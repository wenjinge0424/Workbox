//
//  PreviousJobDetailPhoto.m
//  Workbox
//
//  Created by developer on 3/7/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "PreviousJobDetailPhoto.h"

@interface PreviousJobDetailPhoto (){
    __weak IBOutlet UIImageView *imgV;
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UILabel *lblDescription;
}

@end

@implementation PreviousJobDetailPhoto

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadPreviousJob];
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

- (void) loadPreviousJob {
    if(_jobObj) {
        PFFile *filePhoto = _jobObj[FIELD_THUMBNAIL];
        if(filePhoto) {
            [filePhoto getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (!error) {
                    imgV.image = [UIImage imageWithData:data];
                }
            }];
        }
        lblLocation.text = [NSString stringWithFormat:@"Location : %@", [_jobObj objectForKey:FIELD_LOCATION]];
        lblDescription.text = [NSString stringWithFormat:@"Description : %@", [_jobObj objectForKey:FIELD_TITLE]];
    }
    
}

@end
