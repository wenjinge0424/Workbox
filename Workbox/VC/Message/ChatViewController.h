//
//  ChatViewController.h
//  Bmbrella
//
//  Created by gao on 10/30/17.
//  Copyright © 2017 Mikolaj Kudumov. All rights reserved.
//

#import "SuperViewController.h"

//@protocol MyChatDelegate <NSObject>
//
//@optional
//- (void)tapComplete;
//
//@end

@interface ChatViewController : SuperViewController
@property (strong, nonatomic) PFUser *toUser;
@property (strong, nonatomic) PFObject *room;
//@property (weak, nonatomic) id<MyChatDelegate> myDelegate;
@end
