//
//  SignUpTwoViewController.m
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "SignUpTwoViewController.h"

@interface SignUpTwoViewController (){
    IBOutlet UITextField *txtPassword;
    IBOutlet UIButton *btnNext;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnLength;
    IBOutlet UIButton *btnUpper;
    IBOutlet UIButton *btnLower;
    IBOutlet UIButton *btnNumber;
    IBOutlet UILabel *lblLength;
    IBOutlet UILabel *lblUpper;
    IBOutlet UILabel *lblLower;
    IBOutlet UILabel *lblNumber;    
    PFUser *newUser;
    BOOL longPW;
    BOOL numberPW;
}

@end

@implementation SignUpTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [txtPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    newUser = [[AppStateManager sharedInstance] getSignUpUser];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lblTitle.text = LOCALIZATION(@"sign_up");
    txtPassword.placeholder = LOCALIZATION(@"enter_password");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    lblLength.text = LOCALIZATION(@"pwd_one");
    lblUpper.text = LOCALIZATION(@"pwd_two");
    lblLower.text = LOCALIZATION(@"pwd_three");
    lblNumber.text = LOCALIZATION(@"pwd_four");
    txtPassword.delegate = self;
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


- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    NSString *password = txtPassword.text;
    
    if ([txtPassword.text isEqualToString:@""]){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_EMPTY];
        return;
    }
    
    if (password.length<6){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_SHORT];
        return;
    }
    
    if (password.length>20){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_LONG];
        return;
    }
    
    if (![Util isContainsUpperCase:password]){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_UPPER];
        return;
    }
    
    if (![Util isContainsLowerCase:password]){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_LOWER];
        return;
    }
    
    if (![Util isContainsNumber:password]){
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_PASSWORD_NUMBER];
        return;
    }
    
    newUser.password = [Util trim:password];
    [[AppStateManager sharedInstance] setSignUpUser:newUser];
    [self performSegueWithIdentifier:@"showSignupthreeVC" sender:Nil];
}

- (BOOL) isValid {
    BOOL result = btnLength.selected && btnLower.selected && btnUpper.selected && btnNumber.selected;
    return result;
}

-(void)textFieldDidChange :(UITextField *) textField{
    NSString *password = txtPassword.text;
    btnLength.selected = (password.length >= 6);
    btnUpper.selected = [Util isContainsUpperCase:password];
    btnLower.selected = [Util isContainsLowerCase:password];
    btnNumber.selected = [Util isContainsNumber:password];
    if (txtPassword.text.length>20)
        txtPassword.text = [txtPassword.text substringToIndex:20];
    btnNext.enabled = [self isValid];
    if([self isValid]) {
        txtPassword.textColor = MAIN_TEXT_COLOR;
    }
    else {
        txtPassword.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
    }
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 20;
}

@end
