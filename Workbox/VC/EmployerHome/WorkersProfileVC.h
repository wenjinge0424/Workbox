//
//  WorkersProfileVC.h
//  Workbox
//
//  Created by developer  on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface WorkersProfileVC : SuperViewController
@property (nonatomic) PFUser* bidder;
@property (nonatomic) PFObject* jobObj;

@end
