//
//  CardInfoCell.h
//  Workbox
//
//  Created by developer on 3/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellDelegate.h"

@interface CardInfoCell : UITableViewCell
@property (weak, nonatomic) id<CellDelegate>delegate;
@property (assign, nonatomic) NSInteger cellIndex;
@end
