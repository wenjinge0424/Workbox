//
//  SignupThreeViewController.m
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "SignupThreeViewController.h"

@interface SignupThreeViewController (){
    IBOutlet UITextField *txtRepassword;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnMatch;
    IBOutlet UILabel *lblMatch;
    IBOutlet UIButton *btnNext;
    PFUser *newUser;
    
}

@end

@implementation SignupThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [txtRepassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    txtRepassword.delegate = self;
    newUser = [[AppStateManager sharedInstance] getSignUpUser];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    lblTitle.text = LOCALIZATION(@"sign_up");
    txtRepassword.placeholder = LOCALIZATION(@"re_enter_pwd");
    [btnNext setTitle:LOCALIZATION(@"next") forState:UIControlStateNormal];
    lblMatch.text = LOCALIZATION(@"pwd_five");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onNext:(id)sender {
    [self performSegueWithIdentifier:@"showSignupFourVC" sender:Nil];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidChange :(UITextField *) textField{
    btnMatch.selected = [newUser.password isEqualToString:txtRepassword.text];
    btnNext.enabled = btnMatch.selected;
    if(btnMatch.selected) {
        txtRepassword.textColor = MAIN_TEXT_COLOR;
    }
    else {
        txtRepassword.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 20;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
