//
//  ChatDetailsViewController.m
//  Bmbrella
//
//  Created by gao on 10/31/17.
//  Copyright © 2017 Mikolaj Kudumov. All rights reserved.
//

#import "ChatDetailsViewController.h"
#import "MessageModel.h"
#import "IQDropDownTextField.h"
#import "JobCompleteMessageCollectionViewCell.h"
#import "StripeRest.h"

static ChatDetailsViewController *_sharedViewController = nil;

@interface ChatDetailsViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    PFUser *me;
    NSMutableArray *messages;
    JSQMessagesBubbleImage *outgoingBubbleImageData;
    JSQMessagesBubbleImage *incomingBubbleImageData;
    BOOL isLoading;
    BOOL isCamera;
    BOOL isPhoto;
    int userType;
    NSString *mainId;
    NSString *feeId;
    NSString *messageId;
}

@end

@implementation ChatDetailsViewController
@synthesize toUser;

- (void)viewDidLoad {
    [super viewDidLoad];
    me = [PFUser currentUser];
    userType = [me[FIELD_USER_TYPE] intValue];
    isCamera = NO;
    isPhoto = NO;
    _sharedViewController = self;
    self.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
    [self.inputToolbar setBackgroundColor:[UIColor clearColor]];
    self.inputToolbar.contentView.textView.placeHolder = @"Type a message...";
    [self.inputToolbar.contentView setBackgroundColor:[UIColor clearColor]];
    self.inputToolbar.contentView.textView.textColor = [UIColor whiteColor];
    [self.inputToolbar.contentView.textView setBackgroundColor:[UIColor clearColor]];
    [self.inputToolbar.contentView.leftBarButtonContainerView setBackgroundColor:[UIColor clearColor]];
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.inputToolbar.contentView.rightBarButtonItem setTitle:@"Send" forState:UIControlStateNormal];
    self.inputToolbar.contentView.rightBarButtonItemWidth = 41.f;
    self.inputToolbar.contentView.rightBarButtonItem.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.inputToolbar.contentView.rightBarButtonItem.titleLabel.adjustsFontSizeToFitWidth = YES;
    JSQMessagesBubbleImageFactory *bubbleFactory = [JSQMessagesBubbleImageFactory new];
    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor grayColor]];
    messages = [NSMutableArray new];
    isLoading = NO;
    self.showLoadEarlierMessagesHeader = NO;
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */
    
    /** Set a maximum height for the input toolbar **/
    self.inputToolbar.maximumHeight = 150;
    self.senderId = me.objectId;
    self.senderDisplayName = [NSString stringWithFormat:@"%@ %@", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessage) name:kChatReceiveNotification object:nil];
    
    if (toUser){
        [self refreshUI];
    } else {
        
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JobCompleteMessageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"JobCompleteMessageCollectionViewCell"];
      self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
      self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [AppStateManager sharedInstance].chatRoomId = @"";
    _sharedViewController = nil;
}

+ (ChatDetailsViewController *)getInstance{
    return _sharedViewController;
}

- (void) setRoom:(PFObject *) room User:(PFUser *) user {
    self.toUser = user;
    self.room = room;
    [self refreshUI];
}

- (void)refreshUI {
    [AppStateManager sharedInstance].chatRoomId = self.room.objectId;
    [self loadMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshMessage {
    [self loadMessages];
}

- (void)loadMessages {
    if (!isLoading) {
        [Util showWaitingMark];
        isLoading = true;
        MessageModel *message_last = messages.lastObject;
        
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        [query whereKey:PARSE_HISTORY_ROOM equalTo:self.room];
        if (message_last != nil) {
            [query whereKey:PARSE_FIELD_CREATED_AT greaterThan:message_last.date];
        }
        [query orderByDescending:PARSE_FIELD_CREATED_AT];
        [query includeKey:PARSE_HISTORY_SENDER];
        [query setLimit:100];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error && objects.count > 0) {
                self.automaticallyScrollsToMostRecentMessage = NO;
                for (int i = objects.count - 1; i>=0; i--) {
                    PFObject* msgObj = objects[i];
                    if(msgObj) {
                        NSArray* removeList = msgObj[FIELD_REMOVELIST];
                        
                        if(removeList.count == 0) {
                            [self addMessage:msgObj];
                        }
                        else {
                            for(PFUser* removeUser in removeList) {
                                if([removeUser.objectId isEqualToString:me.objectId]) {
                                    break;
                                }
                                [self addMessage:msgObj];
                            }
                        }
                    }
                }
                [self finishReceivingMessage];
                [self scrollToBottomAnimated:NO];
                self.automaticallyScrollsToMostRecentMessage = YES;
            }
            [Util hideWaitingMark];
            isLoading = NO;
        }];
    }
}

- (void)addMessage:(PFObject *)object {
    
    PFUser *sender = object[PARSE_HISTORY_SENDER]; // me
    NSString *senderId = sender.objectId;
    NSString* msgType = object[@"type"];
    if([msgType isEqualToString:@"text"]) {
        NSString *chatText = object[@"text"];
        NSString* senderName = [NSString stringWithFormat:@"%@ %@", sender[FIELD_FIRST_NAME], sender[FIELD_LAST_NAME]];
        MessageModel *message = [[MessageModel alloc] initWithSenderId:senderId senderDisplayName:senderName date:object.createdAt text:chatText];
        message.objectId = object.objectId;
        [messages addObject:message];
    }
    else if ([msgType isEqualToString:@"picture"]) {
        PFFile *filePhoto = object[@"picture"];
        if(filePhoto) {
            JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
                        
            mediaItem.appliesMediaViewMaskAsOutgoing = [senderId isEqualToString:me.objectId];
            NSString* senderName = [NSString stringWithFormat:@"%@ %@", sender[FIELD_FIRST_NAME], sender[FIELD_LAST_NAME]];
            MessageModel *photoMsg = [[MessageModel alloc] initWithSenderId:senderId senderDisplayName:senderName date:object.createdAt media:mediaItem];
            photoMsg.objectId = object.objectId;
            [filePhoto getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (!error) {
                    mediaItem.image = [UIImage imageWithData:data];
                    [self.collectionView reloadData];
                }
            }];
            [messages addObject:photoMsg];
        }
    }
    else if ([msgType isEqualToString:@"job completed"]) {
        if (userType == TYPE_USER_LOOKING){
            NSString *chatText = object[@"text"];
            NSString* senderName = [NSString stringWithFormat:@"%@ %@", sender[FIELD_FIRST_NAME], sender[FIELD_LAST_NAME]];
            MessageModel *message = [[MessageModel alloc] initWithSenderId:senderId senderDisplayName:senderName date:object.createdAt text:chatText];
            message.objectId = object.objectId;
            [messages addObject:message];
        }
        else {
            
        NSString *chatText = object[@"text"];
        NSString* senderName = [NSString stringWithFormat:@"%@ %@", sender[FIELD_FIRST_NAME], sender[FIELD_LAST_NAME]];
        MessageModel *message = [[MessageModel alloc] initWithSenderId:senderId senderDisplayName:senderName date:object.createdAt text:chatText];
        message.objectId = object.objectId;
        message.isJobComplete = YES;
        [messages addObject:message];
        }
    }
    
}

/// Helper methods
- (BOOL)inComing:(JSQMessage *)message {
    BOOL isOutGoing = [message.senderId isEqualToString:me.objectId];
    return !isOutGoing;
}

- (BOOL)outGoing:(JSQMessage *)message {
    BOOL isOutGoing = [message.senderId isEqualToString:me.objectId];
    return isOutGoing;
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    text = [Util trim:text];
    UITextView *textView = self.inputToolbar.contentView.textView;
    textView.text = text;
    if (toUser){
        if (text.length == 0) {
            return;
        }
        if (text.length > 1000) {
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"long_message")];
            return;
        }
        [self.inputToolbar.contentView.textView resignFirstResponder];
        [self sendMessage:text video:nil photo:nil isJobComplete:NO];
    } else {
        [Util showAlertTitle:self title:LOCALIZATION(@"error") message:LOCALIZATION(@"no_receiver")];
    }
}

- (void)sendMessage:(NSString *)text video:(PFFile *)video photo:(PFFile *)photo isJobComplete:(BOOL) isJobComplete {
    if (!self.room || !toUser){
        [Util showAlertTitle:self title:@"Error" message:@"Please select recipient first."];
        return;
    }
    
    [self.room setObject:@[] forKey:FIELD_REMOVELIST];
    [self.room saveInBackground];
    
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_CHAT_HISTORY];
    object[PARSE_HISTORY_ROOM] = self.room;
    object[PARSE_HISTORY_SENDER] = me;
    
    if (text) {
        object[PARSE_HISTORY_MESSAGE] = text;
        object[PARSE_HISTORY_TYPE] = @"text";
    }
    
    if (photo) {
        object[PARSE_HISTORY_IMAGE] = photo;
        object[PARSE_HISTORY_MESSAGE] = @"[Photo]";
        object[PARSE_HISTORY_TYPE] = @"picture";
    }
    if(isJobComplete == YES) {
        object[PARSE_HISTORY_TYPE] = @"job completed";
        object[PARSE_HISTORY_MESSAGE] = @"Job Completed";
    }
    [Util showWaitingMark];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            self.room[PARSE_ROOM_LAST_MESSAGE] = object;
            [self.room saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                NSString* pushMsg = @"";
                if(photo) {
                    pushMsg = [NSString stringWithFormat:@"%@ %@ sent a image", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME]];
                }
                else {
                    NSString* shortMsg = [NSString stringWithFormat:@"'%@'", text];
                    
                    if (text.length > 20) {
                        shortMsg = [NSString stringWithFormat:@"'%@...'", [text substringToIndex:20]];
                    }
                    pushMsg = [NSString stringWithFormat:@"%@ %@ sent a message %@", me[FIELD_FIRST_NAME], me[FIELD_LAST_NAME], shortMsg];
                }
                
                [Util sendPushNotification: TYPE_CHAT obecjtId:self.room.objectId receiver:toUser.username message:pushMsg senderId:me.objectId];
            }];
            [self loadMessages];
        }
    }];
    [self finishSendingMessage];
}

- (void)sendPushNotification:(NSString *)msg {
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"take_photo") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"choose_gallery") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onChoosePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:LOCALIZATION(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

//- (void) payMoney : (void (^)(BOOL success))completionHandler {
//
//    dispatch_async(dispatch_get_main_queue(), ^{
////        [self getCardInfos];
//    });
//    completionHandler(NO);
//}
- (void) getCardInfos : (void (^)(BOOL isSuccess))completionHandler {
    [Util showWaitingMark];
    //get bid amount
    PFObject* jobObj = _room[FIELD_JOB_MODEL];
//    [jobObj fetchIfNeeded];
//    [jobObj fetchIfNeededInBackground];
    [jobObj fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSArray* bidCosts = (NSArray*)[jobObj objectForKey:FIELD_PRICE_LIST];
        int iMin = 0;
        int iMinId = 0;
        int counter = 0;
        for(NSNumber* num in bidCosts){
            int iX = num.intValue;
            if (counter == 0){
                iMin = iX;
            }
            else if (iX < iMin) {
                iMin = iX;
                iMinId = counter;
            }
            counter = counter + 1;
        }
        int lowestPrice = iMin;
        
        NSString *amount = [NSString stringWithFormat:@"%d", lowestPrice* 100];
        if (amount.length > 9){
            [Util hideWaitingMark];
            [Util showAlertTitle:self title:@"" message:@"Unable to process payment. Amount exceeds limit"];
            return;
        }
        NSString *accountId = toUser[@"accountId"];
        if(accountId == nil || [accountId isEqualToString:@""]) {
            [Util hideWaitingMark];
            NSString* otherName = [NSString stringWithFormat:@"%@ %@", toUser[FIELD_FIRST_NAME], toUser[FIELD_LAST_NAME]];
            NSString* msgStr = [NSString stringWithFormat:@"You can not pay to %@. He doesn't have to set payment", otherName];
            [Util showAlertTitle:self title:LOCALIZATION(@"error") message:msgStr finish:^(void){
                
            }];
            return;
        }
        
        
        PFQuery *query = [PFQuery queryWithClassName:@"CardInfo"];
        [query includeKeys:@[FIELD_OWNER]];
        [query whereKey:FIELD_OWNER_1 equalTo: me];
        [query whereKey:FIELD_STATE equalTo:[NSNumber numberWithBool:YES]];
        [query orderByDescending:@"createdAt"];
        
        [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
            if (resultObj.count > 0) {
                PFObject* cardObj = resultObj[0];
                //            [cardObj fetchIfNeeded];
//                [cardObj fetchIfNeededInBackground];
                [cardObj fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    NSString* cardNumber = cardObj[FIELD_CARD_NUMBER];
                    NSString* expDate = cardObj[FIELD_EXP_DATE];
                    NSString *expMonth = [expDate substringWithRange: NSMakeRange(0, 2)];
                    NSString *expYear = [expDate substringWithRange: NSMakeRange(2, 2)];
                    NSString* cvvStr = cardObj[FIELD_CVV];
                    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                     @"iOS", @"DeviceType",
                                                     nil];
                    NSMutableDictionary *chargeDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                       amount, @"amount",
                                                       @"usd", @"currency",
                                                       @"false", @"capture",
                                                       accountId, @"destination",
                                                       @"pay money", @"description",
                                                       metadata, @"metadata",
                                                       nil];
                    NSMutableDictionary *tokenDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                      [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                       cardNumber, @"number",
                                                       expYear, @"exp_year",
                                                       expMonth, @"exp_month",
                                                       cvvStr, @"cvc",
                                                       @"usd", @"currency",
                                                       nil],
                                                      @"card",
                                                      nil];
                    
                    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
                    [StripeRest setCharges:chargeDict tokenDict:tokenDict completionBlock:^(id response, NSError *err) { // pay to bussiness
                        if (err) {
                            [SVProgressHUD dismiss];
                            if ([[err localizedDescription] isEqualToString:@"Request failed: bad request (400)"]){
                                [Util showAlertTitle:self title:@"" message:@"Unable to process payment. Not enough balance."];
                            } else {
                                [Util showAlertTitle:self title:@"" message:@"Unable to process payment. Please check your details and try again."];
                            }
                        } else {
                            completionHandler(YES);
                            [Util showAlertTitle:self title:@"" message:@"Payment is completed." finish:^{
                                /* goto main */
                                //                        [self gotoMain];
                                //change message type
                                PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
                                [query whereKey:@"objectId" equalTo:messageId];
                                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                    if (!error && objects.count > 0) {
                                        self.automaticallyScrollsToMostRecentMessage = NO;
                                        
                                        PFObject* msgObj = objects[0];
                                        if(msgObj) {
                                            msgObj[PARSE_HISTORY_TYPE] = @"text";
                                            //                                    [msgObj saveInBackground];
                                            [msgObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                
                                            }];
                                        }
                                    }
                                }];
                                
                                //change job status
                                PFObject* jobObj= _room[FIELD_JOB_MODEL];
                                [jobObj fetchIfNeeded];
                                [jobObj setObject:[NSNumber numberWithInteger:STATE_COMPLETED] forKey:FIELD_STATE];
                                [jobObj saveInBackground];
                            }];
                        }
                    }];
                }];
                
            }
            else {
                [Util hideWaitingMark];
                [Util showAlertTitle:self title:LOCALIZATION(@"error") message:@"You don't have CardNumber activated." finish:^(void){
                    
                }];
            }
        }];
    }];
    
    
}
- (void)onChoosePhoto:(id)sender {
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    isPhoto = YES;
    isCamera = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)onTakePhoto:(id)sender {
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Camera"];
        return;
    }
    isCamera = YES;
    isPhoto = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isCamera &&![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Camera"];
        return;
    }
    if (isPhoto && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    image = [Util getUploadingImageFromImage:image];
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    [self sendMessage:@"" video:nil photo:[PFFile fileWithData:data] isJobComplete:NO];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return outgoingBubbleImageData;
    }
    
    return incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    else {
        return nil;
    }
    
    // can add avatar image
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    JSQMessage *message = messages[indexPath.item];
    NSAttributedString *curDateStr = [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    
    if (indexPath.item == 0)
        return curDateStr;
    else{
        JSQMessage *priorMesg = messages[indexPath.item-1];
        NSAttributedString *priorDateStr = [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:priorMesg.date];
        
        if ([curDateStr isEqualToAttributedString:priorDateStr]) {
            return nil;
        }else
            return curDateStr;
    }
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    MessageModel *msg1 = [messages objectAtIndex:indexPath.item];
    if (msg1.isJobComplete){
        JobCompleteMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JobCompleteMessageCollectionViewCell" forIndexPath:indexPath];
        id<JSQMessageBubbleImageDataSource> bubbleImageDataSource = [collectionView.dataSource collectionView:collectionView messageBubbleImageDataForItemAtIndexPath:indexPath];
        cell.messageBubbleImageView.image = [bubbleImageDataSource messageBubbleImage];
        cell.messageBubbleImageView.highlightedImage = [bubbleImageDataSource messageBubbleHighlightedImage];
        [cell setDidTapYesBlock:^(id sender) {
            NSLog(@"tap yes");
            //pay
            
//            [self payMoney];
//            [self payMoney:^(BOOL success) {
//                if (success == true) {
//                    messageId = msg1.objectId;
//                    msg1.isJobComplete = NO;
//                    [self.collectionView reloadData];
//                }
//            }];
            
            [self getCardInfos:^(BOOL isSuccess) {
                if (isSuccess == true) {
                    messageId = msg1.objectId;
                    msg1.isJobComplete = NO;
                    [self.collectionView reloadData];
                }
            }];
            
            
        }];
        
        [cell setDidTapNoBlock:^(id sender) {
            NSLog(@"tap no");
            //change message type
            PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
            [query whereKey:@"objectId" equalTo:msg1.objectId];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (!error && objects.count > 0) {
                    self.automaticallyScrollsToMostRecentMessage = NO;
                    
                    PFObject* msgObj = objects[0];
                    if(msgObj) {
                        msgObj[PARSE_HISTORY_TYPE] = @"text";
                        [msgObj saveInBackground];
                        [msgObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            msg1.isJobComplete = NO;
                            [self.collectionView reloadData];
                        }];
                    }
                }
            }];
        }];
        return cell;

    }
    
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    
    
    
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    
}

#pragma  alertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger tag = alertView.tag;
    
}

- (NSString *) getDisplayName:(PFUser *)user {
    return [NSString stringWithFormat:@"%@ %@", user[FIELD_FIRST_NAME], user[FIELD_LAST_NAME]];
}

- (void) tapComplete{
    NSLog(@"tap complete on detail");
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self sendMessage:@"" video:nil photo:nil isJobComplete:YES];
}

- (void) tapCancel{
    NSLog(@"tap cancel on detail");
    PFObject* jobObj= _room[FIELD_JOB_MODEL];
    [jobObj fetchIfNeeded];
    [jobObj setObject:[NSNumber numberWithInteger:STATE_COMPLETED] forKey:FIELD_STATE];
    [jobObj saveInBackground];
}

@end
