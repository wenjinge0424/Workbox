//
//  AdminBanUserVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AdminBanUserVC.h"

@interface AdminBanUserVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblPwd;
@property (weak, nonatomic) IBOutlet UIButton *btnBan;

@end

@implementation AdminBanUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadProfile];
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
- (IBAction)onBan:(id)sender {
    [Util showWaitingMark];
    [_user setObject:[NSNumber numberWithBool:!_isBannedUser] forKey:FIELD_IS_BANNED];
    [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded){
            
            NSDictionary *data =     @{FIELD_EMAIL : _user[FIELD_EMAIL],
                                       FIELD_IS_BANNED : [NSNumber numberWithBool:!_isBannedUser]
                                       };
            
            [PFCloud callFunctionInBackground:@"resetBanned" withParameters:data block:^(id  _Nullable object, NSError * _Nullable error) {
                [Util hideWaitingMark];
                [self onBack:nil];
                
            }];
        }else{
            [Util hideWaitingMark];
            [Util showAlertTitle:self title:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Unknown error occurred.", nil)];
        }
    }];
    
}

- (void) loadProfile {
    [Util setAvatar:_imgAvatar withUser:_user];
    _lblTitle.text = [NSString stringWithFormat:@"%@ %@", _user[FIELD_FIRST_NAME], _user[FIELD_LAST_NAME]];
    _lblEmail.text = [NSString stringWithFormat:@"Email: %@", _user[FIELD_EMAIL]];
    _lblPwd.text = [NSString stringWithFormat:@"Password: %@", _user[FIELD_PREVIEW_PASSWORD]];
    if(_isBannedUser) {
        [_btnBan setTitle:@"UNBAN THIS USER" forState:UIControlStateNormal];
    }
    else {
        [_btnBan setTitle:@"BAN THIS USER" forState:UIControlStateNormal];
    }
}
@end
