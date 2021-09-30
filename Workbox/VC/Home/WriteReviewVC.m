//
//  WriteReviewVC.m
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "WriteReviewVC.h"
#import "HCSStarRatingView.h"

#define contentPlaceholer @"Write your review here"
#define headlinePlaceholer @"Headline for your review"

@interface WriteReviewVC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starV;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UITextView *tvReviewContent;
@property (weak, nonatomic) IBOutlet UITextView *tvReviewHeadline;

@end

@implementation WriteReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadEmployerData];
    _tvReviewHeadline.delegate = self;
    _tvReviewContent.delegate = self;
    _tvReviewHeadline.text = headlinePlaceholer;
    _tvReviewContent.text = contentPlaceholer;
    _tvReviewHeadline.textColor = [UIColor lightGrayColor];
    _tvReviewContent.textColor = [UIColor lightGrayColor];
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
- (IBAction)onSubmit:(id)sender {
    if([self isValid] == NO) return;
    PFObject* review = [PFObject objectWithClassName:@"Review"];
    [review setObject:[PFUser currentUser] forKey:FIELD_OWNER_1];
    [review setObject:_ower forKey:FIELD_TO_USER];
    [review setObject:[NSNumber numberWithInt:_starV.value] forKey:FIELD_MARK];
    [review setObject:_tvReviewContent.text forKey:FIELD_CONTENT];
    [review setObject:_tvReviewHeadline.text forKey:FIELD_HEAD_LINE];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error == nil){
            [self.navigationController popViewControllerAnimated:YES];
            PFUser* me = [PFUser currentUser];
            NSString* myName = [NSString stringWithFormat:@"You receive a review from %@ %@", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
            [Util sendPushNotification:TYPE_REVIEW_POST obecjtId:review.objectId receiver:_ower.username message:myName senderId:me.objectId];
        }else {
            if (error.code == 202){
                [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
            }else
                [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
        }
    }];
    
}

- (void) loadEmployerData {
    if (_ower == nil) return;
    [Util setAvatar:_imgAvatar withUser:_ower];
    _lblName.text = [NSString stringWithFormat:@"%@ %@", _ower[FIELD_FIRST_NAME], _ower[FIELD_LAST_NAME]];
    _lblAddress.text = _ower[FIELD_LOCATION];
    _starV.value = 0;
}

- (BOOL) isValid {
    [self removeHighlight];
    _tvReviewContent.text = [Util trim:_tvReviewContent.text];
    _tvReviewHeadline.text = [Util trim:_tvReviewHeadline.text];
    NSString *content = _tvReviewContent.text;
    NSString *headline = _tvReviewHeadline.text;
    
    int errCount = 0;
    if (content.length < 6 || content.length > 120 || [content isEqualToString:contentPlaceholer]){
        [Util setBorderView:_tvReviewContent color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (headline.length < 6 || headline.length > 120 || [headline isEqualToString:headlinePlaceholer]){
        [Util setBorderView:_tvReviewHeadline color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (errCount == 1){
        [self showErrorMsg:LOCALIZATION(@"err_single")];
        return NO;
    } else if (errCount > 1){
        [self showErrorMsg:LOCALIZATION(@"err_multi")];
        return NO;
    }
    return YES;
}
- (void) removeHighlight {
    [Util setBorderView:_tvReviewContent color:[UIColor clearColor] width:0.6];
    [Util setBorderView:_tvReviewHeadline color:[UIColor clearColor] width:0.6];
}
- (void) showErrorMsg:(NSString *) msg {
    [Util showAlertTitle:self title:LOCALIZATION(@"error") message:msg];
}

- (void) showNetworkErr {
    [self showErrorMsg:LOCALIZATION(@"network_error")];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == _tvReviewHeadline) {
        [Util setBorderView:_tvReviewHeadline color:[UIColor clearColor] width:0.6];
        if ([textView.text isEqualToString:headlinePlaceholer]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor]; //optional
        }
    }
    else if (textView == _tvReviewContent) {
        [Util setBorderView:_tvReviewContent color:[UIColor clearColor] width:0.6];
        if ([textView.text isEqualToString:contentPlaceholer]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor]; //optional
        }
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        if (textView == _tvReviewHeadline) {
            _tvReviewHeadline.text = headlinePlaceholer;
        }
        else {
            _tvReviewContent.text = contentPlaceholer;
        }
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
@end
