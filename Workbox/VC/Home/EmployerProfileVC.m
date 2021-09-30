//
//  EmployerProfileVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "EmployerProfileVC.h"
#import "EmployerProfileTableViewCell.h"
#import "HCSStarRatingView.h"
#import "JobDetailsVC.h"
#import "ReviewVC.h"
#import "WriteReviewVC.h"
#import "ChatViewController.h"

@interface EmployerProfileVC () <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblAddress;
    __weak IBOutlet HCSStarRatingView *vStars;
    __weak IBOutlet UITableView *tvJobs;
    NSMutableArray *arr_jobs;
    NSMutableArray *arr_reviews;
    BOOL isDownloaded;
    NSMutableArray *arr_AllGroups;
    PFUser* me;
}


@end

@implementation EmployerProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadEmployerData];
    [self getPreviousJobs];
    [self getReviews];
    arr_AllGroups = [NSMutableArray new];
    me = [PFUser currentUser];
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


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_jobs.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmployerProfileTableViewCell *cell = (EmployerProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"EmployerProfileTableViewCell"];
    NSInteger row = indexPath.row;
    if (row < arr_jobs.count) {
        PFObject *job = [arr_jobs objectAtIndex:row];
        if (job != nil) {
            UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:1];
            NSString* cat_name = [job objectForKey:FIELD_CATEGORY];
            UIImage* cat_img = [Util getCategoryImage:cat_name];
            imgAvatar.image = cat_img;
            UILabel *lbl1 = (UILabel *)[cell viewWithTag:2];
            lbl1.text = [job objectForKey:FIELD_POSITION];
            UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];
            lbl2.text = [job objectForKey:FIELD_LOCATION];
            UIImageView *vTime = (UILabel *)[cell viewWithTag:4];
            UILabel *lbl4 = (UILabel *)[cell viewWithTag:5];
            vTime.hidden = YES;
            lbl4.hidden = YES;
            if([job[FIELD_STATE] intValue] == STATE_WAITING) {
                NSDate* endDate = (NSDate*)[job objectForKey:FIELD_DATE];
                NSTimeInterval secondsBetween = [endDate timeIntervalSinceNow];     // second unit
                if (secondsBetween > 0) {
                    secondsBetween = secondsBetween / 60 / 60;      //hour unit
                    if (secondsBetween < 24) {
                        int tm = (int)secondsBetween;
                        lbl4.text = [NSString stringWithFormat:@"%d hours", tm];
                    }
                    else if (secondsBetween < 24 * 30) {
                        int tm = (int)(secondsBetween / 24);
                        lbl4.text = [NSString stringWithFormat:@"%d days", tm];
                    }
                    else{
                        int tm = (int)(secondsBetween / 24 / 30);
                        lbl4.text = [NSString stringWithFormat:@"%d months", tm];
                    }
                    vTime.hidden = NO;
                    lbl4.hidden = NO;
                }
                else {
                    lbl4.text = @"";
                }
            }
            lbl1.adjustsFontSizeToFitWidth = YES;
            lbl1.minimumScaleFactor = 0.1;
            lbl2.adjustsFontSizeToFitWidth = YES;
            lbl2.minimumScaleFactor = 0.1;
            
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

//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self performSegueWithIdentifier:@"showEmployerJobDetailVC" sender:Nil];
//}

- (IBAction)onShowEmployerReview:(id)sender {
    ReviewVC *vc = (ReviewVC *)[Util getUIViewControllerFromStoryBoard:@"ReviewVC"];
    vc.arr_reviews = [arr_reviews mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) loadEmployerData {
    if (_ower == nil) return;
    [Util setAvatar:imgAvatar withUser:_ower];
    
    lblName.text = [NSString stringWithFormat:@"%@ %@", _ower[FIELD_FIRST_NAME], _ower[FIELD_LAST_NAME]];
    lblAddress.text = _ower[FIELD_LOCATION];
    vStars.value = 0;
}

- (void) getPreviousJobs {
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query includeKeys:@[FIELD_OWNER, FIELD_BIDDERS, FIELD_WORKER]];
    [query whereKey:FIELD_OWNER equalTo:_ower];
    [query orderByDescending:FIELD_CREATED_AT];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_jobs removeAllObjects];
        arr_jobs = [resultObj mutableCopy];
        isDownloaded = YES;
        [tvJobs reloadData];
    }];
}

- (void) getReviews {
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query includeKeys:@[FIELD_OWNER, FIELD_TO_USER]];
    [query whereKey:FIELD_TO_USER equalTo:_ower];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_reviews removeAllObjects];
        arr_reviews = [resultObj mutableCopy];
        int sum = 0;
        for(PFObject* review in arr_reviews) {
            sum = sum + [review[FIELD_MARK] intValue];
        }
        vStars.value = sum * 1.f / arr_reviews.count;
    }];
}
- (IBAction)onWriteReview:(id)sender {
    WriteReviewVC *vc = (WriteReviewVC *)[Util getUIViewControllerFromStoryBoard:@"WriteReviewVC"];
    vc.ower = self.ower;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onMessage:(id)sender {
    [self getAllGroups];
}


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
            if(([user1.objectId isEqualToString:_ower.objectId] && [user2.objectId isEqualToString:me.objectId]) || ([user2.objectId isEqualToString:_ower.objectId] && [user1.objectId isEqualToString:me.objectId])) {
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
                    vc.toUser = _ower;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
                [Util hideWaitingMark];
            }];
            
        }
        else {
            PFObject* groupObj = [PFObject objectWithClassName:@"Group"];
            NSArray* participants = @[me, _ower];
            [groupObj setObject:participants forKey:FIELD_PARTICIPANTS];
            [Util showWaitingMark];
            [groupObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [Util hideWaitingMark];
                if (error == nil){
                    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
                    vc.toUser = _ower;
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
@end
