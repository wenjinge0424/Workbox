//
//  ProfileVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "ProfileVC.h"
#import "ProfileVideoCollectionViewCell.h"
#import "HCSStarRatingView.h"
#import "ReviewVC.h"
#import "IQDropDownTextField.h"
#import <GooglePlaces/GooglePlaces.h>
#import "PreviousJobDetailPhoto.h"
#import "PreviousJobDetailVideo.h"
#import "CellDelegate.h"

@interface ProfileVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate,IQDropDownTextFieldDelegate, GMSAutocompleteViewControllerDelegate>{
    
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UIButton *btnEdit;
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UITextField *categoryTF;
    __weak IBOutlet UIView *categoryV;
    __weak IBOutlet UILabel *lblDistance;
    __weak IBOutlet UICollectionView *videoCV;
    __weak IBOutlet HCSStarRatingView *starV;
    __weak IBOutlet UIView *categoryDropdownV;
    NSMutableArray *arr_jobs;
    NSMutableArray *arr_reviews;
    PFUser* me;
    __weak IBOutlet IQDropDownTextField *categoryDropdown;
    __weak IBOutlet IQDropDownTextField *distanceDropdown;
    BOOL isEditing;
    BOOL isAvatarChanged;
    BOOL isLocationChanged;
    __weak IBOutlet UIButton *btnCancel;
    __weak IBOutlet UITextField *tfName;
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
    
}

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    me = [PFUser currentUser];
    zipCode = @"";
    city = @"";
    // Do any additional setup after loading the view.
    
    NSArray *categoryList = @[@"Auto Detailing", @"Carpentry", @"Electronics", @"Masonry", @"Cleaning", @"Electrical", @"Metal Works", @"Plumbing", @"Hot Jobs", @"Moving and Shipping", @"Daycare", @"Pet Care", @"Tutoring", @"Landscaping", @"Garbage Removal", @"Auto Mechanic", @"Furniture Assembly", @"Other Jobs"];
    
    categoryDropdown.delegate = self;
    categoryDropdown.isOptionalDropDown = NO;
    [categoryDropdown setItemList:categoryList];
    
    distanceDropdown.delegate = self;
    distanceDropdown.isOptionalDropDown = NO;
    [distanceDropdown setItemList:@[@"1 - 10 miles", @"1 - 20 miles", @"1 - 30 miles", @"1 - 40 miles", @"1 - 50 miles"]];
    
    isEditing = NO;
    isAvatarChanged = NO;
    isLocationChanged = NO;
    btnCancel.hidden = YES;
    [btnEdit setTitle:@"EDIT" forState:UIControlStateNormal];
    [tfName setEnabled:NO];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadProfile];
    [self getPreviousJob];
    [self getReviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSInteger selectedRow = distanceDropdown.selectedRow;
    [me setObject:categoryDropdown.text forKey:FIELD_EXPERIENCE];
    int distance = 7500;
    if(selectedRow == 0) {
        distance = 10;
    }
    else if(selectedRow == 1) {
        distance = 20;
    }
    else if(selectedRow == 2) {
        distance = 30;
    }
    else if(selectedRow == 3) {
        distance = 40;
    }
    else if(selectedRow == 4) {
        distance = 50;
    }
    [me setObject:[NSNumber numberWithInteger:distance]  forKey:FIELD_NEAR_DISTANCE];
    [me saveInBackground];
    
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
        [btnEdit setTitle:@"SAVE" forState:UIControlStateNormal];
        btnCancel.hidden = NO;
        isEditing = YES;
        [tfName setEnabled:YES];
        [videoCV reloadData];
        return;
    }
    if(isEditing) {
        // save
        if([self isValid]) {
            NSString* strFullname = tfName.text;
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
                [me setObject:lblLocation.text forKey:FIELD_LOCATION];
                [me setObject:lonLat forKey:FIELD_GEOPOINT];
            }
            
            if(isAvatarChanged) {
                UIImage *edittedImage = imgAvatar.image;
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
                    [btnEdit setTitle:@"EDIT" forState:UIControlStateNormal];
                    btnCancel.hidden = YES;
                    [tfName setEnabled:NO];
                    isEditing = NO;
                    [videoCV reloadData];
                    
                }else {
                    if (error.code == 202){
                        [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                    }else
                        [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
                }
            }];
        }
    }
}


- (IBAction)onAdd:(id)sender {
    [self performSegueWithIdentifier:@"showPreviousJobVC" sender:Nil];
    
}
- (IBAction)onTabStarView:(id)sender {
    ReviewVC *vc = (ReviewVC *)[Util getUIViewControllerFromStoryBoard:@"ReviewVC"];
    vc.arr_reviews = [arr_reviews mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark CollectionView delegate & datasource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arr_jobs.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileVideoCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.cellIndex = indexPath.row; // Set indexpath if its a grouped table.
    UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
    UILabel *lblCategory = (UILabel *)[cell viewWithTag:2];
    UIButton *btnDelete = (UIButton *)[cell viewWithTag:3];
    if (isEditing) {
        [btnDelete setHidden:NO];
    }
    else {
        [btnDelete setHidden:YES];
    }
    NSInteger row = indexPath.item;
    if (row < arr_jobs.count) {
        PFObject *job = [arr_jobs objectAtIndex:row];
        if (job != nil) {
            PFFile *filePhoto = job[FIELD_THUMBNAIL];
            if(filePhoto) {
                [filePhoto getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                    if (!error) {
                        imgCategory.image = [UIImage imageWithData:data];
                    }
                }];
            }
            
            lblCategory.text = [job objectForKey:FIELD_TITLE];
        }
    }
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject* jobObj = arr_jobs[indexPath.row];
    if(jobObj) {
        BOOL isVideo = [jobObj[FIELD_THUMBNAIL_IS_VIDEO] boolValue];
        if(isVideo) {
            PreviousJobDetailVideo *vc = (PreviousJobDetailVideo *)[Util getUIViewControllerFromStoryBoard:@"PreviousJobDetailVideo"];
            vc.jobObj = jobObj;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            PreviousJobDetailPhoto *vc = (PreviousJobDetailPhoto *)[Util getUIViewControllerFromStoryBoard:@"PreviousJobDetailPhoto"];
            vc.jobObj = jobObj;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    
}

- (CGSize) collectionView:(UICollectionView *) collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    int nWidth = (CGRectGetWidth(collectionView.frame) - 15 ) / 3;
    int nHeight = nWidth * 1.3;
    return CGSizeMake(nWidth, nHeight);
}

- (void) loadProfile {
    if(!isAvatarChanged) {
        [Util setAvatar:imgAvatar withUser:me];
    }
    tfName.text = [NSString stringWithFormat:@"%@ %@", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
    lblLocation.text = me[FIELD_LOCATION];
    starV.value = 0;
}

- (void) getPreviousJob {
    PFQuery *query = [PFQuery queryWithClassName:@"Portfolio"];
    [query includeKeys:@[FIELD_OWNER_1]];
    [query whereKey:FIELD_OWNER_1 equalTo:me];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_jobs removeAllObjects];
        arr_jobs = [resultObj mutableCopy];
        
        [videoCV reloadData];
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
        starV.value = sum * 1.f / arr_reviews.count;
    }];
}

- (IBAction)onCancel:(id)sender {
    isEditing = NO;
    [btnEdit setTitle:@"EDIT" forState:UIControlStateNormal];
    btnCancel.hidden = YES;
    [tfName setEnabled:NO];
    [videoCV reloadData];
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


#pragma mark PickerViewDelegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *edittedImage = info[UIImagePickerControllerEditedImage];
    
    NSData *imageData = UIImageJPEGRepresentation(edittedImage, 0.8);
    if (imageData == nil) {
        [Util showAlertTitle:self title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please select your profile image.", nil)];
        return;
    }
    imgAvatar.image = edittedImage;
    isAvatarChanged = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
    tfName.text = [Util trim:tfName.text];
    lblLocation.text = [Util trim:lblLocation.text];
    NSString *strName = tfName.text;
    NSString *strLocation = lblLocation.text;
    int errCount = 0;
    if (strName.length < 6 || strName.length > 20){
        [Util setBorderView:tfName color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (strLocation.length < 6){
        [Util setBorderView:lblLocation color:[UIColor redColor] width:0.6];
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
    [Util setBorderView:tfName color:[UIColor clearColor] width:0.6];
    [Util setBorderView:lblLocation color:[UIColor clearColor] width:0.6];
}

- (void) showErrorMsg:(NSString *) msg {
    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:msg];
}

- (void) showNetworkErr {
    [self showErrorMsg:LOCALIZATION(@"network_error")];
}
- (IBAction)onTapLocation:(id)sender {
    if(isEditing) {
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
    lblLocation.text = place.formattedAddress;
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

- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withData:(id)data
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    alert.customViewColor = MAIN_COLOR;
    PFObject* deleteJob = arr_jobs[cellIndex];
    [alert addButton:@"Yes" actionBlock:^{
        if(deleteJob) {
            [deleteJob deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self getPreviousJob];
            }];
        }
    }];
    [alert showInfo:@"Warning" subTitle:@"Are you sure you want to delete this job?" closeButtonTitle:@"No" duration:0.f];
}

@end
