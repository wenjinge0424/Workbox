//
//  ResetPasswordVC.m
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "ResetPasswordVC.h"

@interface ResetPasswordVC (){
    BOOL isInUse;
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UIButton *btnDone;
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UILabel *lbldesc;
    NSMutableArray *dataArray;
}

@end

@implementation ResetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtEmail.delegate = self;
    [txtEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    dataArray = [[NSMutableArray alloc] init];
    if (![Util isConnectableInternet]){
        [self showErrorMsg:LOCALIZATION(@"network_error")];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *user = [array objectAtIndex:i];
                [dataArray addObject:user.username];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configLanguage];
}

- (void) configLanguage {
    lblTitle.text = LOCALIZATION(@"reset_pwd");
    lbldesc.text = LOCALIZATION(@"reset_desc");
    [btnDone setTitle:LOCALIZATION(@"done") forState:UIControlStateNormal];
    txtEmail.placeholder = LOCALIZATION(@"email_placeholder");
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
- (IBAction)onSubmit:(id)sender {
    if (![Util isConnectableInternet]) {
        [Util showAlertTitle:self title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
        return;
    }
    
    NSString *email = txtEmail.text;
    
    if (email.length == 0) {
        [Util showAlertTitle:self.parentViewController title:@"Reset Password" message:@"Please input email address" finish:^(void) {
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    
    if (![email isEmail]) {
        [Util showAlertTitle:self.parentViewController title:@"Reset Password" message:@"Email address is invalid." finish:^(void) {
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    
    [Util showWaitingMark];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [Util hideWaitingMark];
        
        if (objects.count > 0) {
            [txtEmail resignFirstResponder];
            [Util showWaitingMark];
            
            [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded,NSError *error) {
                [SVProgressHUD dismiss];
                if (!error) {
                    [Util showAlertTitle:self.parentViewController
                                   title:@"Reset password"
                                 message: @"Success! We’ve sent a password reset link to your email"
                                  finish:^(void) {
                                      [self onBack:nil];
                                  }];
                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    [Util showAlertTitle:self.parentViewController
                                   title:@"Reset password"
                                 message:errorString
                                  finish:^(void) {
                                  }];
                }
            }];
        } else{
            [self showNoUserFoundMsg];
        }
    }];
}



- (void)showNoUserFoundMsg {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    alert.customViewColor = MAIN_COLOR;
    
    [alert addButton:@"Sign Up" actionBlock:^{
        [self performSegueWithIdentifier:@"gotoSignUpFromForgotPW" sender:nil];
    }];
    [alert showInfo:@"" subTitle:@"Email entered is not registered. Create an account now?" closeButtonTitle:@"Not now" duration:0.f];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    txtEmail.text = [Util trim:textField.text];
    
    if ([txtEmail.text isEqualToString:@""]){
        return;
    }
    
    if ([dataArray containsObject:txtEmail.text]){
        isInUse = YES;
    }else{
        isInUse = NO;
    }
    
    [self changeState];
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSString *email = txtEmail.text;
    if ([email isEqualToString:@""]){
        return;
    }
    
    if ([dataArray containsObject:txtEmail.text]){
        isInUse = YES;
    }else{
        isInUse = NO;
    }
    
    [self changeState];
}

- (void) changeState {
    if (isInUse){
        txtEmail.textColor = MAIN_TEXT_COLOR;
        [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnDone setEnabled:YES];
    }else {
        txtEmail.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
        [btnDone setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btnDone setEnabled:NO];
    }
}

@end
