//
//  AdminAddWorkVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AdminAddWorkVC.h"

@interface AdminAddWorkVC (){
    __weak IBOutlet UILabel *lblCategory;
    __weak IBOutlet UILabel *lblPosition;
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UILabel *lblPayment;
    __weak IBOutlet UILabel *lblBiddingTime;
    __weak IBOutlet UILabel *lblBidStartAmount;
    __weak IBOutlet UITextView *tvDesc;
}

@end

@implementation AdminAddWorkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [tvDesc setEditable:NO];
    [self loadJobData];
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
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)onApprove:(id)sender {
    [_jobObj setObject:[NSNumber numberWithInteger:STATE_WAITING] forKey:FIELD_STATE];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [_jobObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error == nil){
            [self getPreferContactsAndSendNotifictation:_jobObj];
            [self getContactsAndSendNotifictation:_jobObj.objectId];
        }else {
            if (error.code == 202){
                [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
            }else
                [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
        }
    }];
}
- (IBAction)onDecline:(id)sender {
    [_jobObj setObject:[NSNumber numberWithInteger:STATE_DECLINE] forKey:FIELD_STATE];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [_jobObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error == nil){
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {
            if (error.code == 202){
                [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
            }else
                [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
        }
    }];
}

- (void) loadJobData {
    lblCategory.text = [_jobObj objectForKey:FIELD_CATEGORY];
    lblPosition.text = [_jobObj objectForKey:FIELD_POSITION];
    lblLocation.text = [_jobObj objectForKey:FIELD_LOCATION];
    lblPayment.text = [_jobObj objectForKey:FIELD_PAYMENTMETHOD];
    NSDate* bidTime = (NSDate*)[_jobObj objectForKey:FIELD_DATE];
    NSString* strBidTime = [Util convertDate2StringWithFormat:bidTime dateFormat:@"hh:mm a MM dd, yyyy"];
    lblBiddingTime.text = strBidTime;
    NSNumber* startNumber = [_jobObj objectForKey: FIELD_START_BID_AMOUNT];
    lblBidStartAmount.text = [NSString stringWithFormat:@"$ %d", startNumber.intValue];
    tvDesc.text = [_jobObj objectForKey:FIELD_DESCRIPTION];
}

- (void) getContactsAndSendNotifictation: (NSString*)jobid{
    PFQuery *query = [PFUser query];
    [query whereKey:FIELD_IS_BANNED equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:FIELD_USER_TYPE equalTo:[NSNumber numberWithInteger:TYPE_USER_LOOKING]];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        for(PFUser* lookingUser in resultObj) {
            [lookingUser fetchIfNeeded];
            [Util sendPushNotification:TYPE_JOB_POST obecjtId:jobid receiver:lookingUser.username message:@"A Job posted" senderId:@""];
            
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void) getPreferContactsAndSendNotifictation: (PFObject*)jobObj{
    if(jobObj) {
        PFQuery *query = [PFUser query];
        [query whereKey:FIELD_IS_BANNED equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:FIELD_USER_TYPE equalTo:[NSNumber numberWithInteger:TYPE_USER_LOOKING]];
        [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
        
        [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
            for(PFUser* lookingUser in resultObj) {
                [lookingUser fetchIfNeeded];
                NSString* userExp = lookingUser[FIELD_EXPERIENCE];
                if(userExp) {
                    NSString* jobCategory = jobObj[FIELD_CATEGORY];
                    if(jobCategory) {
                        BOOL isMatching = NO;
                        if([userExp isEqualToString:jobCategory]) {
                            isMatching = YES;
                        }
                        else if ([userExp isEqualToString:@"Others"]) {
                            isMatching = YES;
                            if([jobCategory isEqualToString:@"Auto Detailing"] || [jobCategory isEqualToString:@"Carpentry"] || [jobCategory isEqualToString:@"Gardening"] || [jobCategory isEqualToString:@"Cleaning"] || [jobCategory isEqualToString:@"MetalWorks"]) {
                                isMatching = NO;
                            }
                        }
                        if(isMatching) {
                            PFGeoPoint* userPoint = lookingUser[FIELD_GEOPOINT];
                            if(userPoint) {
                                PFGeoPoint* jobPoint = jobObj[FIELD_GEOPOINT];
                                if(jobPoint) {
                                    CLLocation* userlocation = [[CLLocation alloc] initWithLatitude: userPoint.latitude longitude: userPoint.longitude];
                                    CLLocation* joblocation = [[CLLocation alloc] initWithLatitude: jobPoint.latitude longitude: jobPoint.longitude];
                                    double dist_left = [userlocation distanceFromLocation: joblocation];
                                    int userDist = [lookingUser[FIELD_NEAR_DISTANCE] intValue];
                                    if(dist_left < userDist * 1609.344) { // 1 Mile = 1609.344 Meters
                                        [Util sendPushNotification:TYPE_PREFER_JOB_POST obecjtId:jobObj.objectId receiver:lookingUser.username message:@"A Job posted." senderId:@""];
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
        }];
        
    }
    
}
@end
