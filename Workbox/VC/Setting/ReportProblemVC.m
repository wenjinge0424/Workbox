//
//  ReportProblemVC.m
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "ReportProblemVC.h"
#define     EMPTY_CONTENT       @"Enter text here..."
@interface ReportProblemVC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *tvDesc;

@end

@implementation ReportProblemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tvDesc.delegate = self;
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
- (IBAction)onSend:(id)sender {
    //send
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:EMPTY_CONTENT]){
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString *text = [[Util trim:textView.text] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if ([[Util trim:text] isEqualToString:@""]){
        textView.text = EMPTY_CONTENT;
        textView.textColor = [UIColor lightGrayColor];
    }
}

@end
