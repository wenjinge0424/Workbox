//
//  LogInOptionVC.m
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "LogInOptionVC.h"
#import "LogInVC.h"

@interface LogInOptionVC (){
    NSInteger loginType;
}
@end

@implementation LogInOptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util appDelegate].rootNav = self.navigationController;
    loginType = ACCOUNT_TYPE_EMPLOYER;
    
    if ([Util getBoolValue:USER_LOGIN_STATUS]) {
        
        NSString *username = [Util getLoginUserName];
        NSString *password = [Util getLoginUserPassword];
        
        if (![Util isConnectableInternet]) {
            [Util showAlertTitle:self title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
            return;
        }
        
        [SVProgressHUD setForegroundColor:MAIN_COLOR];
        [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            [SVProgressHUD dismiss];
            if (!user) {
                [Util showAlertTitle:self title:@"Error" message:@"User login failed."];
                [Util setLoginUserName:@"" password:@""];
            } else {
                [Util registerInstallation];
                [self afterLoginWithUser:user andPassword:password];
            }
        }];
    }
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
- (IBAction)onIHaveWork:(id)sender {
    loginType = ACCOUNT_TYPE_EMPLOYER;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:ACCOUNT_TYPE_EMPLOYER forKey:@"accountType"];
    [self performSegueWithIdentifier:@"showLoginVC" sender:Nil];
}

- (IBAction)onLookingForWork:(id)sender {
    loginType = ACCOUNT_TYPE_WORKER;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:ACCOUNT_TYPE_WORKER forKey:@"accountType"];
    [self performSegueWithIdentifier:@"showLoginVC" sender:Nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"showLoginVC"]) {
    }
}



- (void)afterLoginWithUser:(PFUser *)user andPassword:(NSString *)password {
    BOOL admin = [[[PFUser currentUser] objectForKey:@"admin"] boolValue];
    if (admin){
        return;
    }
    
    [Util setLoginUserName:user.username password:password];
    [[AppStateManager sharedInstance] setSignUpUser:user];
    [AppStateManager sharedInstance].isSigned = YES;
    [self gotoMainScreen];
}



- (void) gotoMainScreen {
    PFUser *me = [PFUser currentUser];
    if (!me[FIELD_USER_TYPE]){
        [self showErrorMsg:LOCALIZATION(@"invalid_user")];
        return;
    }
    int type = [me[FIELD_USER_TYPE] intValue];
    if (type == TYPE_ADMIN){
        UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"AdminHomeVC"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == TYPE_USER_HAVE) {
        UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"EmployerHomeVC"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == TYPE_USER_LOOKING){
        UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"WorkerHomeVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void) showErrorMsg:(NSString *) msg {
    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:msg];
}

- (void) showNetworkErr {
    [self showErrorMsg:LOCALIZATION(@"network_error")];
}

@end
