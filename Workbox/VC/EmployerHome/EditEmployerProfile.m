//
//  EditEmployerProfile.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "EditEmployerProfile.h"
#import "EmployerProfileTableViewCell.h"

@interface EditEmployerProfile () <UITableViewDelegate, UITableViewDataSource>  {
    
}

@end

@implementation EditEmployerProfile

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)onSave:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmployerProfileTableViewCell *cell = (EmployerProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"EmployerProfileTableViewCell"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"showEmployerJobDetailVC" sender:Nil];
}

- (IBAction)onShowEmployerReview:(id)sender {
    [self performSegueWithIdentifier:@"showEmployersReview" sender:Nil];
}

@end
