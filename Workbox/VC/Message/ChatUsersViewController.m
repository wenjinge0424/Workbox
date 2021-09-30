//
//  ChatUsersViewController.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "ChatUsersViewController.h"
#import "CircleImageView.h"
#import "ChatViewController.h"
#import "ChatDetailsViewController.h"
#import "ChartUsersCell.h"
#import "GroupModel.h"

ChatUsersViewController *_sharedViewController;
@interface ChatUsersViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    IBOutlet UILabel *lblTitle;
    PFUser *me;
    NSMutableArray *arr_AllGroups;
}

@end

@implementation ChatUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    _sharedViewController = self;
    arr_AllGroups =  [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRooms) name:kChatReceiveNotificationUsers object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (ChatUsersViewController *)getInstance{
    return _sharedViewController;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshRooms];
    [self getAllGroups];
}

- (void) refreshRooms {
    
}

- (IBAction)onback:(id)sender {
    _sharedViewController = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNewChat:(id)sender {
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_AllGroups.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *room = [arr_AllGroups objectAtIndex:indexPath.row];
    PFUser* otherUser;
    NSArray* users = room[FIELD_PARTICIPANTS];
    for(PFUser* user in users) {
        if(![user.objectId isEqualToString: me.objectId]) {
            otherUser = user;
            break;
        }
    }
    
    ChartUsersCell *cell = (ChartUsersCell *)[tableView dequeueReusableCellWithIdentifier:@"ChartUsersCell"];
    UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:1];
    imgAvatar.image = [UIImage imageNamed:@"default_profile.png"];
    UILabel *lbl1 = (UILabel *)[cell viewWithTag:2];     //name
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];      // date
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];     // message content
    [Util setAvatar:imgAvatar withUser:otherUser];
    lbl1.text = [NSString stringWithFormat:@"%@ %@", otherUser[FIELD_FIRST_NAME], otherUser[FIELD_LAST_NAME]];
    NSDate* msgDate= room.updatedAt;
    NSDate* now = [NSDate date];
    if(now.year == msgDate.year && now.month == msgDate.month && now.day == msgDate.day) {
        lbl2.text = @"Today";
    }
    else if (now.year == msgDate.year && now.month == msgDate.month && now.day == msgDate.day+1) {
        lbl2.text = @"Yesterday";
    }
    else {
        lbl2.text = [Util convertDate2StringWithFormat:msgDate dateFormat:@"MMMM dd, yyyy"];
    }
    
    PFObject* lastMessageObj = room[FIELD_LAST_MESSAGE];
    lbl3.text = lastMessageObj[@"text"];
    return cell;
    
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *room = [arr_AllGroups objectAtIndex:indexPath.row];
    PFUser *toUser;
    NSArray* users = users = room[FIELD_PARTICIPANTS];
    for(PFUser* user in users) {
        if(![user.objectId isEqualToString: me.objectId]) {
            toUser = user;
            break;
        }
    }
    
    ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
    vc.toUser = toUser;
    vc.room = room;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView  editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
        return;
    }
    PFObject* room = arr_AllGroups[indexPath.row];
    if(room) {
        NSMutableArray* removeList = ((NSArray*)[room objectForKey:FIELD_REMOVELIST]).mutableCopy;
        if(removeList == nil) {
            removeList = [NSMutableArray new];
        }
        if(removeList.count == 0) {
            [self setDeleteMarkOnDB:room];
            [removeList insertObject:me atIndex:0];
            [room setObject:removeList forKey:FIELD_REMOVELIST];
            [room saveInBackground];
        }
        else {
            [self deleteMsgFromDB:room];
            [room deleteInBackground];
        }
        [self getAllGroups];
        
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

- (void) getAllGroups {    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query includeKeys:@[FIELD_PARTICIPANTS, FIELD_REMOVELIST, FIELD_LAST_MESSAGE]];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_AllGroups removeAllObjects];
        for(PFObject* group in resultObj) {
            NSArray* participants = group[FIELD_PARTICIPANTS];
            NSArray* removeList = group[FIELD_REMOVELIST];
            for(PFUser* user in participants) {
                if([user.objectId isEqualToString:me.objectId]) {
                    BOOL isRemovedUser = NO;
                    for(PFUser* removeUser in removeList){
                        if([removeUser.objectId isEqualToString:me.objectId]) {
                            isRemovedUser = YES;
                            break;
                        }
                    }
                    if(isRemovedUser == NO) {
                        [arr_AllGroups addObject:group];
                        break;
                    }
                    
                }
            }
        }
        if(arr_AllGroups.count == 0) {
            [Util showAlertTitle:self title:@"" message:@"No messages available."];
        }
        [tableview reloadData];
        
    }];
}

- (void) setDeleteMarkOnDB : (PFObject*) room{
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:PARSE_HISTORY_ROOM equalTo:room];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [query includeKey:PARSE_HISTORY_SENDER];
    [Util showWaitingMark];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(objects){
            for(PFObject* msgObj in objects) {
                NSMutableArray* removeList = ((NSArray*)[msgObj objectForKey:FIELD_REMOVELIST]).mutableCopy;
                if(removeList == nil) {
                    removeList = [NSMutableArray new];
                }
                [removeList insertObject:me atIndex:0];
                [msgObj setObject:removeList forKey:FIELD_REMOVELIST];
                [msgObj saveInBackground];
            }
        }
        [Util hideWaitingMark];
        [self getAllGroups];
    }];
}


- (void) deleteMsgFromDB : (PFObject*) room {
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:PARSE_HISTORY_ROOM equalTo:room];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [query includeKey:PARSE_HISTORY_SENDER];
    [Util showWaitingMark];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(objects){
            for(PFObject* msgObj in objects) {
                [msgObj deleteInBackground];
            }
        }
        [Util hideWaitingMark];
        [self getAllGroups];
    }];
}

@end

