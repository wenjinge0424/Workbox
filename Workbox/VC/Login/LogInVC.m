//
//  LogInVC.m
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "LogInVC.h"
#import "Util.h"
#import "PFFacebookUtils.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <Parse/Parse.h>
#import "SignUpFourViewController.h"


typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for that
typedef void (^LoginHandler)(NSString *username, NSString *password);//loginHandler

@interface LogInVC ()<GIDSignInUIDelegate, GIDSignInDelegate, UIActionSheetDelegate, UIWebViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (nonatomic, strong) accountChooserBlock_t accountChooserBlock;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;

@end

@implementation LogInVC
//@synthesize type;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignOut) name:@"signOut" object:nil];
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    self.accountStore = [[ACAccountStore alloc] init];
    _consumerKey = @"HhO0FVP4s6apRPjXA13EhSldI";
    _consumerSecret = @"1o57NmTQii2gN6fgRyp5ZJPGyikw7omAI2Fjw5b6IBjrsYg7h7";
    
    [_txtEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _txtEmail.delegate = self;
    
    [_txtPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _txtPassword.delegate = self;
}

- (void)userSignOut {
    _txtEmail.text = @"";
    _txtPassword.text = @"";
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configLanguage];
}

- (void) configLanguage {
    [_btnLogin setTitle:LOCALIZATION(@"let_go") forState:UIControlStateNormal];
    [_btnSignUp setTitle:LOCALIZATION(@"sign_up") forState:UIControlStateNormal];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

- (IBAction)onLogin:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    
    if (![self isValid]){
        return;
    }
    
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:LOCALIZATION(@"please_wait") maskType:SVProgressHUDMaskTypeGradient];
    
    PFQuery *query = [PFUser query];
    NSString *email = [Util trim:_txtEmail.text];
    NSString *password = [Util trim:_txtPassword.text];
    [query whereKey:FIELD_EMAIL equalTo:email];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
                [SVProgressHUD dismiss];
                if (user) {
                    BOOL isBanned = [user[FIELD_IS_BANNED] boolValue];
                    if (isBanned){
                        [Util showAlertTitle:self title:@"Error" message:@"Banned User"];
                        return;
                    }
                    [self afterLoginWithUser:user andPassword:password];
                } else {
                    NSString *errorString = LOCALIZATION(@"incorrect_password");
                    [Util showAlertTitle:self title:LOCALIZATION(@"login_failed") message:errorString finish:^{
                        [_txtPassword becomeFirstResponder];
                    }];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
            
            NSString *msg = LOCALIZATION(@"msg_not_registerd_email");
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:LOCALIZATION(@"not_now") actionBlock:^(void) {
            }];
            [alert addButton:LOCALIZATION(@"sign_up") actionBlock:^(void) {
                [self onSignup:nil];
            }];
            [alert showError:LOCALIZATION(@"sign_up") subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];
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
    _txtEmail.text = @"";
    _txtPassword.text = @"";
}

- (BOOL) isValid {
    _txtEmail.text = [Util trim:_txtEmail.text];
    NSString *email = _txtEmail.text;
    NSString *password = _txtPassword.text;
    if (email.length == 0){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_email") finish:^(void){
            [_txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_email") finish:^(void){
            [_txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    
    if ([email containsString:@".."]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_email") finish:^(void){
            [_txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    
    if (password.length == 0){
        [self showErrorMsg:LOCALIZATION(@"no_password")];
        return NO;
    }
    
    return YES;
}

- (IBAction)onFacebookLogin:(id)sender {
    if (![Util isConnectableInternet]) {
        [Util showAlertTitle:self title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if (user != nil) {
             if (user[@"facebookid"] == nil) {
                 [self requestFacebook:user];
             } else {
                 [self userLoggedIn:user];
             }
         }else{
             if (error != nil){
                 if (error.code == 202){
                     [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                 }else
                     [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
             }
         }
     }];
}

- (IBAction)onGoogleLogin:(id)sender {
    if (![Util isConnectableInternet]) {
        [Util showAlertTitle:self title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GIDSignIn sharedInstance] signIn];
}


- (IBAction)onResetPwd:(id)sender {
    [self performSegueWithIdentifier:@"showResetPwdVC" sender:Nil];
}

- (IBAction)onSignup:(id)sender {
    [self performSegueWithIdentifier:@"showSignupOneVC" sender:Nil];
}


- (void)requestFacebook:(PFUser *)user
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,first_name,last_name,birthday,email" forKey:@"fields"];
    
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error == nil)
        {
            NSDictionary *userData = (NSDictionary *)result;
            [self processFacebook:user UserData:userData];
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

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
{
    NSString *link = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             NSString *passwd = [Util randomStringWithLength:20];
             user.password = passwd;
             user[FIELD_FIRST_NAME] = [NSString stringWithFormat:@"%@", userData[@"first_name"]];
             user[FIELD_LAST_NAME] = [NSString stringWithFormat:@"%@", userData[@"last_name"]];
             user[FIELD_FACEBOOKID] = userData[@"id"];
             if (userData[@"email"]) {
                 user.email = userData[@"email"];
             } else {
                 NSString *name = [[userData[@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 user.email = [NSString stringWithFormat:@"%@@facebook.com",name];
             }
             user.username = user.email;
             
             UIImage *profileImage = [Util getUploadingImageFromImage:responseObject];
             NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
             NSString *filename = [NSString stringWithFormat:@"%@.png", user.username];
             PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
             user[FIELD_AVATAR] = imageFile;
             
             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  [SVProgressHUD dismiss];
                  if (error == nil){
                      /*Sign In finished*/
                      [self afterLoginWithUser:user andPassword:passwd];
                  }else {
                      if (error.code == 202){
                          [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                      }else
                          [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
                  }
              }];
         } else {
             [Util setLoginUserName:user.email password:user.password];
             [PFUser logOut];
             [SVProgressHUD dismiss];
             [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [Util setLoginUserName:@"" password:@""];
         [PFUser logOut];
         [SVProgressHUD dismiss];
         [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)userLoggedIn:(PFUser *)user
{
    /* login */
    NSString *password = [Util randomStringWithLength:20];
    user.password = password;
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [user saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        [SVProgressHUD dismiss];
        [self afterLoginWithUser:user andPassword:password];
    }];
}


#pragma mark GooglePlus Login
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) {
        if (error.code != -5)
            [Util showAlertTitle:self title:@"Oops!" message:@"Failed to login Google Plus."];
    } else {
        NSString *passwd = [Util randomStringWithLength:20];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              user.profile.email, @"username",
                              user.userID, @"googleid",
                              passwd, @"password",
                              nil];
        
        [Util showWaitingMark];
        
        [PFCloud callFunctionInBackground:@"resetGooglePasswd" withParameters:data block:^(PFUser *registeredUser, NSError *err) {
            if (err) {
                PFUser *puser = [PFUser user];
                puser.password = passwd;
                puser[FIELD_FIRST_NAME] = [NSString stringWithFormat:@"%@", user.profile.givenName];
                puser[FIELD_LAST_NAME] = [NSString stringWithFormat:@"%@",user.profile.familyName];
                puser[FIELD_GOOOGLEID] = user.userID;
                puser.email = user.profile.email;
                puser.username = puser.email;
                if (user.profile.hasImage) {
                    NSURL *imageURL = [user.profile imageURLWithDimension:50*50];
                    UIImage *im = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                    UIImage *profileImage = [Util getUploadingImageFromImage:im];
                    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                    NSString *filename = [NSString stringWithFormat:@"avatar.png"];
                    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
                    puser[FIELD_AVATAR] = imageFile;
                }
                
                [puser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (!error) {
                        PFACL *groupACL = [PFACL ACL];
                        [groupACL setPublicReadAccess:YES];
                        [groupACL setPublicWriteAccess:YES];
                        puser.ACL = groupACL;
                        [puser save];
                        
                        /*Sign In finished*/
                        [self afterLoginWithUser:puser andPassword:passwd];
                    } else {
                        if (error.code == 202){
                            [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                        }else
                            [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
                    }
                }];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    PFQuery *query = [PFUser query];
                    [query whereKey:@"objectId" equalTo:registeredUser.objectId];
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        if (objects.count>0){
                            PFUser *currentUser = [objects firstObject];
                            [PFUser logInWithUsernameInBackground:currentUser.username password:passwd block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                                if (error == nil){
                                    [SVProgressHUD dismiss];
                                    [self afterLoginWithUser:currentUser andPassword:passwd];
                                }
                                else{
                                    [Util showAlertTitle:self title:@"Error" message:@"Unknown error occurred."];
                                }
                            }];
                        }
                    }];
                });
            }
        }];
    }
}

- (void)afterLoginWithUser:(PFUser *)user andPassword:(NSString *)password {
    NSString *loc = [[PFUser currentUser] objectForKey:FIELD_LOCATION];
    if (loc == nil || [loc isEqualToString:@""]){
        [Util setLoginUserName:user.username password:password];
        [Util setLoginUserName:user[FIELD_FIRST_NAME] lastName:user[FIELD_LAST_NAME] password:password];
        [[AppStateManager sharedInstance] setSignUpUser:user];
        [AppStateManager sharedInstance].isSigned = YES;
        
        [Util setBoolValue:USER_LOGIN_STATUS value:YES];
        
        [self gotoSignUpFourVC:user];
        return;
    }
    [Util setLoginUserName:user.username password:password];
    [[AppStateManager sharedInstance] setSignUpUser:user];
    [AppStateManager sharedInstance].isSigned = YES;
    [Util setBoolValue:USER_LOGIN_STATUS value:YES];
    [self gotoMainScreen];
}

- (void) gotoSignUpFourVC :(PFUser *)user {
    SignUpFourViewController *vc = (SignUpFourViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpFourViewController"];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.delegate = self;
    if(textField == _txtPassword){
        _txtPassword.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self changeState:textField];
    if(textField == _txtPassword) {
        _txtPassword.textColor = MAIN_TEXT_COLOR;
    }
}

-(void)textFieldDidChange :(UITextField *) textField{
    if(textField == _txtEmail) {
        _txtEmail.text = [Util trim:_txtEmail.text];
    }
    else if(textField == _txtPassword) {
        _txtPassword.text = [Util trim:_txtPassword.text];
    }
    [self changeState:textField];
}

- (void) changeState : (UITextField*) tf {
    if(tf == _txtEmail){
        NSString *email = _txtEmail.text;
        if (email.length == 0){
            return;
        }
        if (![email isEmail]){
            tf.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
            return;
        }
        
        if ([email containsString:@".."]){
            tf.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
            return;
        }
        tf.textColor = MAIN_TEXT_COLOR;
        return;
    }
    else if(tf == _txtPassword){
        
    }
}

@end
