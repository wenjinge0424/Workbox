//
//  AdminEditProfileVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AdminEditProfileVC.h"

@interface AdminEditProfileVC (){
    PFUser* me;
}
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfRePassword;

@end

@implementation AdminEditProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    [self loadProfile];
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
- (IBAction)onSave:(id)sender {
    if([self isValid]) {
        me.password = _tfPassword.text;
        [Util showWaitingMark];
        [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [Util hideWaitingMark];
            
            if (succeeded){
                [Util setLoginUserName:me.username password:_tfPassword.text];
                [Util showAlertTitle:self title:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Your account was updated successfully.", nil) finish:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                [Util showAlertTitle:self title:NSLocalizedString(@"Sign Up", nil) message:NSLocalizedString(@"Unknown error occurred.", nil)];
            }
        }];
    }
}

- (void) loadProfile {
    _tfEmail.text = [NSString stringWithFormat:@"%@", me[FIELD_EMAIL]];
    [_tfEmail setEnabled:NO];
    _tfPassword.text = [NSString stringWithFormat:@"%@", me[FIELD_PREVIEW_PASSWORD]];
    _tfRePassword.text = [NSString stringWithFormat:@"%@", me[FIELD_PREVIEW_PASSWORD]];

}

- (BOOL) isValid {
    _tfPassword.text = [Util trim:_tfPassword.text];
    _tfRePassword.text = [Util trim:_tfRePassword.text];
    NSString* password = _tfPassword.text;
    
    if ([password isEqualToString:@""]){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_EMPTY];
        return NO;
    }
    
    if (password.length<6){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_SHORT];
        return NO;
    }
    
    if (password.length>20){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_LONG];
        return NO;
    }
    
    if (![Util isContainsUpperCase:password]){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_UPPER];
        return NO;
    }
    
    if (![Util isContainsLowerCase:password]){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_LOWER];
        return NO;
    }
    
    if (![Util isContainsNumber:password]){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_NUMBER];
        return NO;
    }
    
    if(![password isEqualToString:_tfRePassword.text]) {
        [Util showAlertTitle:self title:STRING_ERROR message:@"Password and Confirm Password is not mached."];
        return NO;
    }
    return  YES;

}

@end
