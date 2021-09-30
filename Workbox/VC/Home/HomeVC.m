//
//  HomeVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "HomeVC.h"
#import "HomeTableViewCell.h"
#import "JobDetailsVC.h"
#import "CellDelegate.h"

@interface HomeVC () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *arr_jobs;
    BOOL isDownloaded;
    int sortType;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tvJobs;
@property (weak, nonatomic) IBOutlet UIView *vSortDropdown;
@property (weak, nonatomic) IBOutlet UIButton *btnSort;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arr_jobs = [NSMutableArray new];
    sortType = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _vSortDropdown.hidden = YES;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString* curCategory = [defaults objectForKey:CURRENT_CATEGORY];
    if (curCategory == nil) {
        return;
    }
    _lblCategory.text = curCategory;
    [self getJobs:curCategory];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_jobs.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = (HomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
    cell.delegate = self;
    cell.cellIndex = indexPath.row; // Set indexpath if its a grouped table.
    NSInteger row = indexPath.row;
    if (row < arr_jobs.count) {
        PFObject *job = [arr_jobs objectAtIndex:row];
        if (job != nil) {
            UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:1];
            NSString* cat_name = [job objectForKey:FIELD_CATEGORY];
            UIImage* cat_img = [Util getCategoryImage:cat_name];
            imgAvatar.image = cat_img;
            
            UILabel *lbl1 = (UILabel *)[cell viewWithTag:2];
            lbl1.text = [NSString stringWithFormat:@"%@ %@", ((PFUser*)[job objectForKey:FIELD_OWNER])[FIELD_FIRST_NAME], ((PFUser*)[job objectForKey:FIELD_OWNER])[FIELD_LAST_NAME]];
            UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];
            lbl2.text = [job objectForKey:FIELD_POSITION];
            UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];
            lbl3.text = [job objectForKey:FIELD_LOCATION];
            UILabel *lbl4 = (UILabel *)[cell viewWithTag:5];
            UIImageView *eye_img = (UIImageView *)[cell viewWithTag:6];
            NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
            NSArray* lookingJobList = (NSArray*)[[ud objectForKey:UD_LOOKING_JOBS] mutableCopy];
            eye_img.image = [UIImage imageNamed:@"ic_see_no.png"];
            if(lookingJobList) {
                if([lookingJobList containsObject:job.objectId]) {
                    eye_img.image = [UIImage imageNamed:@"ic_see.png"];
                }
            }
            
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
            }
            else {
                lbl4.text = @"";
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


- (IBAction)onTapCategory:(id)sender {
    [self performSegueWithIdentifier:@"showCategoryVC" sender:Nil];
}

- (void) getJobs:(NSString*) category {
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query includeKeys:@[FIELD_OWNER, FIELD_BIDDERS, FIELD_WORKER]];
    [query whereKey:FIELD_STATE equalTo:[NSNumber numberWithInteger:STATE_WAITING] ];
    [query whereKey:FIELD_CATEGORY equalTo:category];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_jobs removeAllObjects];
        arr_jobs = [resultObj mutableCopy];
        isDownloaded = YES;
        [self sortJob];
        [_tvJobs reloadData];
    }];
}

- (void) getAllJobs {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString* curCategory = [defaults objectForKey:CURRENT_CATEGORY];
    if (curCategory == nil) {
        return;
    }
    [self getJobs:curCategory];
    
}
- (IBAction)onSortbyTime:(id)sender {
    sortType = 1;
    [self sortJobByTime];
}

- (void) sortJobByTime {
    arr_jobs = [[arr_jobs sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        PFObject* dataA = (PFObject*)a;
        PFObject* dataB = (PFObject*)b;
        NSDate* date1 = dataA.updatedAt;
        NSDate* date2 = dataB.updatedAt;
        
        return [date1 compare:date2] != NSOrderedDescending;
        
    }] mutableCopy];
    _vSortDropdown.hidden = YES;
    [_tvJobs reloadData];
}

- (void) sortJobByLocation {
    PFUser *me = [PFUser currentUser];
    arr_jobs = [[arr_jobs sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        double left_lat = [[(NSDictionary*)a objectForKey:@"latitude"] doubleValue];
        double left_long = [[(NSDictionary*)a objectForKey:@"longitude"] doubleValue];
        double right_lat = [[(NSDictionary*)b objectForKey:@"latitude"] doubleValue];
        double right_long = [[(NSDictionary*)b objectForKey:@"longitude"] doubleValue];
        CLLocation* location1 = [[CLLocation alloc] initWithLatitude: left_lat longitude: left_long];
        CLLocation* location2 = [[CLLocation alloc] initWithLatitude: right_lat longitude: right_long];
        PFGeoPoint* curPos = (PFGeoPoint*)[me objectForKey:FIELD_GEOPOINT];
        CLLocation* curLocation = [[CLLocation alloc] initWithLatitude: curPos.latitude longitude: curPos.longitude];
        double dist_left = [curLocation distanceFromLocation: location1];
        double dist_right = [curLocation distanceFromLocation: location2];
        return dist_right > dist_left;
    }] mutableCopy];
    _vSortDropdown.hidden = YES;
    [_tvJobs reloadData];
}
- (IBAction)onSortByLocation:(id)sender {
    sortType = 2;
    [self sortJobByLocation];
    
}
- (IBAction)onTapSort:(id)sender {
    _vSortDropdown.hidden = !_vSortDropdown.isHidden;
}

- (void) sortJob {
    if(sortType == 1) {
        [self sortJobByTime];
    }
    else {
        [self sortJobByLocation];
    }
}

- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withData:(id)data
{
    // Do additional actions as required.
    //    NSLog(@"Cell at Index: %d clicked.\n Data received : %@", cellIndex, data);
    PFObject* deleteJob = arr_jobs[cellIndex];
    if(deleteJob) {
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSArray* noti_list = (NSArray*)[[ud objectForKey:UD_LOOKING_JOBS] mutableCopy];
        NSMutableArray* new_noti_list;
        UIImageView* eyeV = (UIImageView*)data;
        if(noti_list) {
            new_noti_list = [noti_list mutableCopy];
        }
        else {
            new_noti_list = [[NSMutableArray alloc] init];
        }
        if([new_noti_list containsObject:deleteJob.objectId]) {
            [new_noti_list removeObject:deleteJob.objectId];
            //remove local notification
            UIApplication *app = [UIApplication sharedApplication];
            NSArray *eventArray = [app scheduledLocalNotifications];
            for (int i=0; i<[eventArray count]; i++)
            {
                UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
                NSDictionary *userInfoCurrent = oneEvent.userInfo;
                NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"uid"]];
                if ([uid isEqualToString:deleteJob.objectId])
                {
                    //Cancelling local notification
                    [app cancelLocalNotification:oneEvent];
                    break;
                }
            }
            if(eyeV) {
                eyeV.image = [UIImage imageNamed:@"ic_see_no.png"];
                
            }
            
        }
        else {
            [new_noti_list addObject:deleteJob.objectId];
            //register local notification
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            NSDate* fireDate = [deleteJob[FIELD_DATE] dateByAddingHours:-1];
            
            [localNotif setFireDate:fireDate];
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            NSLog(@"fireDate %@", localNotif.fireDate);
            NSLog(@"datepicker %@", fireDate);
            
            [localNotif setRepeatInterval:0];
            localNotif.alertBody = @"Job will be expired after 1 hour";
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.alertAction = @"...";
            
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      deleteJob.objectId, @"uid",
                                      nil];
            localNotif.userInfo = userInfo;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
            
            if(eyeV) {
                eyeV.image = [UIImage imageNamed:@"ic_see.png"];
            }
        }
        [ud setObject:new_noti_list forKey:UD_LOOKING_JOBS];
        
    }
}

@end
