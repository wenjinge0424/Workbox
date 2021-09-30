//
//  CardInformationVC.m
//  Workbox
//
//  Created by developer on 2/13/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "CardInformationVC.h"
#import "AddCardVC.h"
#import "CardInfoCell.h"
#import "CellDelegate.h"
#import "Util.h"
#import "StripeViewController.h"
@import Stripe;


@interface CardInformationVC () <UITableViewDelegate, UITableViewDataSource>{
    __weak IBOutlet UILabel *lblExistingCard;
    __weak IBOutlet UITableView *tv;
    __weak IBOutlet UIButton *btnEdit;
    NSMutableArray *arr_cards;
    PFUser* me;
    BOOL isEditing;
    STPPaymentCardTextField *paymentField;
    __weak IBOutlet UIButton *btnCardInformation;
    __weak IBOutlet UIButton *btnStripe;
//    __weak IBOutlet UITextField *tfEmail;
//    __weak IBOutlet UITextField *tfPassword;
    __weak IBOutlet UIButton *btnLogin;
    __weak IBOutlet UIView *cardV;
    __weak IBOutlet NSLayoutConstraint *cardVHeight;
    __weak IBOutlet UIButton *btnAddCard;
    __weak IBOutlet NSLayoutConstraint *btnAddCardHeight;
    __weak IBOutlet NSLayoutConstraint *tvHeight;
    int userType;
    __weak IBOutlet UIButton *btnCreateAccount;
    __weak IBOutlet UIView *stripeV;
    __weak IBOutlet NSLayoutConstraint *stripeVHeight;
}

@end

@implementation CardInformationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arr_cards = [NSMutableArray new];
    me = [PFUser currentUser];
    isEditing = NO;
    if(isEditing) {
        [btnEdit setTitle:@"CANCEL" forState:UIControlStateNormal];
    }
    else {
        [btnEdit setTitle:@"EDIT" forState:UIControlStateNormal];
    }
//    tfEmail.enabled = NO;
//    tfPassword.enabled = NO;
    userType = [me[FIELD_USER_TYPE] intValue];
    if (userType == TYPE_USER_LOOKING){
        cardVHeight.constant = 0;
        cardV.hidden = YES;
        btnAddCardHeight.constant = 0;
        btnAddCard.hidden = YES;
        tvHeight.constant = 0;
        tv.hidden = YES;
        stripeVHeight.constant = 0;
        stripeV.hidden = YES;
        [btnLogin setTitle:@"Sign In" forState:UIControlStateNormal];
        
    }
    else {
        stripeV.hidden = YES;
//        tfEmail.hidden = YES;
//        tfPassword.hidden = YES;
        btnLogin.hidden = YES;
        btnCreateAccount.hidden = YES;
    }
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getCardInfos];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)onAddCard:(id)sender {
    AddCardVC *vc = (AddCardVC *)[Util getUIViewControllerFromStoryBoard:@"AddCardVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) getCardInfos {
    PFQuery *query = [PFQuery queryWithClassName:@"CardInfo"];
    [query includeKeys:@[FIELD_OWNER]];
    [query whereKey:FIELD_OWNER_1 equalTo: me];
    [query orderByDescending:@"createdAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_cards removeAllObjects];
        arr_cards = [resultObj mutableCopy];
        lblExistingCard.hidden = arr_cards.count == 0;
        [tv reloadData];
    }];
    
}
- (IBAction)onEdit:(id)sender {
    isEditing = !isEditing;
    if(isEditing) {
        [btnEdit setTitle:@"CANCEL" forState:UIControlStateNormal];
    }
    else {
        [btnEdit setTitle:@"EDIT" forState:UIControlStateNormal];
    }
    [tv reloadData];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_cards.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CardInfoCell *cell = (CardInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"CardInfoCell"];
    cell.delegate = self;
    cell.cellIndex = indexPath.row; // Set indexpath if its a grouped table.
    NSInteger row = indexPath.row;
    UILabel *cardNumberView = (UILabel *)[cell viewWithTag:1];
    UIButton *btnActive = (UIButton *)[cell viewWithTag:2];
    UIButton *btnDelete = (UIButton *)[cell viewWithTag:3];
    
    if (row < arr_cards.count) {
        PFObject* cardInfo = (PFObject*)arr_cards[row];
        BOOL isActive = [cardInfo[FIELD_STATE] boolValue];
        if(!isActive) {
            [btnActive setTitle:@"INACTIVE" forState:UIControlStateNormal];
        }
        else {
            [btnActive setTitle:@"ACTIVE" forState:UIControlStateNormal];
        }
        btnDelete.hidden = !isEditing;
        NSString* cardNumber = cardInfo[FIELD_CARD_NUMBER];
        cardNumberView.text = cardNumber;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withData:(id)data
{
    // Do additional actions as required.
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    alert.customViewColor = MAIN_COLOR;
    [alert addButton:@"Ok" actionBlock:^{
        PFObject* deleteJob = arr_cards[cellIndex];
        [Util showWaitingMark];
        [deleteJob deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [Util hideWaitingMark];
            if(succeeded) {
                [self getCardInfos];
            }
        }];
    }];
    [alert showInfo:@"Confirmation" subTitle:@"Are you sure you want to delete this card?" closeButtonTitle:@"Cancel" duration:0.f];
    
}

- (void)didClickActiveAtIndex:(NSInteger)cellIndex withData:(id)data
{
    // Do additional actions as required.
    //    NSLog(@"Cell at Index: %d clicked.\n Data received : %@", cellIndex, data);
    PFObject* deleteJob = arr_cards[cellIndex];
    BOOL isActive = [deleteJob[FIELD_STATE] boolValue];
    if(isActive) {
        [deleteJob setObject:[NSNumber numberWithBool:!isActive] forKey:FIELD_STATE];
        [Util showWaitingMark];
        [deleteJob saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [Util hideWaitingMark];
            if(succeeded) {
                [self getCardInfos];
            }
        }];
    }
    else {
        
        for(PFObject* cardInfo in arr_cards){
            if(![cardInfo.objectId isEqualToString:deleteJob.objectId]) {
                [cardInfo setObject:[NSNumber numberWithBool:NO] forKey:FIELD_STATE];
                [cardInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                }];
            }
        }
        [deleteJob setObject:[NSNumber numberWithBool:!isActive] forKey:FIELD_STATE];
        [Util showWaitingMark];
        [deleteJob saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [Util hideWaitingMark];
            if(succeeded) {
                [self getCardInfos];
            }
        }];
    }
    
}
- (IBAction)onTapCardInformation:(id)sender {
    btnCardInformation.selected = YES;
    btnStripe.selected = NO;
//    tfEmail.enabled = NO;
//    tfPassword.enabled = NO;
}
- (IBAction)onTapStripe:(id)sender {
    btnCardInformation.selected = NO;
    btnStripe.selected = YES;
//    tfEmail.enabled = YES;
//    tfPassword.enabled = YES;
}
- (IBAction)onTapLogin:(id)sender {
//    if (![Util isConnectableInternet]){
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"network_error")];
//        return;
//    }
//
//    if (![self isValid]){
//        return;
//    }
    
    StripeViewController *vc = (StripeViewController *)[Util getUIViewControllerFromStoryBoard:@"StripeViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
}
//
//- (BOOL) isValid {
//    tfEmail.text = [Util trim:tfEmail.text];
//    NSString *email = tfEmail.text;
//    NSString *password = tfPassword.text;
//    if (email.length == 0){
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_email") finish:^(void){
//            [tfEmail becomeFirstResponder];
//        }];
//        return NO;
//    }
//    if (![email isEmail]){
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_email") finish:^(void){
//            [tfEmail becomeFirstResponder];
//        }];
//        return NO;
//    }
//
//    if ([email containsString:@".."]){
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"invalid_email") finish:^(void){
//            [tfEmail becomeFirstResponder];
//        }];
//        return NO;
//    }
//    if( ![email isEqualToString:me[FIELD_EMAIL]]) {
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:@"Please enter correct email" finish:^(void){
//            [tfEmail becomeFirstResponder];
//        }];
//        return NO;
//    }
//
//    if (password.length == 0){
//        [self showErrorMsg:LOCALIZATION(@"no_password")];
//        return NO;
//    }
//    if(![password isEqualToString:me[FIELD_PREVIEW_PASSWORD]]) {
//        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:@"Please enter correct password" finish:^(void){
//            [tfPassword becomeFirstResponder];
//        }];
//        return NO;
//    }
//
//    return YES;
//}

- (IBAction)onTapCreateAccount:(id)sender {
    StripeViewController *vc = (StripeViewController *)[Util getUIViewControllerFromStoryBoard:@"StripeViewController"];
    vc.bCreateAccount = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
