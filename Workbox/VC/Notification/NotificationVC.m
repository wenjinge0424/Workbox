//
//  NotificationVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "NotificationVC.h"
#import "NotificationCell.h"
#import "ReviewVC.h"
#import "ListOfBiddersVC.h"
#import "ChatViewController.h"

@interface NotificationVC () <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UILabel *lblNoActivity;
    __weak IBOutlet UITableView *tv;
    NSMutableArray* noti_list;
    PFUser* me;
}

@end

@implementation NotificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    [lblNoActivity setHidden:YES];
    noti_list = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadNotifications];
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
    return noti_list.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:1];
    UILabel *lbl1 = (UILabel *)[cell viewWithTag:2];     // review
    NSDictionary* notiData = noti_list[indexPath.row];
    if(notiData) {
        int noti_type = [notiData[@"type"] intValue];
        NSString* senderId = notiData[@"senderId"];
        NSString* senderName = notiData[@"message"];
        NSString* msg = @"";
        if(noti_type == TYPE_REVIEW_POST) {
            msg = [NSString stringWithFormat:@"You receive a review from %@", senderName];
        }
        else if (noti_type == TYPE_PLACE_BID) {
            msg = [NSString stringWithFormat:@"%@", senderName];
        }
        else if (noti_type == TYPE_CHAT) {
            msg = [NSString stringWithFormat:@"%@", senderName];
        }
        lbl1.text = msg;
        [self loadAvatarFromName:senderId imgAvatar:imgAvatar];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* notiData = noti_list[indexPath.row];
    if(notiData) {
        int noti_type = [notiData[@"type"] intValue];
        NSString* objectId = notiData[@"objectId"];
        if(noti_type == TYPE_REVIEW_POST) {
            ReviewVC *vc = (ReviewVC *)[Util getUIViewControllerFromStoryBoard:@"ReviewVC"];
            vc.me = me;
            [vc getReviews];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        else if (noti_type == TYPE_PLACE_BID) {
            [self gotoListOfBiddersVC:objectId];
        }
        else if (noti_type == TYPE_CHAT) {
            [self gotoChatVC:objectId];
        }
    }
}

- (void) reloadTableView {
    
}

- (void) loadNotifications {
    [noti_list removeAllObjects];
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSArray* all_noti_list = (NSMutableArray*)[ud objectForKey:UD_NOTIFICATIONS];
    for(NSDictionary* notiData in all_noti_list) {
        int noti_type = [notiData[@"type"] intValue];
        if(noti_type == TYPE_REVIEW_POST ||
           noti_type == TYPE_PLACE_BID ||
           noti_type == TYPE_CHAT) {
            [noti_list insertObject:notiData atIndex:0];
        }
    }
    
    if(noti_list.count == 0) {
        [Util showAlertTitle:self title:@"" message:@"No notifications available."];
    }
    [tv reloadData];
}

-(void) loadAvatarFromName:(NSString*)senderId imgAvatar:(UIImageView*) imgAvatar{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:senderId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object) {
            PFUser* user = (PFUser*) object;
            if(user) {
                [Util setAvatar:imgAvatar withUser:user];
            }
        }
    }];
}

- (void) gotoChatVC:(NSString*)roomId {
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query includeKeys:@[FIELD_PARTICIPANTS, FIELD_REMOVELIST, FIELD_LAST_MESSAGE]];
    [query whereKey:@"objectId" equalTo:roomId];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        if(resultObj.count == 0) {
            [Util showAlertTitle:self title:@"" message:@"This chat room is removed."];
            return;
        }
        for(PFObject* group in resultObj) {
            NSArray* participants = group[FIELD_PARTICIPANTS];
            PFUser* toUser;
            for(PFUser* user in participants) {
                if(![user.objectId isEqualToString:me.objectId]) {
                    toUser = user;
                    break;
                }
            }
            if(toUser) {
                ChatViewController *vc = (ChatViewController *)[Util getUIViewControllerFromStoryBoard:@"ChatViewController"];
                vc.toUser = toUser;
                vc.room = group;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            else {
                [Util showAlertTitle:self title:@"" message:@"This chat room is removed."];
            }
        }
        
        
    }];
}

- (void) gotoListOfBiddersVC : (NSString*) jobId {
    PFQuery *query = [PFQuery queryWithClassName:@"Job"];
    [query includeKeys:@[FIELD_OWNER, FIELD_BIDDERS, FIELD_WORKER]];
    [query whereKey:@"objectId" equalTo:jobId];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        for(PFObject* job in resultObj) {
            ListOfBiddersVC *vc = (ListOfBiddersVC *)[Util getUIViewControllerFromStoryBoard:@"ListOfBiddersVC"];
            vc.currentJob = job;
            [vc getBidders];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        
    }];
}
@end
