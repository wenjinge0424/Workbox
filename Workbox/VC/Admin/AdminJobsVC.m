//
//  AdminJobsVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AdminJobsVC.h"
#import "AdminAddWorkVC.h"

@interface AdminJobsVC ()<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *arr_allJobs;
    NSMutableArray *arr_res;
}
@property (weak, nonatomic) IBOutlet UITableView *tvJobs;

@end

@implementation AdminJobsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshJobs) name:kJobApproved object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getJobs];
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
    return arr_res.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AdminJobsCell"];
    UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:1];
    UILabel *lbl1 = (UILabel *)[cell viewWithTag:2];
    NSInteger row = indexPath.row;
    if (row < arr_res.count) {
        PFObject* job = arr_res[row];
        PFUser* user = job[FIELD_OWNER];
        [user fetchIfNeeded];
        [Util setAvatar:imgAvatar withUser:user];
        lbl1.text = [NSString stringWithFormat:@"%@ %@", user[FIELD_FIRST_NAME], user[FIELD_LAST_NAME]];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AdminAddWorkVC *vc = (AdminAddWorkVC *)[Util getUIViewControllerFromStoryBoard:@"AdminAddWorkVC"];
    vc.jobObj = arr_res[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) refreshJobs {
    [self getJobs];
}

- (void) getJobs {
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query includeKeys:@[FIELD_OWNER]];
    [query whereKey:FIELD_STATE equalTo:[NSNumber numberWithInteger:STATE_READY] ];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_allJobs removeAllObjects];
        arr_allJobs = [resultObj mutableCopy];
        arr_res = [arr_allJobs mutableCopy];
        [_tvJobs reloadData];
    }];
}

//----------------
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //Remove all objects first.
    [self searchTerm:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
    [self showAllData];// to show all data
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [searchBar setShowsCancelButton:NO];
    [searchBar resignFirstResponder];
    [self searchTerm:searchBar.text];
}

-(void)showAllData {
    //load all data in _tableViewDataSourceArray, and reload table
    arr_res = [arr_allJobs mutableCopy];
    [_tvJobs reloadData];
}

-(void)searchTerm : (NSString*)searchText
{
    
}


@end
