//
//  GroupModel.h
//  Workbox
//
//  Created by developer on 2/14/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import <Parse/Parse.h>

@interface GroupModel : NSObject
@property (nonatomic) NSString* lastDate;
@property (nonatomic) NSString* lastMessage;
@property (nonatomic) NSString* lastSenderUserName;
@property (nonatomic) NSString* lastSenderUserId;
@property (nonatomic) NSString* lastSenderAvatarUrl;
@property (nonatomic) NSString* groupId;
@property (nonatomic) BOOL isNewChat;
@property (nonatomic) NSMutableArray* users;

@property (nonatomic) PFFile* thumbnail;

@end
