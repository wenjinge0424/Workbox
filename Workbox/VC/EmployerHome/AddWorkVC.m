//
//  AddWorkVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AddWorkVC.h"
#import <GooglePlaces/GooglePlaces.h>

#define placeholdertext @"Write your description here..."

@interface AddWorkVC () <UINavigationControllerDelegate, UITextViewDelegate, GMSAutocompleteViewControllerDelegate>{
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
    NSDate* bidDate;
    __weak IBOutlet UITextView *tvDesc;
    __weak IBOutlet UILabel *lblCategory;
    __weak IBOutlet UITextField *tfPosition;
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UITextField *tfPayment;
    __weak IBOutlet UITextField *tfBiddingTime;
    __weak IBOutlet UITextField *tfStartAmount;
    __weak IBOutlet UIView *innerV;
    __weak IBOutlet UITableView *tv;
}

@end

@implementation AddWorkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    zipCode = @"";
    city = @"";
    tvDesc.delegate = self;
    tvDesc.text = placeholdertext;
    tvDesc.textColor = [UIColor lightGrayColor];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker setMinimumDate:[NSDate date]];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [tfBiddingTime setInputView:datePicker];
    
    CGRect frame = innerV.frame;
    frame.size.height = tv.frame.size.height;
    innerV.frame = frame;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString* curCategory = [defaults objectForKey:CURRENT_CATEGORY];
    if (curCategory == nil) {
        return;
    }
    lblCategory.text = curCategory;
    
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
-(void)updateTextField:(UIDatePicker *)dtPicker{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"dd/MM/yy hh:mm a"];
    tfBiddingTime.text = [timeFormatter stringFromDate:dtPicker.date];
    bidDate = dtPicker.date;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSubmit:(id)sender {
    // submit
    if([self isValid]) {
        [self registerJob];
    }
}
- (IBAction)onCategory:(id)sender {
    [self performSegueWithIdentifier:@"showEmployerCategoryVC" sender:Nil];
}

- (IBAction)onLocation:(id)sender {
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}


// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    lblLocation.text = place.formattedAddress;
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholdertext]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeholdertext;
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}


- (BOOL) isValid {
    [self removeHighlight];
    lblCategory.text = [Util trim:lblCategory.text];
    tfPosition.text = [Util trim:tfPosition.text];
    lblLocation.text = [Util trim:lblLocation.text];
    tfPayment.text = [Util trim:tfPayment.text];
    tfBiddingTime.text = [Util trim:tfBiddingTime.text];
    tfStartAmount.text = [Util trim:tfStartAmount.text];
    tvDesc.text = [Util trim:tvDesc.text];
    NSString *strCategory = lblCategory.text;
    NSString *strPosition = tfPosition.text;
    NSString *strLocation = lblLocation.text;
    NSString *strPayment = tfPayment.text;
    NSString *strBidTime = tfBiddingTime.text;
    NSString *strStartAmount = tfStartAmount.text;
    NSString *strDesc = tvDesc.text;
    
    int errCount = 0;
    if ([strCategory isEqualToString:@""]) {
        [Util setBorderView:lblCategory color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
    if (strPosition.length < 6 || strPosition.length > 30){
        [Util setBorderView:tfPosition color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if([strLocation isEqualToString:@""]) {
        [Util setBorderView:lblLocation color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
    if([strBidTime isEqualToString:@""]) {
        [Util setBorderView:tfBiddingTime color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
    if (strPayment.length < 2 || strPayment.length > 20){
        [Util setBorderView:tfPayment color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if([strStartAmount isEqualToString:@""]) {
        [Util setBorderView:tfStartAmount color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
    if ((strDesc.length < 6 || strDesc.length > 160) || [strDesc isEqualToString: placeholdertext]){
        [Util setBorderView:tvDesc color:[UIColor redColor] width:0.6];
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

- (void) registerJob {
    PFObject* job = [PFObject objectWithClassName:@"Job"];
    [job setObject:tfPosition.text forKey:FIELD_POSITION];
    [job setObject:lblLocation.text forKey:FIELD_LOCATION];
    [job setObject:lonLat forKey:FIELD_GEOPOINT];
    [job setObject:tfPayment.text forKey:FIELD_PAYMENTMETHOD];
    [job setObject:bidDate forKey:FIELD_DATE];
    [job setObject:[PFUser currentUser] forKey:FIELD_OWNER];
    [job setObject:[NSNumber numberWithInt:[tfStartAmount.text intValue]]  forKey:FIELD_START_BID_AMOUNT];
    [job setObject:tvDesc.text forKey:FIELD_DESCRIPTION];
    [job setObject:tfPosition.text forKey:FIELD_TITLE];
    if([lblCategory.text isEqualToString:@"Hot Jobs"]) {
        [job setObject:[NSNumber numberWithInteger:STATE_WAITING] forKey:FIELD_STATE];
    }
    else {
        [job setObject:[NSNumber numberWithInteger:STATE_READY] forKey:FIELD_STATE];
    }
    [job setObject:lblCategory.text forKey:FIELD_CATEGORY];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [job saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error == nil){
            [self getContactsAndSendNotifictation];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            if (error.code == 202){
                [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
            }else
                [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
        }
    }];
    
}

- (void) getContactsAndSendNotifictation{
    PFQuery *query = [PFUser query];
    [query whereKey:FIELD_USER_TYPE equalTo:[NSNumber numberWithInteger:TYPE_ADMIN]];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(objects) {
            for(PFUser* lookingUser in objects) {
                [lookingUser fetchIfNeeded];
                [Util sendPushNotification:TYPE_JOB_APPROVED obecjtId:@"" receiver:lookingUser.username message:@"A job posted." senderId:@""];
            }
        }
    }];
}

- (void) removeHighlight {
    [Util setBorderView:lblCategory color:[UIColor clearColor] width:0.6];
    [Util setBorderView:tfPosition color:[UIColor clearColor] width:0.6];
    [Util setBorderView:lblLocation color:[UIColor clearColor] width:0.6];
    [Util setBorderView:tfPayment color:[UIColor clearColor] width:0.6];
    [Util setBorderView:tfBiddingTime color:[UIColor clearColor] width:0.6];
    [Util setBorderView:tfStartAmount color:[UIColor clearColor] width:0.6];
    [Util setBorderView:tvDesc color:[UIColor clearColor] width:0.6];
    
}

@end
