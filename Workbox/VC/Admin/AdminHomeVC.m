//
//  AdminHomeVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AdminHomeVC.h"

@interface AdminHomeVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end

@implementation AdminHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser* me = [PFUser currentUser];
    _lblName.text = [NSString stringWithFormat:@"%@ %@", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
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

@end
