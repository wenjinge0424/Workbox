//
//  AppDelegate.h
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MFSideMenu.h"
#import "PFFacebookUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *rootNav;
- (void)showRatingAlert;
- (void)startTimerForRelogin;

@end

