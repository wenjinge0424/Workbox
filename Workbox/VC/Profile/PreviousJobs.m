//
//  PreviousJobs.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "PreviousJobs.h"
#import "HomeViewController.h"
#import <GooglePlaces/GooglePlaces.h>

@interface PreviousJobs () <UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate, GMSAutocompleteViewControllerDelegate> {
    
    __weak IBOutlet UITextView *tvDescription;
    NSURL *videoURLToPost;
    UIImage *imageToPost;
    HomeViewController *homeVC;
    UIImageView* iv_thumbnail;
    __weak IBOutlet UILabel *lblLocation;
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
    __weak IBOutlet UIButton *btnLocation;
    __weak IBOutlet UIView *innerView;
}

@end

@implementation PreviousJobs

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    iv_thumbnail = [[UIImageView alloc] init];
    
    CGRect frame = innerView.frame;
    frame.size.height = self.view.bounds.size.height - 66;
    innerView.frame = frame;
    
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
- (IBAction)onAdd:(id)sender {
    if([self isValid]) {
        PFObject* porfolio = [PFObject objectWithClassName:@"Portfolio"];
        [porfolio setObject:[PFUser currentUser] forKey:FIELD_OWNER_1];
        [porfolio setObject:tvDescription.text forKey:FIELD_DESCRIPTION];
        [porfolio setObject:lblLocation.text forKey:FIELD_LOCATION];
        [porfolio setObject:lonLat forKey:FIELD_GEOPOINT];
        [porfolio setObject:@"Cleaning" forKey:FIELD_CATEGORY];
        [porfolio setObject:tvDescription.text forKey:FIELD_TITLE];
        UIImage *edittedImage = iv_thumbnail.image;
        NSData *imageData = UIImageJPEGRepresentation(edittedImage, 0.8);
        
        if (imageData != nil) {
            NSString *filename = @"ar.png";
            PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
            [porfolio setObject:imageFile forKey:FIELD_THUMBNAIL];
        }
        
        if(videoURLToPost != nil){
            [porfolio setObject:[NSNumber numberWithBool:YES] forKey:FIELD_THUMBNAIL_IS_VIDEO];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *videoName = [NSString stringWithFormat:@"video_%f.mp4", [NSDate timeIntervalSinceReferenceDate]];
            NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:videoName];
            CallbackHandler handler;
            handler = ^(id resultObj){
                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURLToPost options:nil];
                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
                exportSession.outputURL = [NSURL fileURLWithPath:myPathDocs];
                exportSession.outputFileType = AVFileTypeQuickTimeMovie;
                exportSession.shouldOptimizeForNetworkUse = YES;
                
                [Util showWaitingMark];
                
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    NSData *videoData = [NSData dataWithContentsOfURL:exportSession.outputURL];
                    if (videoData == nil){
                        [Util showAlertTitle:self title:STRING_ERROR message:MESSAGE_ERROR_UNKNOWN_OCCURED];
                        return;
                    }
                    
                    NSString *filename = @"video.mp4";
                    PFFile *videoFile = [PFFile fileWithName:filename data:videoData];
                    [porfolio setObject:videoFile forKey:FIELD_VIDEO];
                    
                    [Util saveInBackground:porfolio vc:self handler:^(id resultObj) {
                        //                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MUSCLE_INFO_CHANGED object:nil];
                        //                        [self didTapBackBtn:nil];
                        [self onBack:nil];
                    }];
                }];
            };
            handler(nil);
        }
        else {
            [porfolio setObject:[NSNumber numberWithBool:NO] forKey:FIELD_THUMBNAIL_IS_VIDEO];
            [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
            [porfolio saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [SVProgressHUD dismiss];
                if (error == nil){
                    
                    [self onBack:nil];
                }else {
                    if (error.code == 202){
                        [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                    }else
                        [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
                }
            }];
        }
        
        
    }
    // add
    //    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
- (IBAction)onTakePhoto:(id)sender {
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
                [Util showAlertTitle:self.parentViewController title:NSLocalizedString(@"Previous Jobs", nil) message:message info:NO];
            });
        }
    } failure:^(id resultObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util showAlertTitle:self title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enable the permissions in order to use your Camera Library. Check your permissions in Settings > Privacy > Camera.", nil)];
        });
    }];
}
- (IBAction)onSelectPhoto:(id)sender {
    [Util checkPhotoPermissionWithSuccess:^(id resultObj) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        
        CFStringRef mTypes[2] = { kUTTypeImage, kUTTypeMovie };
        CFArrayRef mTypesArray = CFArrayCreate(CFAllocatorGetDefault(), (const void**)mTypes, 2, &kCFTypeArrayCallBacks);
        picker.mediaTypes = (__bridge NSArray*)mTypesArray;
        
        picker.videoMaximumDuration = 15.f;
        
        [self presentViewController:picker animated:YES completion:NULL];
    } failure:^(id resultObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util showAlertTitle:self title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enable the permissions in order to use your Photo Library. Check your permissions in Settings > Privacy > Photo", nil)];
        });
    }];
}
- (IBAction)onTakeVideo:(id)sender {
    //    homeVC = [HomeViewController new];
    //    [self presentViewController:homeVC animated:YES completion:nil];
    [Util checkCameraPermissionWithSuccess:^(id resultObj) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            imagePicker.allowsEditing = YES;
            NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            NSArray *videoMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
            
            if([videoMediaTypesOnly count] == 0) {
                
            }
            else {
                imagePicker.mediaTypes = videoMediaTypesOnly;
            }
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        } else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = NSLocalizedString(@"Unable to find a camera on your device.", nil);
                [Util showAlertTitle:self.parentViewController title:NSLocalizedString(@"Previous Jobs", nil) message:message info:NO];
            });
        }
    } failure:^(id resultObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util showAlertTitle:self title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enable the permissions in order to use your Camera Library. Check your permissions in Settings > Privacy > Camera.", nil)];
        });
    }];
}

#pragma mark PickerViewDelegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if([info[UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)(kUTTypeImage)]){
        imageToPost = [info objectForKey:UIImagePickerControllerEditedImage];
        videoURLToPost = nil;
        iv_thumbnail.image = [info objectForKey:UIImagePickerControllerEditedImage];
    }else{
        imageToPost = nil;
        videoURLToPost = [info objectForKey:UIImagePickerControllerMediaURL];
        iv_thumbnail.image = [Util generateThumbImage:videoURLToPost];
        //        [iv_play setHidden:NO];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) recordStopped {
    videoURLToPost = [homeVC getOutPutUrl];
    iv_thumbnail.image = [Util generateThumbImage:videoURLToPost];
    [homeVC dismissViewControllerAnimated:YES completion:nil];
    homeVC = nil;
}

- (BOOL) isValid {
    [self removeHighlight];
    tvDescription.text = [Util trim:tvDescription.text];
    NSString *strName = tvDescription.text;
    int errCount = 0;
    if (strName.length < 6 || strName.length > 60){
        [Util setBorderView:tvDescription color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
    lblLocation.text = [Util trim:lblLocation.text];
    NSString *strLocation = lblLocation.text;
    if (strLocation.length < 2){
        [Util setBorderView:btnLocation color:[UIColor redColor] width:0.6];
        errCount++;
    }
    
    if (videoURLToPost == nil && imageToPost == nil) {
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
    [Util setBorderView:tvDescription color:[UIColor clearColor] width:0.6];
    [Util setBorderView:btnLocation color:[UIColor clearColor] width:0.6];
    
    
}

- (void) showErrorMsg:(NSString *) msg {
    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:msg];
}

- (void) showNetworkErr {
    [self showErrorMsg:LOCALIZATION(@"network_error")];
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

@end
