//
//  AppDelegate.m
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AppDelegate.h"
#import "Util.h"
#import "HDNotificationView.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "HomeVC.h"
#import "EmployersProfileVC.h"
#import "ReviewVC.h"
#import "ProfileVC.h"
#import "NotificationVC.h"
#import "ChatViewController.h"
#import "ChatUsersViewController.h"
#import "ListOfBiddersVC.h"
#import "JobDetailsVC.h"
@import Stripe;
//@import Firebase;

@interface AppDelegate (){
    NSTimer *timerForRateTheApp;
    NSTimer *timerUserRelogin;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Override point for customization after application launch.
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:@""];
    
    [PFUser enableAutomaticUser];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"d2a5c93e-283b-45d2-beac-54c2b1bd4c29";
        configuration.clientKey = @"8caf7fa4-dd80-4a22-be74-5a4e426b767c";
        configuration.server = @"https://parse.brainyapps.com:20031/parse";
    }]];
    [PFUser enableRevocableSessionInBackground];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    PFInstallation *currentInstall = [PFInstallation currentInstallation];
    if (currentInstall) {
        currentInstall.badge = 0;
        [currentInstall saveInBackground];
    }
    // Push Notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    
    // register local notification for job alarm
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        
    }
    
    //    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    //
    //    //Google Map
    [GMSServices provideAPIKey:@""];
    [GMSPlacesClient provideAPIKey:@""];
    //
    //    // Google SignIn
    [GIDSignIn sharedInstance].clientID = @"";
    [GIDSignIn sharedInstance].delegate = self;
    //
    //
    
    //set default category
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString* curCategory = [defaults objectForKey:CURRENT_CATEGORY];
    if (curCategory == nil || [curCategory isEqualToString:@""]) {
        [defaults setObject:@"Cleaning" forKey:CURRENT_CATEGORY];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    [currentInstallation saveInBackground];
    
    [self handleNotification:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*Maybe later rate the app*/
- (void)startTimerForLaterRatingApp{
    timerForRateTheApp = [NSTimer scheduledTimerWithTimeInterval:2*60 target:self selector:@selector(showRatingAlert) userInfo:nil repeats:YES];
}

- (void)stopTimerForLaterRatingApp{
    if (timerForRateTheApp != nil){
        [timerForRateTheApp invalidate];
        timerForRateTheApp = nil;
    }
}

- (void)showRatingAlert {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    alert.customViewColor = MAIN_COLOR;
    
    [alert addButton:@"Rate Now" actionBlock:^{
        [self stopTimerForLaterRatingApp];
    }];
    
    [alert addButton:@"Maybe Later" actionBlock:^{
        [self startTimerForLaterRatingApp];
    }];
    
    [alert addButton:@"No, Thanks" actionBlock:^{
        [self stopTimerForLaterRatingApp];
    }];
    
    [alert showInfo:@"Rate App" subTitle:@"" closeButtonTitle:nil duration:0.f];
}

- (void)handleNotification:(NSDictionary *)notificationData {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    if ([PFUser currentUser] != nil && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedNotification" object:nil userInfo:@{}];
        
        NSDictionary *apsData = (NSDictionary *)[notificationData objectForKey:@"aps"];
        NSString *objectId = (NSString *)[notificationData objectForKey:@"data"];
        NSString *senderId = (NSString *)[apsData objectForKey:@"sound"];
        NSString *strMessage = (NSString *)[apsData objectForKey:@"alert"];
        int type = [notificationData[@"type"] intValue];
        NSArray* noti_list = (NSArray*)[[ud objectForKey:UD_NOTIFICATIONS] mutableCopy];
        NSMutableArray* new_noti_list;
        if(noti_list) {
            new_noti_list = [noti_list mutableCopy];
        }
        else {
            new_noti_list = [[NSMutableArray alloc] init];
        }
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              objectId, @"objectId",
                              strMessage, @"message",
                              senderId, @"senderId",
                              [NSNumber numberWithInt:type], @"type",
                              nil];
        [new_noti_list addObject:data];
        [ud setObject:new_noti_list forKey:UD_NOTIFICATIONS];
        
        UIViewController *topController = [self topViewController];
        if(topController) {
            if ([topController isKindOfClass:[NotificationVC class]]) {
                NotificationVC* vc = (NotificationVC*)topController;
                [vc loadNotifications];
                return;
            }
        }
        
        if(type == TYPE_JOB_POST) {
            if(topController) {
                if ([topController isKindOfClass:[HomeVC class]]) {
                    HomeVC* vc = (HomeVC*)topController;
                    [vc getAllJobs];
                    return;
                }
            }
            return;
        }
        else if(type == TYPE_REVIEW_POST) {
            if(topController) {
                if ([topController isKindOfClass:[EmployersProfileVC class]]) {
                    EmployersProfileVC* vc = (EmployersProfileVC*)topController;
                    [vc getReviews];
                    return;
                }
                else if ([topController isKindOfClass:[ReviewVC class]]) {
                    ReviewVC* vc = (ReviewVC*)topController;
                    [vc getReviews];
                    return;
                }
                else if ([topController isKindOfClass:[ProfileVC class]]) {
                    ProfileVC* vc = (ProfileVC*)topController;
                    [vc getReviews];
                    return;
                }
            }
        }
        else if(type == TYPE_PLACE_BID) {
            [NSNotificationCenter.defaultCenter postNotificationName:kPlacebid object:nil];
            return;
            
        }
        else if(type == TYPE_CHAT) {
            NSString *roomId = objectId;
            if ([roomId isEqualToString:[AppStateManager sharedInstance].chatRoomId]){
                [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotification object:nil];
                return;
            }
            if(topController) {
                if ([topController isKindOfClass:[ChatUsersViewController class]]) {
                    ChatUsersViewController* vc = (ChatUsersViewController*)topController;
                    [vc getAllGroups];
                    //                    return;
                }
            }
            
        }
        else if(type == TYPE_JOB_APPROVED) {
            [NSNotificationCenter.defaultCenter postNotificationName:kJobApproved object:nil];
            return;
        }
        else if (type == TYPE_PREFER_JOB_POST) {
            if(topController) {
                if ([topController isKindOfClass:[HomeVC class]]) {
                    HomeVC* vc = (HomeVC*)topController;
                    return;
                }
            }
            else {
                strMessage = @"New Job Posted.";
            }
            
        }
        else {
            return;
        }
        
        AudioServicesPlaySystemSound(1301);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        /// Show notification view
        [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"notification_icon.png"]
                                                    title:@"Workbox"
                                                  message:strMessage
                                               isAutoHide:YES
                                                  onTouch:^{
                                                      
                                                      /// On touch handle. You can hide notification view or do something
                                                      [HDNotificationView hideNotificationViewOnComplete:^{
                                                          if(type == TYPE_CHAT) {
                                                              PFQuery *query = [PFUser query];
                                                              [query whereKey:@"objectId" equalTo:senderId];
                                                              [Util showWaitingMark];
                                                              [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                                                  [Util hideWaitingMark];
                                                                  if(object) {
                                                                      PFUser* user = (PFUser*) object;
                                                                      if(user) {
                                                                          PFQuery *query = [PFQuery queryWithClassName:@"Group"];
                                                                          [query includeKeys:@[FIELD_PARTICIPANTS, FIELD_REMOVELIST, FIELD_LAST_MESSAGE]];
                                                                          [query whereKey:@"objectId" equalTo:objectId];
                                                                          [query orderByDescending:@"updatedAt"];
                                                                          [Util showWaitingMark];
                                                                          [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                                                              [Util hideWaitingMark];
                                                                              if(object) {
                                                                                  PFObject* room = (PFObject*) object;
                                                                                  if(room) {
                                                                                      ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
                                                                                      vc.toUser = user;
                                                                                      vc.room = room;
                                                                                      if(topController.navigationController) {
                                                                                          [topController.navigationController pushViewController:vc animated:YES];
                                                                                      }
                                                                                  }
                                                                              }
                                                                          }];
                                                                          
                                                                      }
                                                                  }
                                                              }];
                                                              
                                                              
                                                          }
                                                          else if (type == TYPE_PREFER_JOB_POST || type == TYPE_JOB_POST) {
                                                              JobDetailsVC *vc = (JobDetailsVC *)[Util getUIViewControllerFromStoryBoard:@"JobDetailsVC"];
                                                              PFQuery *query = [PFQuery queryWithClassName:@"Job"];
                                                              [query includeKeys:@[FIELD_OWNER]];
                                                              [query whereKey:@"objectId" equalTo:objectId];
                                                              [query orderByDescending:@"updatedAt"];
                                                              
                                                              [Util showWaitingMark];
                                                              [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                                                  [Util hideWaitingMark];
                                                                  if(object){
                                                                      vc.jobObj = object;
                                                                      if(topController.navigationController) {
                                                                          [topController.navigationController pushViewController:vc animated:YES];
                                                                      }
                                                                  }
                                                              }];
                                                          }
                                                          
                                                      }];
                                                  }];
    }
}


- (void)sendNotification:(NSString *)name {
    PFUser *me = [PFUser currentUser];
    if (me != nil){
        [me fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
        }];
    }
}

- (void)userBannedByAdministrator {
    
}

- (void)startTimerForRelogin{
    timerUserRelogin = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkRelogin) userInfo:nil repeats:YES];
}

- (void)stopTimerForRelogin{
    if (timerUserRelogin != nil){
        [timerUserRelogin invalidate];
        timerUserRelogin = nil;
    }
}

- (void)checkRelogin {
    if ([Util isConnectableInternet]) {
        [self stopTimerForRelogin];
        PFUser *me = [PFUser currentUser];
        
        if (me != nil){
            [Util showWaitingMark];
            
            [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
                [PFUser logInWithUsernameInBackground:[Util getLoginUserName] password:[Util getLoginUserPassword] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                    [Util hideWaitingMark];
                    
                    
                    [[PFUser currentUser] fetchIfNeeded];
                    
                    if (error!= nil){
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        alert.shouldDismissOnTapOutside = YES;
                        alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
                        alert.customViewColor = MAIN_COLOR;
                        [alert showInfo:@"Login Faild" subTitle:@"" closeButtonTitle:@"Okay" duration:0.f];
                    }
                }];
            }];
        }
    }
}


- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)viewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navContObj = (UINavigationController*)viewController;
        return [self topViewControllerWithRootViewController:navContObj.visibleViewController];
    } else if (viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed) {
        UIViewController* presentedViewController = viewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    else {
        for (UIView *view in [viewController.view subviews])
        {
            id subViewController = [view nextResponder];
            if ( subViewController && [subViewController isKindOfClass:[UIViewController class]])
            {
                if ([(UIViewController *)subViewController presentedViewController]  && ![subViewController presentedViewController].isBeingDismissed) {
                    return [self topViewControllerWithRootViewController:[(UIViewController *)subViewController presentedViewController]];
                }
            }
        }
        return viewController;
    }
}


@end
