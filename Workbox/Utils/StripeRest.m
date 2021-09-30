//
//  StripeRest.m
//  ManuelNadeen
//
//  Created by Vitaly on 11/1/16.
//  Copyright © 2016 Vitaly. All rights reserved.
//

#import "StripeRest.h"
#import "HttpRest.h"

@implementation StripeRest
{
}

+ (void) getCharges:(NSString *)start completionBlock: (BOOL (^)(id, BOOL, NSError *))completionBlock
{
    NSString *urlString;
    NSMutableDictionary *paramDict;
    NSMutableDictionary *created;
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970] - CODE_EXPIRY_TIME;
    
    created = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                [NSString stringWithFormat:@"%ld", (long)timeStamp], @"gte",
                nil];
    paramDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                 created, @"created",
                 nil];
    if (start)
        urlString = [NSString stringWithFormat:@"%@/%@?limit=100&starting_after=%@", STRIPE_URL, STRIPE_CHARGES, start];
    else
        urlString = [NSString stringWithFormat:@"%@/%@?limit=100", STRIPE_URL, STRIPE_CHARGES];
    
    [[HttpRest sharedManager] RestGetRequest:urlString paramDict:paramDict completionBlock:^(id response, NSError *err) {
        if (!err) {
            NSDictionary *dict = response;
            NSArray *data = [dict objectForKey:@"data"];
            BOOL has_more = [[dict objectForKey:@"has_more"] boolValue];
            BOOL stop = NO;
            
            if (completionBlock)
                stop = completionBlock (data, has_more, nil);
            
            if (stop) {
                return;
            } else if (has_more) {
                NSString *customer_id;
                dict = [data objectAtIndex:data.count-1];
                customer_id = [dict objectForKey:@"id"];
                [StripeRest getCharges:customer_id completionBlock:completionBlock];
            } else {
                if (completionBlock)
                    completionBlock (nil, NO, nil);
            }
        } else {
            if (completionBlock)
                completionBlock (nil, NO, err);
        }
    }];
}

+ (void) setCharges:(NSMutableDictionary *)chargeDict tokenDict:(NSMutableDictionary *)tokenDict completionBlock: (void (^)(id, NSError *))completionBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", STRIPE_URL, STRIPE_TOKENS];
    [[HttpRest sharedManager] RestPostRequest:urlString paramDict:tokenDict completionBlock:^(id response, NSError *err) {
        if (!err) {
            NSDictionary *dict = response;
            NSString *urlString = [NSString stringWithFormat:@"%@/%@", STRIPE_URL, STRIPE_CHARGES];
            [chargeDict setObject:[dict objectForKey:@"id"] forKey:@"source"];
            [[HttpRest sharedManager] RestPostRequest:urlString paramDict:chargeDict completionBlock:^(id response, NSError *err) {
                if (!err) {
                    if (completionBlock)
                        completionBlock (response, nil);
                } else {
                    if (completionBlock)
                        completionBlock (nil, err);
                }
            }];
        } else {
            if (completionBlock)
                completionBlock (nil, err);
        }
    }];
}

+ (void) captureCharge:(NSString *)chargeId completionBlock: (void (^)(id, NSError *))completionBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/%@", STRIPE_URL, STRIPE_CHARGES, chargeId, STRIPE_CAPTURE];
    [[HttpRest sharedManager] RestPostRequest:urlString paramDict:nil completionBlock:^(id response, NSError *err) {
        if (!err) {
            if (completionBlock)
                completionBlock (response, nil);
        } else {
            if (completionBlock)
                completionBlock (nil, err);
        }
    }];
}

+ (void) getAccount:(NSString *)accountId completionBlock: (void (^)(id, NSError *))completionBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", STRIPE_URL, STRIPE_ACCOUNTS, accountId];
    [[HttpRest sharedManager] RestGetRequest:urlString paramDict:nil completionBlock:^(id response, NSError *err) {
        if (!err) {
            if (completionBlock)
                completionBlock (response, nil);
        } else {
            if (completionBlock)
                completionBlock (nil, err);
        }
    }];
}

+ (void) getCustomer:(NSString *)customer start:(NSString *)start completionBlock: (void (^)(id, NSError *))completionBlock
{
    NSString *urlString;
    
    if (start)
        urlString = [NSString stringWithFormat:@"%@/%@?limit=2&starting_after=%@", STRIPE_URL, STRIPE_CUSTOMERS, start];
    else
        urlString = [NSString stringWithFormat:@"%@/%@?limit=2", STRIPE_URL, STRIPE_CUSTOMERS];
    
    [[HttpRest sharedManager] RestGetRequest:urlString paramDict:nil completionBlock:^(id response, NSError *err) {
        if (!err) {
            NSDictionary *dict = response;
            bool has_more = [[dict objectForKey:@"has_more"] boolValue];
            NSArray *data = [dict objectForKey:@"data"];
            NSString *customer_id;
            NSString *found_id = nil;
            
            for (int i=0; i<data.count; i++) {
                dict = data[i];
                customer_id = [dict objectForKey:@"id"];
                /* TODO: search customer */
                // found_id = customer_id;
            }
            
            if (found_id) {
                if (completionBlock)
                    completionBlock (found_id, nil);
            } else if (has_more) {
                [StripeRest getCustomer:customer start:customer_id completionBlock:completionBlock];
            } else {
                if (completionBlock)
                    completionBlock (nil, nil);
            }
        } else {
            if (completionBlock)
                completionBlock (nil, err);
        }
    }];
}

+ (void) setCustomer:(NSString *)customer_id param:(NSMutableDictionary *)param completionBlock: (void (^)(id, NSError *))completionBlock
{
    NSString *urlString;
    NSMutableDictionary *metadata;
    NSMutableDictionary *paramDict;
    
    if (customer_id)
        urlString = [NSString stringWithFormat:@"%@/%@/%@", STRIPE_URL, STRIPE_CUSTOMERS, customer_id];
    else
        urlString = [NSString stringWithFormat:@"%@/%@", STRIPE_URL, STRIPE_CUSTOMERS];
        
    metadata = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                @"test1@ios.com", @"VerifyCode",
                @"test2@ios.com", @"ExpiryDate",
                @"iOS", @"DeviceType",
                nil];
    paramDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                 @"test@ios.com", @"email",
                 // source, @"source",
                 metadata, @"metadata",
                 nil];
    
    [[HttpRest sharedManager] RestPostRequest:urlString paramDict:param completionBlock:^(id response, NSError *err) {
        if (!err) {
        } else {
        }
    }];
}
    
@end
