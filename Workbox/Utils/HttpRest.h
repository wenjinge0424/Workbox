//
//  HttpRest.h
//  BeaconAttitude
//
//  Created by Vitaly on 10/7/16.
//  Copyright © 2016 Vitaly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

@interface HttpRest : NSObject
{
    AFHTTPSessionManager *manager;
}

+ (id) sharedManager;
- (void) RestGetRequest:(NSString *)urlString paramDict:(NSMutableDictionary *)paramDict completionBlock: (void (^)(id, NSError *))completionBlock;
- (void) RestPostRequest:(NSString *)urlString paramDict:(NSMutableDictionary *)paramDict completionBlock: (void (^)(id, NSError *))completionBlock;
@end
