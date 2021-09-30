//
//  MyTabbarVC.m
//  Workbox
//
//  Created by developer on 2/14/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "MyTabbarVC.h"

@interface MyTabbarVC ()

@end

@implementation MyTabbarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 10.0, *)) {
        [[UITabBar appearance] setUnselectedItemTintColor:[UIColor colorWithRed:0.0 green:26/255.0 blue:61/255.0 alpha:1.0]];
    } else {
        // Fallback on earlier versions
    }
    [[UITabBar appearance] setTintColor:[UIColor redColor]];
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
