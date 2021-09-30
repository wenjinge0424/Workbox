//
//  ChatDetailsViewController.h
//  Bmbrella
//
//  Created by gao on 10/31/17.
//  Copyright © 2017 Mikolaj Kudumov. All rights reserved.
//

#import "SuperViewController.h"
#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import "DemoModelData.h"
#import "AppStateManager.h"
#import "Util.h"
#import "ChatViewController.h"

@class ChatViewController;
@protocol ChatViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(ChatViewController *)vc;

@end

@interface ChatDetailsViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>
@property (strong, nonatomic) PFUser *toUser;
@property (strong, nonatomic) PFObject *room;
@property (strong, nonatomic) NSString *roomId;
@property (nonatomic) BOOL isNewChat;
@property (strong, nonatomic) id<ChatViewControllerDelegate> delegateModal;


+ (ChatDetailsViewController *)getInstance;
- (void) setRoom:(PFObject *) room User:(PFUser *) user ;
- (void) tapComplete;
- (void) tapCancel;
@end
