//
//  ReviewVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "ReviewVC.h"
#import "ReviewTableCellTableViewCell.h"

@interface ReviewVC () <UITableViewDelegate, UITableViewDataSource>{
    __weak IBOutlet UITableView *tv;    
}

@end

@implementation ReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _me = [PFUser currentUser];
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
    if(_arr_reviews) {
        return _arr_reviews.count;
    }
    return 0;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 165;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReviewTableCellTableViewCell *cell = (ReviewTableCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReviewTableCellTableViewCell"];
    HCSStarRatingView *starV = (HCSStarRatingView *)[cell viewWithTag:1];
    UILabel *lbl1 = (UILabel *)[cell viewWithTag:2];     // review
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];        //by design
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];        // lorem
    NSInteger row = indexPath.row;
    if (row < _arr_reviews.count) {
        PFObject *review = [_arr_reviews objectAtIndex:row];
        starV.value = [review[FIELD_MARK] intValue];
        lbl1.text = review[FIELD_HEAD_LINE];
        
        NSDate *reviewDate = (NSDate*)review.updatedAt;
        
        PFUser* owner = (PFUser*)[review objectForKey:FIELD_OWNER_1];
        [owner fetchIfNeeded];
        NSString* firstname = @"";
        NSString* lastname = @"";
        
        if (owner[FIELD_FIRST_NAME] != nil) {
            firstname = owner[FIELD_FIRST_NAME];
        }
        if (owner[FIELD_LAST_NAME] != nil) {
            lastname = owner[FIELD_LAST_NAME];
        }
        lbl2.text = [NSString stringWithFormat:@"by %@ %@ on %@",firstname, lastname, [Util convertDate2StringWithFormat:reviewDate dateFormat:@"MM dd, yyyy"]];
        lbl3.text = review[FIELD_CONTENT];
        
    }
    lbl1.adjustsFontSizeToFitWidth = YES;
    lbl1.minimumScaleFactor = 0.1;
    lbl2.adjustsFontSizeToFitWidth = YES;
    lbl2.minimumScaleFactor = 0.1;
    lbl3.adjustsFontSizeToFitWidth = YES;
    lbl3.minimumScaleFactor = 0.1;
    return cell;
}

- (void) getReviews {
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query includeKeys:@[FIELD_OWNER, FIELD_TO_USER]];
    [query whereKey:FIELD_TO_USER equalTo:_me];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [_arr_reviews removeAllObjects];
        _arr_reviews = [resultObj mutableCopy];
        [tv reloadData];
    }];
}

@end
