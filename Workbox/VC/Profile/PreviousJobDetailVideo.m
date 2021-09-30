//
//  PreviousJobDetailVideo.m
//  Workbox
//
//  Created by developer on 3/7/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "PreviousJobDetailVideo.h"
#import <AVKit/AVKit.h>

@interface PreviousJobDetailVideo (){
    __weak IBOutlet UIView *playerV;
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UILabel *lblDescription;
    AVPlayer* player;
}

@end

@implementation PreviousJobDetailVideo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadPreviousJob];
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

- (void) loadPreviousJob {
    if(_jobObj) {
        PFFile *videoFile = _jobObj[FIELD_VIDEO];
        if(videoFile) {
            player = [AVPlayer playerWithURL:[NSURL URLWithString:videoFile.url]];
            AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
            [self addChildViewController:controller];
            [playerV addSubview:controller.view];            
            controller.view.frame = playerV.bounds;
            controller.player = player;
            controller.showsPlaybackControls = YES;
            player.closedCaptionDisplayEnabled = NO;
            [player pause];
            [player play];
        }
        lblLocation.text = [NSString stringWithFormat:@"Location : %@", [_jobObj objectForKey:FIELD_LOCATION]];
        lblDescription.text = [NSString stringWithFormat:@"Description : %@", [_jobObj objectForKey:FIELD_TITLE]];
    }
    
}

@end
