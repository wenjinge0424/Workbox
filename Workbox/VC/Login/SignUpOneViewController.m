//
//  SignUpOneViewController.m
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "SignUpOneViewController.h"

@interface SignUpOneViewController () <UITextFieldDelegate>{
    IBOutlet UITextField *txtEmail;
    IBOutlet UIButton *btnNext;
    IBOutlet UIButton *btnRegister;
    IBOutlet UIButton *btnValid;
    IBOutlet UILabel *lblNotuse;
    IBOutlet UILabel *lblValid;
    NSMutableArray *dataArray;
}

@end

@implementation SignUpOneViewController
@synthesize user;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [txtEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    txtEmail.delegate = self;
    
    if (![Util isConnectableInternet]){
        [self showErrorMsg:LOCALIZATION(@"network_error")];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [self showErrorMsg:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [dataArray addObject:owner.username];
            }
        }
    }];
    [btnNext setEnabled:NO];
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    txtEmail.placeholder = LOCALIZATION(@"email_placeholder");
    lblNotuse.text = LOCALIZATION(@"not_use");
    lblValid.text = LOCALIZATION(@"valid_email");
}

- (IBAction)onback:(id)sender {
    [[AppStateManager sharedInstance] setSignUpUser:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    if ([Util isConnectableInternet]){
        if (!btnRegister.selected || !btnValid.selected) {
            /*Email is in use*/
            [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_EMAIL_REGISTERED];
        } else{
            PFUser *newUser = [PFUser new];
            newUser.email = [Util trim:txtEmail.text];
            newUser.username = [Util trim:txtEmail.text];
            [[AppStateManager sharedInstance] setSignUpUser:newUser];
            [self performSegueWithIdentifier:@"showSignupTwoVC" sender:Nil];
        }
    }else {
        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_INTERNET_NO_CONNECT];
    }
}

- (BOOL) isValid {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if (email.length == 0){
        return NO;
    }
    if (![email isEmail]){
        return NO;
    }
    if(!btnValid.selected) {
        return NO;
    }
    if(!btnRegister.selected) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.delegate = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [Util trim:textField.text];
    if ([txtEmail.text isEqualToString:@""])
        return;
    [self changeState];
}

-(void)textFieldDidChange :(UITextField *) textField{
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    btnValid.selected = [email isEmail];
    if (![email isEmail]){
        btnRegister.selected = NO;
        return;
    }
    if ([email containsString:@".."]){
        btnValid.selected = NO;
        btnRegister.selected = NO;
        return;
    }
    if ([dataArray containsObject:email]){
        btnRegister.selected = NO;
    } else if ([email isEmail]){
        btnRegister.selected = YES;
    }
    if(btnRegister.selected && btnValid.selected) {
        txtEmail.textColor = MAIN_TEXT_COLOR;
        btnNext.enabled = YES;
    }
    else {
        txtEmail.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
        btnNext.enabled = NO;
    }
}

- (void) changeState {
    if (btnValid.selected && btnRegister.selected){
        txtEmail.textColor = MAIN_TEXT_COLOR;
        [btnNext setEnabled:YES];
    }else {
        txtEmail.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
        [btnNext setEnabled:NO];
    }
}

@end
