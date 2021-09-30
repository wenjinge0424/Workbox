//
//  EmployersProfileVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "EmployersProfileVC.h"
#import "EmployerProfileTableViewCell.h"
#import "HCSStarRatingView.h"
#import "ReviewVC.h"
#import "JobDetailsVC.h"
#import <GooglePlaces/GooglePlaces.h>

@interface EmployersProfileVC () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate, GMSAutocompleteViewControllerDelegate> {
    NSMutableArray *arr_jobs;
    NSMutableArray *arr_reviews;
    PFUser* me;
    BOOL isEditing;
    BOOL isAvatarChanged;
    BOOL isLocationChanged;
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
}
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starV;
@property (weak, nonatomic) IBOutlet UITableView *tvJobs;
@end

@implementation EmployersProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    isEditing = NO;
    isAvatarChanged = NO;
    isLocationChanged = NO;
    [_btnEdit setTitle:@"EDIT" forState:UIControlStateNormal];
    [_btnAdd setTitle:@"ADD" forState:UIControlStateNormal];
    _lblTitle.text = @"MY PROFILE";
    [_tfName setEnabled:NO];
    zipCode = @"";
    city = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Cleaning" forKey:CURRENT_CATEGORY];
    [self loadProfile];
    [self getReviews];
    [self getPreviousJob];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)onEdit:(id)sender {
    if (!isEditing) {
        [_btnAdd setTitle:@"SAVE" forState:UIControlStateNormal];
        [_btnEdit setTitle:@"CANCEL" forState:UIControlStateNormal];
        _lblTitle.text = @"EDIT PROFILE";
        isEditing = YES;
        [_tfName setEnabled:YES];
        [_tvJobs reloadData];
        return;
    }
    if (isEditing) {
        [_btnAdd setTitle:@"ADD" forState:UIControlStateNormal];
        [_btnEdit setTitle:@"EDIT" forState:UIControlStateNormal];
        _lblTitle.text = @"MY PROFILE";
        isEditing = NO;
        [_tfName setEnabled:NO];
        [_tvJobs reloadData];
        return;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_jobs.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmployerProfileTableViewCell *cell = (EmployerProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"EmployerProfileTableViewCell"];
    UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
    UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
    UILabel *lblAddress = (UILabel *)[cell viewWithTag:3];
    UIImageView *imgTimer = (UIImageView *)[cell viewWithTag:4];
    UILabel *lblHour = (UILabel *)[cell viewWithTag:5];
    UIButton *btnDelete = (UIButton *)[cell viewWithTag:6];
    [btnDelete setHidden:YES];
    
    NSInteger row = indexPath.item;
    if (row < arr_jobs.count) {
        PFObject *job = [arr_jobs objectAtIndex:row];
        if (job != nil) {
            NSString* cat_name = [job objectForKey:FIELD_CATEGORY];
            UIImage* cat_img = [Util getCategoryImage:cat_name];
            imgCategory.image = cat_img;
            lblTitle.text = [job objectForKey:FIELD_POSITION];
            lblAddress.text = [job objectForKey:FIELD_LOCATION];
            imgTimer.hidden = YES;
            lblHour.hidden = YES;
            
            if([job[FIELD_STATE] intValue] == STATE_WAITING) {
                
                NSDate* endDate = (NSDate*)[job objectForKey:FIELD_DATE];
                NSTimeInterval secondsBetween = [endDate timeIntervalSinceNow];     // second unit
                if (secondsBetween > 0) {
                    secondsBetween = secondsBetween / 60 / 60;      //hour unit
                    if (secondsBetween < 24) {
                        int tm = (int)secondsBetween;
                        lblHour.text = [NSString stringWithFormat:@"%d hours", tm];
                    }
                    else if (secondsBetween < 24 * 30) {
                        int tm = (int)(secondsBetween / 24);
                        lblHour.text = [NSString stringWithFormat:@"%d days", tm];
                    }
                    else{
                        int tm = (int)(secondsBetween / 24 / 30);
                        lblHour.text = [NSString stringWithFormat:@"%d months", tm];
                    }
                    imgTimer.hidden = NO;
                    lblHour.hidden = NO;
                }
                else {
                    lblHour.text = @"";
                }
            }
            lblTitle.adjustsFontSizeToFitWidth = YES;
            lblTitle.minimumScaleFactor = 0.1;
            lblAddress.adjustsFontSizeToFitWidth = YES;
            lblAddress.minimumScaleFactor = 0.1;
        }
    }
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JobDetailsVC *vc = (JobDetailsVC *)[Util getUIViewControllerFromStoryBoard:@"JobDetailsVC"];
    vc.jobObj = arr_jobs[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onShowEmployerReview:(id)sender {
    [self performSegueWithIdentifier:@"showEmployersReview" sender:Nil];
}
- (IBAction)onAddWork:(id)sender {
    if([_btnAdd.titleLabel.text isEqualToString:@"SAVE"]) {
        // edit profile
        if([self isValid]) {
            NSString* strFullname = _tfName.text;
            NSArray* array = [strFullname componentsSeparatedByString:@" "];
            if(array.count> 1) {
                [me setObject:array[0] forKey:FIELD_FIRST_NAME];
                [me setObject:array[1] forKey:FIELD_LAST_NAME];
            }
            else {
                [me setObject:strFullname forKey:FIELD_FIRST_NAME];
                [me setObject:@"" forKey:FIELD_LAST_NAME];
            }
            if(isLocationChanged) {
                [me setObject:_lblLocation.text forKey:FIELD_LOCATION];
                [me setObject:lonLat forKey:FIELD_GEOPOINT];
            }
            
            if(isAvatarChanged) {
                UIImage *edittedImage = _imgAvatar.image;
                NSData *imageData = UIImageJPEGRepresentation(edittedImage, 0.8);
                if (imageData != nil) {
                    NSString *filename = @"ar.png";
                    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
                    [me setObject:imageFile forKey:FIELD_AVATAR];
                }
            }
            [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
            [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [SVProgressHUD dismiss];
                if (error == nil){
                    [_btnAdd setTitle:@"ADD" forState:UIControlStateNormal];
                    [_btnEdit setTitle:@"EDIT" forState:UIControlStateNormal];
                    _lblTitle.text = @"MY PROFILE";
                    isEditing = NO;
                    [_tfName setEnabled:NO];
                    [_tvJobs reloadData];
                    
                }else {
                    if (error.code == 202){
                        [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                    }else
                        [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
                }
            }];
            
            
        }
    }
    else {
        [self performSegueWithIdentifier:@"showAddWorkVC" sender:Nil];
    }
}
- (IBAction)onTapStarV:(id)sender {
    ReviewVC *vc = (ReviewVC *)[Util getUIViewControllerFromStoryBoard:@"ReviewVC"];
    vc.arr_reviews = [arr_reviews mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onTapAvatar:(id)sender {
    if (isEditing) {
        NSString *takePhoto = NSLocalizedString(@"Take a new photo", nil);
        NSString *choosePhoto = NSLocalizedString(@"Select from gallery", nil);
        NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:takePhoto, choosePhoto, nil];
        [actionSheet showInView:self.view];
    }
}


- (void) loadProfile {
    if(!isAvatarChanged) {
        [Util setAvatar:_imgAvatar withUser:me];
    }
    
    _tfName.text = [NSString stringWithFormat:@"%@ %@", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
    _lblLocation.text = me[FIELD_LOCATION];
    _starV.value = 0;
}

- (void) getPreviousJob {
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query includeKeys:@[FIELD_OWNER, FIELD_BIDDERS, FIELD_WORKER]];
    [query whereKey:FIELD_OWNER equalTo:me];
    [query orderByDescending:@"updatedAt"];
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_jobs removeAllObjects];
        arr_jobs = [resultObj mutableCopy];
        [_tvJobs reloadData];
    }];
}


- (void) getReviews {
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query includeKeys:@[FIELD_OWNER, FIELD_TO_USER]];
    [query whereKey:FIELD_TO_USER equalTo:me];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_reviews removeAllObjects];
        arr_reviews = [resultObj mutableCopy];
        int sum = 0;
        for(PFObject* review in arr_reviews) {
            sum = sum + [review[FIELD_MARK] intValue];
        }
        _starV.value = sum * 1.f / arr_reviews.count;
    }];
}



#pragma mark PickerViewDelegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *edittedImage = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(edittedImage, 0.8);
    if (imageData == nil) {
        [Util showAlertTitle:self title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please select your profile image.", nil)];
        return;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    _imgAvatar.image = edittedImage;
    isAvatarChanged = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            [Util checkCameraPermissionWithSuccess:^(id resultObj) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
                    imagePicker.delegate = self;
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imagePicker.allowsEditing = YES;
                    
                    [self presentViewController:imagePicker animated:YES completion:nil];
                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *message = NSLocalizedString(@"Unable to find a camera on your device.", nil);
                        [Util showAlertTitle:self.parentViewController title:NSLocalizedString(@"Edit Profile", nil) message:message info:NO];
                    });
                }
            } failure:^(id resultObj) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Util showAlertTitle:self title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enable the permissions in order to use your Camera Library. Check your permissions in Settings > Privacy > Camera.", nil)];
                });
            }];
        }
            break;
            
        case 1:{
            [Util checkPhotoPermissionWithSuccess:^(id resultObj) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:picker animated:YES completion:NULL];
            } failure:^(id resultObj) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Util showAlertTitle:self title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enable the permissions in order to use your Photo Library. Check your permissions in Settings > Privacy > Photo", nil)];
                });
            }];
        }
            break;
            
        default:
            break;
    }
}


- (BOOL) isValid {
    [self removeHighlight];
    _tfName.text = [Util trim:_tfName.text];
    _lblLocation.text = [Util trim:_lblLocation.text];
    NSString *strName = _tfName.text;
    NSString *strLocation = _lblLocation.text;
    int errCount = 0;
    if (strName.length < 6 || strName.length > 20){
        [Util setBorderView:_tfName color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (strLocation.length < 6){
        [Util setBorderView:_lblLocation color:[UIColor redColor] width:0.6];
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
    [Util setBorderView:_tfName color:[UIColor clearColor] width:0.6];
    [Util setBorderView:_lblLocation color:[UIColor clearColor] width:0.6];
    
    
}

- (void) showErrorMsg:(NSString *) msg {
    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:msg];
}

- (void) showNetworkErr {
    [self showErrorMsg:LOCALIZATION(@"network_error")];
}
- (IBAction)onTapLocation:(id)sender {
    if (isEditing) {
        if (![Util isConnectableInternet]){
            [self showNetworkErr];
            return;
        }
        GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
        acController.delegate = self;
        [self presentViewController:acController animated:YES completion:nil];
    }
    
}


// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    _lblLocation.text = place.formattedAddress;
    lonLat = [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
    isLocationChanged = YES;
    
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

@end
