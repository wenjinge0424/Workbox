//
//  SignUpFourViewController.m
//  Workbox
//
//  Created by developer  on 1/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "SignUpFourViewController.h"
#import "CircleImageView.h"
#import <GooglePlaces/GooglePlaces.h>

@interface SignUpFourViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate>{
    IBOutlet UITextField *txtFirstName;
    IBOutlet UITextField *txtLastName;
    IBOutlet UITextField *txtLocation;
    IBOutlet UILabel *lblAddress;
    __weak IBOutlet UIButton *btnAgree;
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
    PFUser *newUser;
    BOOL isAgree;
    __weak IBOutlet UIButton *btnNext;
}

@end

@implementation SignUpFourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    zipCode = @"";
    city = @"";
    txtFirstName.delegate = self;
    txtLastName.delegate = self;
    newUser = [[AppStateManager sharedInstance] getSignUpUser];
    isAgree = NO;
    btnNext.enabled = isAgree;
    if ([AppStateManager sharedInstance].isSigned){
        NSString *firstName = [Util getLoginFirstName];
        NSString *lastName = [Util getLoginLastName];
        txtFirstName.text = firstName;
        txtLastName.text = lastName;
    }
    [txtFirstName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    txtFirstName.delegate = self;
    
    [txtLastName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    txtLastName.delegate = self;
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

- (IBAction)onLocation:(id)sender {
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    [self signup];
}


- (BOOL) isValid {
    [self removeHighlight];
    txtFirstName.text = [Util trim:txtFirstName.text];
    txtLastName.text = [Util trim:txtLastName.text];
    
    NSString *firstName = txtFirstName.text;
    NSString *lastName = txtLastName.text;
    NSString *address = lblAddress.text;
    
    int errCount = 0;
    if (firstName.length < 2 || firstName.length > 20){
        [Util setBorderView:txtFirstName color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (lastName.length < 2 || lastName.length > 20){
        [Util setBorderView:txtLastName color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
    if (address.length < 2){
        [Util setBorderView:txtLocation color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
    if (errCount == 1){
        [self showErrorMsg:LOCALIZATION(@"err_single")];
        return NO;
    } else if (errCount > 1){
        [self showErrorMsg:LOCALIZATION(@"err_multi")];
        return NO;
    }
    return YES;
}

- (void) removeHighlight {
    [Util setBorderView:txtFirstName color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtLastName color:[UIColor clearColor] width:0.6];
    [Util setBorderView:txtLocation color:[UIColor clearColor] width:0.6];
}

- (void)signup {
    [newUser setObject:[NSNumber numberWithInteger:7500]  forKey:FIELD_NEAR_DISTANCE];
    [newUser setObject:[Util trim:txtFirstName.text] forKey:FIELD_FIRST_NAME];
    [newUser setObject:[Util trim:txtLastName.text] forKey:FIELD_LAST_NAME];
    [newUser setObject:[Util trim:lblAddress.text] forKey:FIELD_LOCATION];
    [newUser setObject:[NSNumber numberWithBool:YES] forKey:FIELD_IS_PAID];
    [newUser setObject:[NSNumber numberWithBool:NO] forKey:FIELD_IS_BANNED];
    [newUser setObject:lonLat forKey:FIELD_GEOPOINT];
    
    [newUser setObject:[NSNumber numberWithInteger:5]  forKey:FIELD_BID_COUNT_PERMONTH];
    [newUser setObject:[NSNumber numberWithInteger:0]  forKey:FIELD_CUR_BID_COUNT];
    [newUser setObject:[NSNumber numberWithInteger:TYPE_SUB_FREE]  forKey:FIELD_SUBSCRIPTION];
    [newUser setObject:@"" forKey:FIELD_PAYMENTINFO];
    [newUser setObject:[NSDate date] forKey:FIELD_PAID_AT];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSInteger nType = [defaults integerForKey:@"accountType"];
    if (nType == ACCOUNT_TYPE_WORKER) {
        [newUser setObject:[NSNumber numberWithInteger:TYPE_USER_LOOKING]  forKey:FIELD_USER_TYPE];
    }
    else {
        [newUser setObject:[NSNumber numberWithInteger:TYPE_USER_HAVE]  forKey:FIELD_USER_TYPE];
    }
    
    [[AppStateManager sharedInstance] setSignUpUser:newUser];
    
    [Util signUpInVC:self finish:^{
        [self performSegueWithIdentifier:@"showOnboardVC" sender:Nil];;
    }];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    txtLocation.hidden = YES;
    lblAddress.text = place.formattedAddress;
    lonLat = [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

# pragma mark UITextField delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [Util setBorderView:textField color:[UIColor clearColor] width:0.6];
}

- (IBAction)onTapAgree:(id)sender {
    isAgree = !isAgree;
    btnAgree.selected = isAgree;
    btnNext.enabled = isAgree;
}


-(void)textFieldDidChange :(UITextField *) textField{
    if(textField == txtFirstName){
        txtFirstName.text = [Util trim:txtFirstName.text];
        NSString *firstName = txtFirstName.text;
        if(firstName.length < 2 || firstName.length > 20) {
            txtFirstName.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
            
        }
        else {
            txtFirstName.textColor = MAIN_TEXT_COLOR;
        }
    }
    else if (textField == txtLastName) {
        txtLastName.text = [Util trim:txtLastName.text];
        NSString *lastName = txtLastName.text;
        if(lastName.length < 2 || lastName.length > 20) {
            txtLastName.textColor = MAIN_TEXT_PLACEHOLDER_COLOR;
            
        }
        else {
            txtLastName.textColor = MAIN_TEXT_COLOR;
        }
    }
    
}

@end
