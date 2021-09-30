//
//  AddCardVC.m
//  Workbox
//
//  Created by developer on 2/13/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "AddCardVC.h"
#import "StripeRest.h"
@import Stripe;

@interface AddCardVC () <STPPaymentCardTextFieldDelegate>{
    __weak IBOutlet UIView *cardInfoV;
    STPPaymentCardTextField *paymentField;
    __weak IBOutlet UIButton *btnSave;
    __weak IBOutlet UITextField *tfCountry;
    PFUser* me;
}

@end

@implementation AddCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [cardInfoV layoutIfNeeded];
    paymentField = [[STPPaymentCardTextField alloc] initWithFrame:cardInfoV.frame];
    paymentField.delegate = self;
    [self.view addSubview:paymentField];
    btnSave.enabled = NO;
    me = [PFUser currentUser];
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

//#pragma mark STPPaymentCardTextFieldDelegate
//
- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    NSLog(@"Card number: %@ Exp Month: %@ Exp Year: %@ CVC: %@", textField.cardParams.number, @(textField.cardParams.expMonth), @(textField.cardParams.expYear), textField.cardParams.cvc);
    btnSave.enabled = textField.isValid;
}

- (IBAction)onSave:(id)sender {
    if (![Util isConnectableInternet]){
        [self showNetworkErr];
        return;
    }
    if([self isValid]) {
        NSString* strCVV = paymentField.cardParams.cvc;
        NSString* strCardNumber = paymentField.cardParams.number;
        NSString* expDate = [NSString stringWithFormat:@"%02d%02d", paymentField.cardParams.expMonth, paymentField.cardParams.expYear];
        PFObject* cardInfo = [PFObject objectWithClassName:@"CardInfo"];
        [cardInfo setObject:strCVV forKey:FIELD_CVV];
        [cardInfo setObject:expDate forKey:FIELD_EXP_DATE];
        [cardInfo setObject:[NSNumber numberWithBool:NO] forKey:FIELD_STATE];
        [cardInfo setObject:me forKey:FIELD_OWNER_1];
        [cardInfo setObject:tfCountry.text forKey:FIELD_COUNTRY];
        [cardInfo setObject:strCardNumber forKey:FIELD_CARD_NUMBER];
        
        [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
        [cardInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            if (error == nil){
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                if (error.code == 202){
                    [Util showAlertTitle:self title:STRING_ERROR message:USERNAME_IS_IN_USE];
                }else
                    [Util showAlertTitle:self title:@"" message:@"Unknown error occurred."];
            }
        }];
    }
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL) isValid {
    [self removeHighlight];
    tfCountry.text = [Util trim:tfCountry.text];
    NSString *strCountry = tfCountry.text;
    int errCount = 0;
    if (strCountry.length < 2 || strCountry.length > 20){
        [Util setBorderView:tfCountry color:[UIColor redColor] width:0.6];
        errCount++;
    }
    if (!paymentField.isValid){
        [Util setBorderView:paymentField color:[UIColor redColor] width:0.6];
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
    [Util setBorderView:paymentField color:[UIColor clearColor] width:0.6];
    [Util setBorderView:tfCountry color:[UIColor clearColor] width:0.6];
}

@end
