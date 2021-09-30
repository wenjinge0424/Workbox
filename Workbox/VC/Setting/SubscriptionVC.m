//
//  SubscriptionVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "SubscriptionVC.h"

@interface SubscriptionVC (){
    __weak IBOutlet UIButton *btnFree;
    __weak IBOutlet UIButton *btnTen;
    __weak IBOutlet UIButton *btnTwenty;
    __weak IBOutlet UIButton *btnThirty;
    __weak IBOutlet UIButton *btnCurrentPlan;
    PFObject* cardInfo;
    PFUser* me;
    int payMoney;
}

@end

@implementation SubscriptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    btnFree.titleLabel.adjustsFontSizeToFitWidth = YES;
    btnFree.titleLabel.minimumScaleFactor = 0.1;
    btnTen.titleLabel.adjustsFontSizeToFitWidth = YES;
    btnTen.titleLabel.minimumScaleFactor = 0.1;
    btnTwenty.titleLabel.adjustsFontSizeToFitWidth = YES;
    btnTwenty.titleLabel.minimumScaleFactor = 0.1;
    btnThirty.titleLabel.adjustsFontSizeToFitWidth = YES;
    btnThirty.titleLabel.minimumScaleFactor = 0.1;
    me = [PFUser currentUser];
    [self initCurrentPlanLabel];
    cardInfo = nil;
    payMoney = 0;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getCardInfo];
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
- (IBAction)onFree:(id)sender {
}

- (IBAction)onTen:(id)sender {
    int subType = [me[FIELD_SUBSCRIPTION] intValue];
    if(subType == TYPE_SUB_10) {
        [Util showAlertTitle:self title:@"" message:@"You have $10 subscription already"];
        return;
    }
    if([self checkCardInfo] == NO){
        return;
    }
    NSString *msg = LOCALIZATION(@"$10/Month(Up to 10 Jobs)");
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = [UIColor colorWithRed:211/255.0 green:17/255.0 blue:58/255.0 alpha:1.0];
    alert.horizontalButtons = YES;
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert addButton:@"Confirm" actionBlock:^(void) {
        payMoney = 10;
        [self onPayMoney];
    }];
    [alert showInfo:msg subTitle:LOCALIZATION(@"Will you allow Workbox to\ncharge $10 to your existing\nPayment Information?") closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onTwenty:(id)sender {
    int subType = [me[FIELD_SUBSCRIPTION] intValue];
    if(subType == TYPE_SUB_20) {
        [Util showAlertTitle:self title:@"" message:@"You have $20 subscription already"];
        return;
    }
    if([self checkCardInfo] == NO){
        return;
    }
    NSString *msg = LOCALIZATION(@"$20/Month(Up to 20 Jobs)");
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = [UIColor colorWithRed:211/255.0 green:17/255.0 blue:58/255.0 alpha:1.0];
    alert.horizontalButtons = YES;
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert addButton:@"Confirm" actionBlock:^(void) {
        payMoney = 20;
        [self onPayMoney];
    }];
    [alert showInfo:msg subTitle:LOCALIZATION(@"Will you allow Workbox to\ncharge $20 to your existing\nPayment Information?") closeButtonTitle:nil duration:0.0f];
    
}
- (IBAction)onThirty:(id)sender {
    int subType = [me[FIELD_SUBSCRIPTION] intValue];
    if(subType == TYPE_SUB_25) {
        [Util showAlertTitle:self title:@"" message:@"You have $25 subscription already"];
        return;
    }
    if([self checkCardInfo] == NO){
        return;
    }
    NSString *msg = LOCALIZATION(@"$25/Month(Unlimited Jobs)");
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = [UIColor colorWithRed:211/255.0 green:17/255.0 blue:58/255.0 alpha:1.0];
    alert.horizontalButtons = YES;
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert addButton:@"Confirm" actionBlock:^(void) {
        payMoney = 25;
        [self onPayMoney];
    }];
    [alert showInfo:msg subTitle:LOCALIZATION(@"Will you allow Workbox to\ncharge $25 to your existing\nPayment Information?") closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) getCardInfo {
    PFQuery *query = [PFQuery queryWithClassName:@"CardInfo"];
    [query includeKeys:@[FIELD_OWNER_1]];
    [query whereKey:FIELD_OWNER_1 equalTo:me];
    [query whereKey:FIELD_STATE equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        if(resultObj.count > 0){
            cardInfo = resultObj[0];
        }
        else {
            cardInfo = nil;
        }
    }];
}

- (BOOL) checkCardInfo {
    if(cardInfo == nil) {
        [Util showAlertTitle:self title:@"" message:@"You don't have CardNumber activated."];
        return NO;
    }
    else {
        return YES;
    }
}

- (void) onPayMoney {
    int subtype = 0;
    int bidCount = 0;
    if(payMoney == 10) {
        subtype = TYPE_SUB_10;
        bidCount = 10;
    }
    else if(payMoney == 20) {
        subtype = TYPE_SUB_20;
        bidCount = 20;
    }
    else if(payMoney == 25) {
        subtype = TYPE_SUB_25;
        bidCount = 1000;
    }
    [me setObject:[NSDate date] forKey:FIELD_PAID_AT];
    [me setObject:[NSNumber numberWithInteger:subtype] forKey:FIELD_SUBSCRIPTION];
    [me setObject:[NSNumber numberWithInteger:bidCount] forKey:FIELD_CUR_BID_COUNT];
    [Util showWaitingMark];
    [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [Util hideWaitingMark];
        if(succeeded) {
            [self initCurrentPlanLabel];
        }
    }];
}

- (void) initCurrentPlanLabel {
    me = [PFUser currentUser];
    int subType = [me[FIELD_SUBSCRIPTION] intValue];
    if(subType == TYPE_SUB_FREE) {
        [btnCurrentPlan setTitle:@"Free Subscription (Up to 5 jobs are free)" forState:UIControlStateNormal];
    }
    else if(subType == TYPE_SUB_10) {
        [btnCurrentPlan setTitle:@"$10 per Month (Up to 10 jobs)" forState:UIControlStateNormal];
    }
    else if(subType == TYPE_SUB_20) {
        [btnCurrentPlan setTitle:@"$20 per Month (Up to 20 jobs)" forState:UIControlStateNormal];
    }
    else if(subType == TYPE_SUB_25) {
        [btnCurrentPlan setTitle:@"$25 per Month (Unlimited Jobs)" forState:UIControlStateNormal];
    }
}
@end
