//
//  SettingVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "SettingVC.h"
#import "PrivacyPolicyVC.h"
#import "LogInOptionVC.h"
#import "CardInformationVC.h"
#import "PFFacebookUtils.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SettingVC () <MFMailComposeViewControllerDelegate>{
    PFUser* me;
    NSMutableArray *arr_jobs;
    
    NSMutableArray *arr_countedInviteId;
    NSMutableArray *arr_noCounted;
}

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    arr_jobs = [NSMutableArray new];
    arr_countedInviteId = [NSMutableArray new];
    arr_noCounted = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)onSubscription:(id)sender {
    [self performSegueWithIdentifier:@"showSubscriptionVC" sender:Nil];
}
- (IBAction)onPrivacyPolicy:(id)sender {
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[Util getUIViewControllerFromStoryBoard:@"PrivacyPolicyVC"];
    vc.mType = 0;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onTermsConditions:(id)sender {
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[Util getUIViewControllerFromStoryBoard:@"PrivacyPolicyVC"];
    vc.mType = 1;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onAboutTheApp:(id)sender {
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[Util getUIViewControllerFromStoryBoard:@"PrivacyPolicyVC"];
    vc.mType = 2;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onReportProblem:(id)sender {
    if (![Util isConnectableInternet]) {
        [Util showAlertTitle:self title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
        return;
    }
    
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailComposeViewController=[[MFMailComposeViewController alloc] init];
        
        mailComposeViewController.mailComposeDelegate=self;
        [mailComposeViewController setSubject:@"Report a Problem"];
        [mailComposeViewController setToRecipients:@[@"workboxapp@gmail.com"]];
        
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Information" message:@"Your device is impossible to send Email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}
- (IBAction)onLogout:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    alert.customViewColor = MAIN_COLOR;
    
    [alert addButton:@"Ok" actionBlock:^{
        [Util showWaitingMark];
        
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            [Util hideWaitingMark];
            [AppStateManager sharedInstance].isSigned = NO;
            [Util setBoolValue:USER_LOGIN_STATUS value:NO];
            [Util setLoginUserName:@"" password:@""];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil];
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation removeObjectForKey:PARSE_FIELD_USER];
            [currentInstallation saveInBackground];
            
            for (UIViewController *vc in [Util appDelegate].rootNav.viewControllers){
                if ([vc isKindOfClass:[LogInOptionVC class]]) {
                    [[Util appDelegate].rootNav popToViewController:vc animated:YES];
                    break;
                }
            }
        }];
    }];
    
    [alert showInfo:@"Confirmation" subTitle:@"Are you sure you want to logout?" closeButtonTitle:@"Cancel" duration:0.f];
}
- (IBAction)onChangeCardInformation:(id)sender {
    CardInformationVC *vc = (CardInformationVC *)[Util getUIViewControllerFromStoryBoard:@"CardInformationVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onInviteFBFriend:(id)sender {
    if(me[FIELD_FACEBOOKID]) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.shouldDismissOnTapOutside = YES;
        alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
        alert.customViewColor = MAIN_COLOR;
        
        [alert addButton:@"Yes" actionBlock:^{
            [self getFacebookFriends];
        }];
        [alert showInfo:@"" subTitle:@"Allow app access to Facebook?" closeButtonTitle:@"No" duration:0.f];
    }
    else {
        [Util showAlertTitle:self title:@"" message:@"You can invite your Facebook friends when you are logged in with Facebook."];
    }
    
}

- (void) getFacebookFriends {
    [Util showWaitingMark];
    [arr_jobs removeAllObjects];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,first_name,last_name,birthday,email" forKey:@"fields"];
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends"
                                                                   parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error == nil)
        {
            NSDictionary *userData = (NSDictionary *)result;
            NSArray* friendsArray = (NSArray*)userData[@"data"];
            for(NSDictionary* friend in friendsArray) {
                NSString* friendId = friend[@"id"];
                [arr_jobs addObject:friendId];
                NSLog(@"%@", friendId);
            }
            if(me){
                arr_countedInviteId = me[FIELD_COUNTED_INVITE_ID];
                if(arr_countedInviteId == nil) {
                    arr_countedInviteId = [NSMutableArray new];
                }
                [me setObject:arr_jobs forKey:FIELD_INVITED_FACEBOOK_FRIENDS_ID];
                [arr_noCounted removeAllObjects];
                for(NSString* invitedId in arr_jobs){
                    if(![arr_countedInviteId containsObject:invitedId]) {
                        [arr_noCounted addObject:invitedId];
                    }
                }
                if(arr_noCounted.count >= 10) {
                    [me setObject:[NSNumber numberWithInteger:0]  forKey:FIELD_CUR_BID_COUNT];
                    [me setObject:[NSNumber numberWithInteger:TYPE_SUB_FREE]  forKey:FIELD_SUBSCRIPTION];
                    [me setObject:[NSNumber numberWithInteger:39999]  forKey:FIELD_BID_COUNT_PERMONTH];
                    [me setObject:[NSDate date] forKey:FIELD_PAID_AT];
                    for(NSString* noCountedId in arr_noCounted) {
                        [arr_countedInviteId addObject:noCountedId];
                    }
                    [me setObject:arr_countedInviteId forKey:FIELD_COUNTED_INVITE_ID];
                    
                }
                [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [Util hideWaitingMark];
                    if(succeeded) {
                        [self sendLinkOnFBMessenger];
                    }
                }];
                
            }            
        }
        else
        {
            [Util setLoginUserName:@"" password:@""];
            [PFUser logOut];
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile."];
        }
    }];
}

-(void) sendLinkOnFBMessenger {
    NSString* strUrl = [NSString stringWithFormat:@"fb-messenger-share-api://"];
    NSURL *fbURL = [NSURL URLWithString:strUrl];
    if ([[UIApplication sharedApplication] canOpenURL: fbURL]) {
        FBSDKShareLinkContent* content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:AppStoreUrl];
        FBSDKMessageDialog *messageDialog = [[FBSDKMessageDialog alloc] init];
        messageDialog.shareContent = content;
        if ([messageDialog canShow]) {
            [messageDialog show];
        }
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/messenger/id454638411?mt=8"]];
    }
}


#pragma MFMailComposeViewController

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    switch (result) {
        case MFMailComposeResultSent:
            [[[UIAlertView alloc] initWithTitle:@"Information" message:@"Sent Email successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
            
        case MFMailComposeResultFailed:
            [[[UIAlertView alloc] initWithTitle:@"Information" message:@"Failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
            
        default:
            break;
    }
    
}

@end
