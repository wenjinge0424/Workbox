//
//  HttpRest.m
//  BeaconAttitude
//
//  Created by Vitaly on 10/7/16.
//  Copyright © 2016 Vitaly. All rights reserved.
//

#import "HttpRest.h"
#import "Util.h"
#import "Config.h"

@implementation HttpRest
static HttpRest* restManager = NULL;
- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

+(id) sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        restManager = [[self alloc] init];
    });
    return restManager;
}


- (void) RestGetRequest:(NSString *) urlString paramDict:(NSMutableDictionary *)paramDict completionBlock: (void (^)(id, NSError *))completionBlock {
    if (!manager) {
        manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:STRIPE_KEY password:@""];
    }
    
    [manager GET:urlString
      parameters:paramDict
         success:^(NSURLSessionTask *task, id responseObject) {
             NSLog(@"%@", responseObject);
             completionBlock (responseObject, nil);
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             NSLog(@"%@", error);
             completionBlock (nil, error);
         }];
}

- (void) RestPostRequest:(NSString *) urlString paramDict:(NSMutableDictionary *)paramDict completionBlock: (void (^)(id, NSError *))completionBlock {
    if (!manager) {
        manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:STRIPE_KEY password:@""];
    }
    
    [manager POST:urlString
       parameters:paramDict
          success:^(NSURLSessionTask *task, id responseObject) {
              NSLog(@"%@", responseObject);
              completionBlock (responseObject, nil);
          } failure:^(NSURLSessionTask *operation, NSError *error) {
              NSLog(@"%@", error);
              completionBlock (nil, error);
          }];
}

@end
