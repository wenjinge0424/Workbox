//
//  StripeRest.h
//  ManuelNadeen
//
//  Created by Vitaly on 11/1/16.
//  Copyright © 2016 Vitaly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"

/* Unified Code */
#define CODE_EXPIRY_TIME_STRIPE                 (3600*24*30)
#define CODE_EXPIRY_TIME                        (3600*24*365)
#define CODE_LENGTH                             5

#import "HttpRest.h"

/* Stripe */
#define STRIPE_URL                              @"https://api.stripe.com/v1"
#define STRIPE_CHARGES                          @"charges"
#define STRIPE_CUSTOMERS                        @"customers"
#define STRIPE_TOKENS                           @"tokens"
#define STRIPE_CAPTURE                          @"capture"

@interface StripeRest : NSObject

+ (void) getCharges:(NSString *)start completionBlock: (BOOL (^)(id, BOOL, NSError *))completionBlock;
+ (void) setCharges:(NSMutableDictionary *)chargeDict tokenDict:(NSMutableDictionary *)tokenDict completionBlock: (void (^)(id, NSError *))completionBlock;
+ (void) captureCharge:(NSString *)chargeId completionBlock: (void (^)(id, NSError *))completionBlock;
+ (void) getAccount:(NSString *)accountId completionBlock: (void (^)(id, NSError *))completionBlock;
+ (void) getCustomer:(NSString *)customer start:(NSString *)start completionBlock: (void (^)(id, NSError *))completionBlock;
+ (void) setCustomer:(NSString *)customer_id param:(NSMutableDictionary *)param completionBlock: (void (^)(id, NSError *))completionBlock;

@end
