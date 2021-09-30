//
//  ChatViewController.m
//  Bmbrella
//
//  Created by gao on 10/30/17.
//  Copyright © 2017 Mikolaj Kudumov. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatDetailsViewController.h"
#import "IQDropDownTextField.h"

@interface ChatViewController ()<IQDropDownTextFieldDelegate>
{
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UIView *jobV;
    __weak IBOutlet UIButton *btnComplete;
    __weak IBOutlet UIButton *btnCancel;
    __weak IBOutlet NSLayoutConstraint *jobVHeight;
    int userType;
}
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblTitle.text = [NSString stringWithFormat:@"%@ %@", _toUser[FIELD_FIRST_NAME], _toUser[FIELD_LAST_NAME]];
    [Util setAvatar:imgAvatar withUser:_toUser];
    PFUser *me = [PFUser currentUser];
    userType = [me[FIELD_USER_TYPE] intValue];
    BOOL isHideJobView = YES;
    if (userType == TYPE_USER_LOOKING){
        if(_room[FIELD_JOB_MODEL] != nil){
            PFObject* jobObj = _room[FIELD_JOB_MODEL];
            [jobObj fetchIfNeeded];
            if ([jobObj[FIELD_STATE] intValue] == STATE_STARTED){
                isHideJobView = NO;
            }
            
        }
    }
    else {
        isHideJobView = YES;
    }
    
    if (isHideJobView == YES) {
        jobVHeight.constant = 0;
        jobV.hidden = YES;
    }
    else {
        jobVHeight.constant = 50;
        jobV.hidden = NO;
    }
    
    [self.view layoutIfNeeded];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showChat"]) {
        ChatDetailsViewController *vc = (ChatDetailsViewController *) segue.destinationViewController;
        vc.toUser = self.toUser;
        vc.room = self.room;
    }
}

- (void) textField:(IQDropDownTextField *)textField didSelectItem:(NSString *)item {
    NSLog(@"SELETECT %@", item);
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
}
- (IBAction)onComplete:(id)sender {
    NSLog(@"tap completed");
    [[ChatDetailsViewController getInstance] tapComplete];
}
- (IBAction)onCancel:(id)sender {
    NSLog(@"tap cancel");
    [[ChatDetailsViewController getInstance] tapCancel];
}

@end
