//
//  ListOfBiddersVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "ListOfBiddersVC.h"
#import "WorkersProfileVC.h"

@interface ListOfBiddersVC () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *arr_bidders;
    NSMutableArray *arr_prices;
    NSMutableArray *arr_dates;
    __weak IBOutlet UITableView *tv_bidders;
}

@end

@implementation ListOfBiddersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arr_bidders = [NSMutableArray new];
    arr_prices = [NSMutableArray new];
    arr_dates = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBidders) name:kPlacebid object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getBidders];
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
    return arr_bidders.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ListOfBiddersTableViewCell"];
    NSInteger row = indexPath.row;
    UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:1];
    UILabel *lblName = (UILabel *)[cell viewWithTag:2];
    UILabel *lblPrice = (UILabel *)[cell viewWithTag:3];
    UILabel *lblDate = (UILabel *)[cell viewWithTag:4];
    if (row < arr_bidders.count) {
        PFUser* bidder = (PFUser*)arr_bidders[row];
        [Util setAvatar:imgAvatar withUser:bidder];
        lblName.text = [NSString stringWithFormat:@"%@ %@", bidder[FIELD_FIRST_NAME], bidder[FIELD_LAST_NAME]];
        NSNumber* bidPrice = arr_prices[row];
        lblPrice.text = [NSString stringWithFormat:@"$%d", bidPrice.intValue];
        NSDate* bidDate = (NSDate*)arr_dates[row];
        NSTimeInterval diff = [bidDate timeIntervalSinceNow];
        if (diff > 0) {
            if (diff < 1000 * 60 * 60 * 24){
                lblDate.text = [Util convertDate2StringWithFormat:bidDate dateFormat:@"hh:mm a"];
            }
            else if (diff < 1000 * 60 * 60 * 24 * 7) {
                lblDate.text = [Util convertDate2StringWithFormat:bidDate dateFormat:@"EEEE"];
            }
            else {
                lblDate.text = [Util convertDate2StringWithFormat:bidDate dateFormat:@"MMMM dd, yyyy"];
            }
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WorkersProfileVC *vc = (WorkersProfileVC *)[Util getUIViewControllerFromStoryBoard:@"WorkersProfileVC"];
    vc.bidder = arr_bidders[indexPath.row];
    vc.jobObj = _currentJob;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) getBidders {
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query includeKeys:@[FIELD_OWNER, FIELD_BIDDERS, FIELD_WORKER]];
    [query whereKey:@"objectId" equalTo: _currentJob.objectId];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_bidders removeAllObjects];
        [arr_dates removeAllObjects];
        [arr_prices removeAllObjects];
        if (resultObj.count > 0) {
            PFObject* job = (PFObject*)resultObj[0];
            _currentJob = job;
            arr_bidders = [job objectForKey:FIELD_BIDDERS];
            arr_dates = [job objectForKey:FIELD_BIDTIME_LIST];
            arr_prices = [job objectForKey:FIELD_PRICE_LIST];
            
        }
        [tv_bidders reloadData];
        
    }];
}

@end
