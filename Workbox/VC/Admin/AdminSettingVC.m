//
//  AdminSettingVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AdminSettingVC.h"
#import "LogInOptionVC.h"

@interface AdminSettingVC ()

@end

@implementation AdminSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

@end
