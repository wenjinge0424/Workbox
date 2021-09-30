//
//  WorkersProfileVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "WorkersProfileVC.h"
#import "ProfileVideoCollectionViewCell.h"
#import "HCSStarRatingView.h"
#import "ReviewVC.h"
#import "WriteReviewVC.h"
#import "ChatViewController.h"
#import "PreviousJobDetailPhoto.h"
#import "PreviousJobDetailVideo.h"

@interface WorkersProfileVC () <UICollectionViewDelegate, UICollectionViewDataSource> {
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UICollectionView *videoCV;
    __weak IBOutlet UITextField *tfName;
    __weak IBOutlet UITextField *tfLocation;
    __weak IBOutlet HCSStarRatingView *starV;
    __weak IBOutlet UIButton *btnAccept;
    __weak IBOutlet UIButton *btnMark;
    NSMutableArray *arr_reviews;
    NSMutableArray *arr_potfolios;
    NSMutableArray *arr_AllGroups;
    NSMutableArray *dataArray;
    PFUser *me;
}


@end

@implementation WorkersProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    arr_AllGroups = [NSMutableArray new];
    me = [PFUser currentUser];
    if (!me[FIELD_USER_TYPE]){
        [self showErrorMsg:LOCALIZATION(@"invalid_user")];
        return;
    }
    int type = [me[FIELD_USER_TYPE] intValue];
    tfName.enabled = type == TYPE_USER_LOOKING;
    tfLocation.enabled = type == TYPE_USER_LOOKING;
    btnMark.hidden = YES;
    
    int jobState = [_jobObj[FIELD_STATE]  intValue];
    btnAccept.hidden = jobState != STATE_WAITING;

    
    [self loadProfile];
    [self getReviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getPortfolios];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark CollectionView delegate & datasource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arr_potfolios.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileVideoCollectionViewCell" forIndexPath:indexPath];
    UIImageView *imgCategory = (UIImageView *)[cell viewWithTag:1];
    UILabel *lblCategory = (UILabel *)[cell viewWithTag:2];
    UIButton *btnDelete = (UIButton *)[cell viewWithTag:3];
    [btnDelete setHidden:YES];
    NSInteger row = indexPath.item;
    if (row < arr_potfolios.count) {
        PFObject *job = [arr_potfolios objectAtIndex:row];
        if (job != nil) {
            [Util setImage:imgCategory imgFile:[job objectForKey:FIELD_THUMBNAIL]];
            lblCategory.text = [job objectForKey:FIELD_TITLE];
        }
    }
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject* jobObj = arr_potfolios[indexPath.row];
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
- (IBAction)onMessage:(id)sender {
    [self getAllGroups];
}
- (IBAction)onReview:(id)sender {
    WriteReviewVC *vc = (WriteReviewVC *)[Util getUIViewControllerFromStoryBoard:@"WriteReviewVC"];
    vc.ower = _bidder;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onPayment:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = MAIN_COLOR;
    UITextField *tf_payAmount = [alert addTextField:@""];
    [tf_payAmount setKeyboardType:UIKeyboardTypeNumberPad];
    
    [Util setBorderView:tf_payAmount color:MAIN_COLOR width:1.f];
    alert.horizontalButtons = YES;
    [alert addButton:@"Confirm" validationBlock:^BOOL{
        if ([tf_payAmount.text isEqualToString:@""]){
            [Util showAlertTitle:self title:STRING_ERROR message:@"Please enter correct amount."];
            return NO;
        }else{
            return YES;
        }
    } actionBlock:^{
        if ([tf_payAmount.text isEqualToString:@""]){
            [Util showAlertTitle:self title:STRING_ERROR message:@"Please enter correct amount."];
        }
        else {
        }
    }];
    [alert showEdit:self title:@"" subTitle:@"Enter your pay amount" closeButtonTitle:@"Cancel" duration:0.0f];
}


- (IBAction)onShowWorkersReview:(id)sender {
    ReviewVC *vc = (ReviewVC *)[Util getUIViewControllerFromStoryBoard:@"ReviewVC"];
    vc.arr_reviews = [arr_reviews mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) showErrorMsg:(NSString *) msg {
    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:msg];
}

- (void) showNetworkErr {
    [self showErrorMsg:LOCALIZATION(@"network_error")];
}
- (IBAction)onAccept:(id)sender {
    [self getAllGroupsJob];
    [_jobObj setObject:_bidder forKey:FIELD_WORKER];
    [_jobObj setObject:[NSNumber numberWithInteger:STATE_STARTED] forKey:FIELD_STATE];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [_jobObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error == nil){
            btnAccept.hidden = YES;
            [Util showAlertTitle:self title:@"" message:@"You hired this user and this job is started."];
        }else {
            if (error.code == 202){
                [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
            }else
                [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
        }
    }];
}


- (void) loadProfile {
    [Util setAvatar:imgAvatar withUser:_bidder];
    tfName.text = [NSString stringWithFormat:@"%@ %@", _bidder[FIELD_FIRST_NAME], _bidder[FIELD_LAST_NAME]];
    tfLocation.text = _bidder[FIELD_LOCATION];
    starV.value = 0;
}


- (void) getReviews {
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query includeKeys:@[FIELD_OWNER, FIELD_TO_USER]];
    [query whereKey:FIELD_TO_USER equalTo:_bidder];
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

- (void) getPortfolios {
    PFQuery *query = [PFQuery queryWithClassName:@"Portfolio"];
    [query includeKeys:@[FIELD_OWNER_1]];
    [query whereKey:FIELD_OWNER_1 equalTo:_bidder];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_potfolios removeAllObjects];
        arr_potfolios = [resultObj mutableCopy];
        [videoCV reloadData];
    }];
}


// check message room or create one.
- (void) getAllGroups {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query includeKeys:@[FIELD_PARTICIPANTS]];
    
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_AllGroups removeAllObjects];
        for(PFObject* group in resultObj) {
            NSArray* participants = group[FIELD_PARTICIPANTS];
            if(participants.count < 2) {
                return ;
            }
            PFUser* user1 = (PFUser*)participants[0];
            PFUser* user2 = (PFUser*)participants[1];
            if(([user1.objectId isEqualToString:_bidder.objectId] && [user2.objectId isEqualToString:me.objectId]) || ([user2.objectId isEqualToString:_bidder.objectId] && [user1.objectId isEqualToString:me.objectId])) {
                [arr_AllGroups insertObject:group atIndex:0];
            }
            
        }
        if(arr_AllGroups.count > 0) {
            PFObject* room = arr_AllGroups[0];
            [room setObject:@[] forKey:FIELD_REMOVELIST];
            [Util showWaitingMark];
            [room saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded) {
                    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
                    vc.room = room;
                    vc.toUser = _bidder;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
                [Util hideWaitingMark];
            }];
        }
        else {
            PFObject* groupObj = [PFObject objectWithClassName:@"Group"];
            NSArray* participants = @[me, _bidder];
            [groupObj setObject:participants forKey:FIELD_PARTICIPANTS];
            [Util showWaitingMark];
            [groupObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [Util hideWaitingMark];
                if (error == nil){
                    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
                    vc.toUser = _bidder;
                    vc.room = groupObj;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else {
                    if (error.code == 202){
                        [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                    }else
                        [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
                }
            }];
        }
    }];
}


// check message room or create one with job
- (void) getAllGroupsJob {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query includeKeys:@[FIELD_PARTICIPANTS]];
    
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_AllGroups removeAllObjects];
        for(PFObject* group in resultObj) {
            if(group[FIELD_JOB_MODEL] == nil) {
                continue;
            }
            NSArray* participants = group[FIELD_PARTICIPANTS];
            if(participants.count < 2) {
                return ;
            }
            PFUser* user1 = (PFUser*)participants[0];
            PFUser* user2 = (PFUser*)participants[1];
            if(([user1.objectId isEqualToString:_bidder.objectId] && [user2.objectId isEqualToString:me.objectId]) || ([user2.objectId isEqualToString:_bidder.objectId] && [user1.objectId isEqualToString:me.objectId])) {
                [arr_AllGroups insertObject:group atIndex:0];
            }
            
        }
        if(arr_AllGroups.count > 0) {
            PFObject* room = arr_AllGroups[0];
            [room setObject:@[] forKey:FIELD_REMOVELIST];
            [Util showWaitingMark];
            [room saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded) {
//                    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
//                    vc.room = room;
//                    vc.toUser = _bidder;
//
//                    [self.navigationController pushViewController:vc animated:YES];
                }
                [Util hideWaitingMark];
            }];
        }
//        else {
        //create chat room with job
            PFObject* groupObj = [PFObject objectWithClassName:@"Group"];
            NSArray* participants = @[me, _bidder];
            [groupObj setObject:participants forKey:FIELD_PARTICIPANTS];
            [groupObj setObject:_jobObj forKey:FIELD_JOB_MODEL];
            [Util showWaitingMark];
            [groupObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [Util hideWaitingMark];
                if (error == nil){
//                    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
//                    vc.toUser = _bidder;
//                    vc.room = groupObj;
//                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else {
                    if (error.code == 202){
                        [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                    }else
                        [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
                }
            }];
//        }
    }];
}

@end
