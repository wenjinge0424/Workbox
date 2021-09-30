//
//  AdminUsers.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AdminUsers.h"
#import "AdminBanUserVC.h"

@interface AdminUsers () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    __weak IBOutlet UITableView *usersTv;
    __weak IBOutlet UIButton *btnAllUsers;
    __weak IBOutlet UIButton *btnBannedUsers;
    NSMutableArray *arr_allUsers;
    NSMutableArray *arr_bannedUsers;
    NSMutableArray *arr_res;
    BOOL isAllUsers;
}

@end

@implementation AdminUsers

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    btnAllUsers.backgroundColor = [UIColor colorWithRed:0/255.f green:26/255.f blue:61/255.f alpha:1.f];
    btnBannedUsers.backgroundColor = [UIColor lightGrayColor];
    
    isAllUsers = YES;
    [btnAllUsers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBannedUsers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(isAllUsers) {
        [self getAllUsers];
    }
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
- (IBAction)onAllUsers:(id)sender {
    if(isAllUsers) {
        return;
    }
    isAllUsers = YES;
    btnAllUsers.backgroundColor = [UIColor colorWithRed:0/255.f green:26/255.f blue:61/255.f alpha:1.f];
    btnBannedUsers.backgroundColor = [UIColor lightGrayColor];
    
    [btnAllUsers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBannedUsers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self getAllUsers];
    
}
- (IBAction)onBannedUsers:(id)sender {
    if(!isAllUsers) {
        return;
    }
    isAllUsers = NO;
    btnBannedUsers.backgroundColor = [UIColor colorWithRed:0/255.f green:26/255.f blue:61/255.f alpha:1.f];
    btnAllUsers.backgroundColor = [UIColor lightGrayColor];
    [btnBannedUsers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnAllUsers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self getBannedUsers];
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_res.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AdminUserCell"];
    UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:1];
    UILabel *lbl1 = (UILabel *)[cell viewWithTag:2];
    NSInteger row = indexPath.row;
    if (row < arr_res.count) {
        PFUser* user = arr_res[row];
        [user fetchIfNeeded];
        [Util setAvatar:imgAvatar withUser:user];
        lbl1.text = [NSString stringWithFormat:@"%@ %@", user[FIELD_FIRST_NAME], user[FIELD_LAST_NAME]];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AdminBanUserVC *vc = (AdminBanUserVC *)[Util getUIViewControllerFromStoryBoard:@"AdminBanUserVC"];
    vc.user = arr_res[indexPath.row];
    vc.isBannedUser = !isAllUsers;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) getAllUsers {
    PFQuery *query = [PFUser query];
    [query whereKey:FIELD_IS_BANNED equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_allUsers removeAllObjects];
        arr_allUsers = [resultObj mutableCopy];
        arr_res = [arr_allUsers mutableCopy];
        [usersTv reloadData];
    }];
}

- (void) getBannedUsers {
    PFQuery *query = [PFUser query];
    [query whereKey:FIELD_IS_BANNED equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_bannedUsers removeAllObjects];
        arr_bannedUsers = [resultObj mutableCopy];
        arr_res = [arr_bannedUsers mutableCopy];
        [usersTv reloadData];
    }];
}



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
    if(isAllUsers) {
        arr_res = [arr_allUsers mutableCopy];
    }
    else {
        arr_res = [arr_bannedUsers mutableCopy];
    }
    [usersTv reloadData];
}

-(void)searchTerm : (NSString*)searchText
{
    if (searchText == nil) return;
    arr_res = @[];
    if(isAllUsers) {
        NSPredicate *predicate_firstName = [NSPredicate predicateWithFormat:@"self.firstName contains[c] %@", searchText];
        NSPredicate *predicate_lastName = [NSPredicate predicateWithFormat:@"self.lastName contains[c] %@", searchText];
        NSPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate_firstName, predicate_lastName]];
        arr_res = [arr_allUsers filteredArrayUsingPredicate:orPredicate];
    }
    else {
        NSPredicate *predicate_firstName = [NSPredicate predicateWithFormat:@"self.firstName contains[c] %@", searchText];
        NSPredicate *predicate_lastName = [NSPredicate predicateWithFormat:@"self.lastName contains[c] %@", searchText];
        NSPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate_firstName, predicate_lastName]];
        arr_res = [arr_bannedUsers filteredArrayUsingPredicate:orPredicate];
    }
    [usersTv reloadData];
}

@end
