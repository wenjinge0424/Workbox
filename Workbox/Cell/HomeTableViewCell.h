//
//  HomeTableViewCell.h
//  Workbox
//
//  Created by developer on 1/10/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellDelegate.h"

@interface HomeTableViewCell : UITableViewCell
@property (weak, nonatomic) id<CellDelegate>delegate;
@property (assign, nonatomic) NSInteger cellIndex;
@property (weak, nonatomic) IBOutlet UIImageView *eyeV;

@end
