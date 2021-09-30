//
//  JobDetailsVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "JobDetailsVC.h"
#import "SuperViewController.h"
#import "EmployerProfileVC.h"
#import "ListOfBiddersVC.h"
#import "SubscriptionVC.h"
@interface JobDetailsVC (){
    __weak IBOutlet UIButton *btnBidLower;
    __weak IBOutlet UILabel *lblCategoryName;
    __weak IBOutlet UIImageView *imgClientAvatar;
    __weak IBOutlet UILabel *lblClientName;
    __weak IBOutlet UILabel *lblJobDesc;
    __weak IBOutlet UILabel *lblClientAddress;
    __weak IBOutlet UILabel *lblTimeLeft;
    __weak IBOutlet UILabel *lblPaymentMethod;
    __weak IBOutlet UILabel *lblLowestBidder;
    __weak IBOutlet UILabel *lblJobDetail;
    int lowestPrice;
    int userType;
}

@end

@implementation JobDetailsVC
@synthesize jobObj;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFUser *me = [PFUser currentUser];
    if (!me[FIELD_USER_TYPE]){
        [self showErrorMsg:LOCALIZATION(@"invalid_user")];
        return;
    }
    userType = [me[FIELD_USER_TYPE] intValue];
    if (userType == TYPE_ADMIN){
        
    } else if (userType == TYPE_USER_HAVE) {
        [btnBidLower setTitle:@"LIST OF BIDDERS" forState:UIControlStateNormal];
    } else if (userType == TYPE_USER_LOOKING){
        [btnBidLower setTitle:@"BID LOWER" forState:UIControlStateNormal];
    }
    lowestPrice = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadJobData) name:kPlacebid object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadJobData];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void) loadJobData {
    if (jobObj == nil) return;
    NSString* cat_name = [jobObj objectForKey:FIELD_CATEGORY];
    UIImage* cat_img = [Util getCategoryImage:cat_name];
    imgClientAvatar.image = cat_img;
    lblCategoryName.text = [jobObj objectForKey:FIELD_CATEGORY];
    lblClientName.text = [NSString stringWithFormat:@"%@ %@", ((PFUser*)[jobObj objectForKey:FIELD_OWNER])[FIELD_FIRST_NAME], ((PFUser*)[jobObj objectForKey:FIELD_OWNER])[FIELD_LAST_NAME]];
    lblJobDesc.text = [jobObj objectForKey:FIELD_POSITION];
    lblClientAddress.text = [jobObj objectForKey:FIELD_LOCATION];
    NSDate* endDate = (NSDate*)[jobObj objectForKey:FIELD_DATE];
    NSTimeInterval secondsBetween = [endDate timeIntervalSinceNow];     // second unit
    if (secondsBetween > 0) {
        secondsBetween = secondsBetween / 60 / 60;      //hour unit
        if (secondsBetween < 24) {
            int tm = (int)secondsBetween;
            lblTimeLeft.text = [NSString stringWithFormat:@"%d hours", tm];
        }
        else if (secondsBetween < 24 * 30) {
            int tm = (int)(secondsBetween / 24);
            lblTimeLeft.text = [NSString stringWithFormat:@"%d days", tm];
        }
        else{
            int tm = (int)(secondsBetween / 24 / 30);
            lblTimeLeft.text = [NSString stringWithFormat:@"%d months", tm];
        }
        if (userType == TYPE_USER_LOOKING){
            btnBidLower.enabled = YES;
            btnBidLower.alpha = 1;
        }
        
    }
    else {
        lblTimeLeft.text = @"Expired";
        if (userType == TYPE_USER_LOOKING){
            btnBidLower.enabled = NO;
            btnBidLower.alpha = 0.5;
        }
        
    }
    
    NSArray* bidCosts = (NSArray*)[jobObj objectForKey:FIELD_PRICE_LIST];
    int iMin = 0;
    int iMinId = 0;
    int counter = 0;
    for(NSNumber* num in bidCosts){
        int iX = num.intValue;
        if (counter == 0){
            iMin = iX;
        }
        else if (iX < iMin) {
            iMin = iX;
            iMinId = counter;
        }
        counter = counter + 1;
    }
    lowestPrice = iMin;
    PFUser* lowestUser = (PFUser*)(((NSArray*)[jobObj objectForKey:FIELD_BIDDERS])[iMinId]);
    if (lowestUser != nil) {
        lblLowestBidder.text = [NSString stringWithFormat:@"$%d - %@ %@",iMin, lowestUser[FIELD_FIRST_NAME], lowestUser[FIELD_LAST_NAME]];
    }
    lblPaymentMethod.text = [jobObj objectForKey:FIELD_PAYMENTMETHOD];
    lblJobDetail.text = [jobObj objectForKey:FIELD_DESCRIPTION];
    
    lblClientName.adjustsFontSizeToFitWidth = YES;
    lblClientName.minimumScaleFactor = 0.1;
    lblJobDesc.adjustsFontSizeToFitWidth = YES;
    lblJobDesc.minimumScaleFactor = 0.1;
    lblClientAddress.adjustsFontSizeToFitWidth = YES;
    lblClientAddress.minimumScaleFactor = 0.1;
    lblTimeLeft.adjustsFontSizeToFitWidth = YES;
    lblTimeLeft.minimumScaleFactor = 0.1;
    lblPaymentMethod.adjustsFontSizeToFitWidth = YES;
    lblPaymentMethod.minimumScaleFactor = 0.1;
    lblJobDetail.adjustsFontSizeToFitWidth = YES;
    lblJobDetail.minimumScaleFactor = 0.1;
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onBidLower:(id)sender {
    PFUser *me = [PFUser currentUser];
    if (!me[FIELD_USER_TYPE]){
        [self showErrorMsg:LOCALIZATION(@"invalid_user")];
        return;
    }
    int type = [me[FIELD_USER_TYPE] intValue];
    if (type == TYPE_ADMIN){
        
    } else if (type == TYPE_USER_HAVE) {
        ListOfBiddersVC *vc = (ListOfBiddersVC *)[Util getUIViewControllerFromStoryBoard:@"ListOfBiddersVC"];
        vc.currentJob = jobObj;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == TYPE_USER_LOOKING){
        [self onBid];
    }
}
- (IBAction)onShowEmplyerProfile:(id)sender {
    PFUser *me = [PFUser currentUser];
    if (!me[FIELD_USER_TYPE]){
        [self showErrorMsg:LOCALIZATION(@"invalid_user")];
        return;
    }
    int type = [me[FIELD_USER_TYPE] intValue];
    if (type == TYPE_ADMIN){
    } else if (type == TYPE_USER_HAVE) {
    } else if (type == TYPE_USER_LOOKING){
        EmployerProfileVC *vc = (EmployerProfileVC *)[Util getUIViewControllerFromStoryBoard:@"EmployerProfileVC"];
        vc.ower = (PFUser*)[jobObj objectForKey:FIELD_OWNER];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) showErrorMsg:(NSString *) msg {
    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:msg];
}

- (void) showNetworkErr {
    [self showErrorMsg:LOCALIZATION(@"network_error")];
}

- (void) onBid {
    PFUser *me = [PFUser currentUser];
    NSDate* paidDate = me[FIELD_PAID_AT];
    if(paidDate == nil) {
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setMonth:-1]; // note that I'm setting it to -1
        NSDate *payDay = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        NSLog(@"%@", payDay);
        [me setObject:payDay forKey:FIELD_PAID_AT];
        [me saveInBackground];
    }
    NSDate* now = [NSDate date];
    NSDate* jobExpDate = jobObj[FIELD_DATE];
    if([now compare:jobExpDate] == NSOrderedDescending) {
        return;
    }
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *subscriptionExpDate = [cal dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:jobExpDate options:0];
    NSDate *cAferOneYearFromPaidAt = [cal dateByAddingUnit:NSCalendarUnitYear value:1 toDate:jobExpDate options:0];
    if([subscriptionExpDate compare:now] != NSOrderedDescending) {
        NSArray* inviteIds = me[FIELD_INVITED_FACEBOOK_FRIENDS_ID];
        if(inviteIds == nil) {
            inviteIds = [NSArray new];
        }
        if(inviteIds.count >= 100 && [now compare:cAferOneYearFromPaidAt] != NSOrderedDescending) {
            [me setObject:[NSNumber numberWithInteger:39999]  forKey:FIELD_BID_COUNT_PERMONTH];
        }
        else {
            [me setObject:[NSNumber numberWithInteger:5]  forKey:FIELD_BID_COUNT_PERMONTH];
            [me setObject:now forKey:FIELD_PAID_AT];
        }
        [me setObject:[NSNumber numberWithInteger:0]  forKey:FIELD_CUR_BID_COUNT];
        [me setObject:[NSNumber numberWithInteger:TYPE_SUB_FREE]  forKey:FIELD_SUBSCRIPTION];
        [me saveInBackground];
    }
    
    int curBidCnt = ((NSNumber*)[me objectForKey:FIELD_CUR_BID_COUNT]).intValue;
    int bidCntPerMonth = ((NSNumber*)[me objectForKey:FIELD_BID_COUNT_PERMONTH]).intValue;
    if (curBidCnt >= bidCntPerMonth) {
        int subType = [me[FIELD_SUBSCRIPTION] intValue];
        if(subType == TYPE_SUB_FREE) {
            NSString *msg = LOCALIZATION(@"You’ve exceeded your allocated jobs. Upgrade your subscription to get more jobs.");
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:LOCALIZATION(@"Cancel") actionBlock:^(void) {
            }];
            [alert addButton:LOCALIZATION(@"Okay") actionBlock:^(void) {
                SubscriptionVC *vc = (SubscriptionVC *)[Util getUIViewControllerFromStoryBoard:@"SubscriptionVC"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [alert showError:LOCALIZATION(@"Subscription Upgrade?") subTitle:msg closeButtonTitle:nil duration:0.0f];
            return;
        }
        else {
            [Util showAlertTitle:self title:@"Out of Bid" message:@"Out of Bid. You can't bid now."];
            return;
        }
        
    }
    else {
        NSArray* bidders = (NSArray*)[jobObj objectForKey:FIELD_BIDDERS];
        for(PFUser* bidder in bidders){
            if([bidder.objectId isEqualToString:me.objectId]){
                
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                alert.shouldDismissOnTapOutside = YES;
                alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
                alert.customViewColor = MAIN_COLOR;
                
                [alert addButton:@"YES" actionBlock:^{
                    NSInteger myIndex;
                    myIndex = [bidders indexOfObject:bidder];
                    if(myIndex < 0) {
                        return;
                    }
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    alert.customViewColor = MAIN_COLOR;
                    UITextField *tf_time = [alert addTextField:@""];
                    [tf_time setKeyboardType:UIKeyboardTypeNumberPad];
                    
                    [Util setBorderView:tf_time color:MAIN_COLOR width:1.f];
                    alert.horizontalButtons = YES;
                    [alert addButton:@"Confirm" validationBlock:^BOOL{
                        if ([tf_time.text isEqualToString:@""]){
                            [Util showAlertTitle:self title:STRING_ERROR message:@"Please enter amount."];
                            return NO;
                        }else{
                            return YES;
                        }
                    } actionBlock:^{
                        if ([tf_time.text isEqualToString:@""]){
                            [Util showAlertTitle:self title:STRING_ERROR message:@"Please enter amount."];
                        }
                        else {
                            if (bidders.count > 0) {
                                int amount = tf_time.text.intValue;
                                if (amount < lowestPrice) {
                                    NSMutableArray* newBiders = bidders.mutableCopy;
                                    [newBiders removeObjectAtIndex:myIndex];
                                    [newBiders insertObject:me atIndex:0];
                                    [jobObj setObject:newBiders forKey:FIELD_BIDDERS];
                                    NSMutableArray* newBidPriceList = ((NSArray*)[jobObj objectForKey:FIELD_PRICE_LIST]).mutableCopy;
                                    [newBidPriceList removeObjectAtIndex:myIndex];
                                    [newBidPriceList insertObject:[NSNumber numberWithInt:amount] atIndex:0];
                                    [jobObj setObject:newBidPriceList forKey:FIELD_PRICE_LIST];
                                    int newBidCnt = curBidCnt + 1;
                                    [me setObject:[NSNumber numberWithInt:newBidCnt] forKey:FIELD_CUR_BID_COUNT];
                                    NSMutableArray* bidTimeList = ((NSArray*)[jobObj objectForKey:FIELD_BIDTIME_LIST]).mutableCopy;
                                    if(bidTimeList == nil) {
                                        bidTimeList = [NSMutableArray new];
                                    }
                                    [bidTimeList removeObjectAtIndex:myIndex];
                                    [bidTimeList insertObject:[NSDate date] atIndex:0];
                                    [jobObj setObject:bidTimeList forKey:FIELD_BIDTIME_LIST];
                                    [me saveInBackground];
                                    [jobObj saveInBackground];
                                    PFUser* jobOwner = [jobObj objectForKey:FIELD_OWNER];
                                    if(jobOwner) {
                                        [jobOwner fetchIfNeeded];
                                        PFUser* me = [PFUser currentUser];
                                        NSString* myName = [NSString stringWithFormat:@"%@ %@ placed a bid.", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
                                        [Util sendPushNotification:TYPE_PLACE_BID obecjtId:jobObj.objectId receiver:jobOwner.username message:myName senderId:me.objectId];
                                    }
                                    
                                    [self onBack:nil];
                                    
                                }
                                else {
                                    [Util showAlertTitle:self title:STRING_ERROR message:@"You needs to have a lower bid than from the existing bidder to get the job."];
                                }
                            }
                            else {
                                int amount = tf_time.text.intValue;
                                NSMutableArray* newBiders = [NSMutableArray new];
                                [newBiders insertObject:me atIndex:0];
                                [jobObj setObject:newBiders forKey:FIELD_BIDDERS];
                                NSMutableArray* newBidPriceList = [NSMutableArray new];
                                [newBidPriceList insertObject:[NSNumber numberWithInt:amount] atIndex:0];
                                [jobObj setObject:newBidPriceList forKey:FIELD_PRICE_LIST];
                                int newBidCnt = curBidCnt + 1;
                                [me setObject:[NSNumber numberWithInt:newBidCnt] forKey:FIELD_CUR_BID_COUNT];
                                NSMutableArray* bidTimeList = [NSMutableArray new];
                                [bidTimeList insertObject:[NSDate date] atIndex:0];
                                [jobObj setObject:bidTimeList forKey:FIELD_BIDTIME_LIST];
                                [me saveInBackground];
                                [jobObj saveInBackground];
                                PFUser* jobOwner = [jobObj objectForKey:FIELD_OWNER];
                                if(jobOwner) {
                                    [jobOwner fetchIfNeeded];
                                    PFUser* me = [PFUser currentUser];
                                    NSString* myName = [NSString stringWithFormat:@"%@ %@ placed a bid.", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
                                    [Util sendPushNotification:TYPE_PLACE_BID obecjtId:jobObj.objectId receiver:jobOwner.username message:myName senderId:me.objectId];
                                }
                                [self onBack:nil];
                            }
                        }
                    }];
                    [alert showEdit:self title:@"" subTitle:@"Enter your bid amount" closeButtonTitle:@"Cancel" duration:0.0f];
                    
                }];
                
                [alert showInfo:@"Confirmation" subTitle:@"Are you sure you want to edit your previous bid?" closeButtonTitle:@"NO" duration:0.f];
                return;
            }
        }
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.customViewColor = MAIN_COLOR;
        UITextField *tf_time = [alert addTextField:@""];
        [tf_time setKeyboardType:UIKeyboardTypeNumberPad];
        
        [Util setBorderView:tf_time color:MAIN_COLOR width:1.f];
        alert.horizontalButtons = YES;
        [alert addButton:@"Confirm" validationBlock:^BOOL{
            if ([tf_time.text isEqualToString:@""]){
                [Util showAlertTitle:self title:STRING_ERROR message:@"Please enter amount."];
                return NO;
            }else{
                return YES;
            }
        } actionBlock:^{
            if ([tf_time.text isEqualToString:@""]){
                [Util showAlertTitle:self title:STRING_ERROR message:@"Please enter amount."];
            }
            else {
                if (bidders.count > 0) {
                    int amount = tf_time.text.intValue;
                    if (amount < lowestPrice) {
                        NSMutableArray* newBiders = bidders.mutableCopy;
                        [newBiders insertObject:me atIndex:0];
                        [jobObj setObject:newBiders forKey:FIELD_BIDDERS];
                        NSMutableArray* newBidPriceList = ((NSArray*)[jobObj objectForKey:FIELD_PRICE_LIST]).mutableCopy;
                        [newBidPriceList insertObject:[NSNumber numberWithInt:amount] atIndex:0];
                        [jobObj setObject:newBidPriceList forKey:FIELD_PRICE_LIST];
                        int newBidCnt = curBidCnt + 1;
                        [me setObject:[NSNumber numberWithInt:newBidCnt] forKey:FIELD_CUR_BID_COUNT];
                        NSMutableArray* bidTimeList = ((NSArray*)[jobObj objectForKey:FIELD_BIDTIME_LIST]).mutableCopy;
                        if(bidTimeList == nil) {
                            bidTimeList = [NSMutableArray new];
                        }
                        [bidTimeList insertObject:[NSDate date] atIndex:0];
                        [jobObj setObject:bidTimeList forKey:FIELD_BIDTIME_LIST];
                        [me saveInBackground];
                        [jobObj saveInBackground];
                        PFUser* jobOwner = [jobObj objectForKey:FIELD_OWNER];
                        if(jobOwner) {
                            [jobOwner fetchIfNeeded];
                            PFUser* me = [PFUser currentUser];
                            NSString* myName = [NSString stringWithFormat:@"%@ %@ placed a bid.", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
                            [Util sendPushNotification:TYPE_PLACE_BID obecjtId:jobObj.objectId receiver:jobOwner.username message:myName senderId:me.objectId];
                        }
                        
                        [self onBack:nil];
                        
                    }
                    else {
                        [Util showAlertTitle:self title:STRING_ERROR message:@"You needs to have a lower bid than from the existing bidder to get the job."];
                    }
                }
                else {
                    int amount = tf_time.text.intValue;
                    NSMutableArray* newBiders = [NSMutableArray new];
                    [newBiders insertObject:me atIndex:0];
                    [jobObj setObject:newBiders forKey:FIELD_BIDDERS];
                    NSMutableArray* newBidPriceList = [NSMutableArray new];
                    [newBidPriceList insertObject:[NSNumber numberWithInt:amount] atIndex:0];
                    [jobObj setObject:newBidPriceList forKey:FIELD_PRICE_LIST];
                    int newBidCnt = curBidCnt + 1;
                    [me setObject:[NSNumber numberWithInt:newBidCnt] forKey:FIELD_CUR_BID_COUNT];
                    NSMutableArray* bidTimeList = [NSMutableArray new];
                    [bidTimeList insertObject:[NSDate date] atIndex:0];
                    [jobObj setObject:bidTimeList forKey:FIELD_BIDTIME_LIST];
                    [me saveInBackground];
                    [jobObj saveInBackground];
                    PFUser* jobOwner = [jobObj objectForKey:FIELD_OWNER];
                    if(jobOwner) {
                        [jobOwner fetchIfNeeded];
                        PFUser* me = [PFUser currentUser];
                        NSString* myName = [NSString stringWithFormat:@"%@ %@ placed a bid.", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
                        [Util sendPushNotification:TYPE_PLACE_BID obecjtId:jobObj.objectId receiver:jobOwner.username message:myName senderId:me.objectId];
                    }
                    [self onBack:nil];
                }
            }
        }];
        [alert showEdit:self title:@"" subTitle:@"Enter your bid amount" closeButtonTitle:@"Cancel" duration:0.0f];
    }
}

@end
