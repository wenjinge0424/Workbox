//
//  ProfileVideoCollectionViewCell.h
//  Workbox
//
//  Created by developer on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellDelegate.h"

@interface ProfileVideoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) id<CellDelegate>delegate;
@property (assign, nonatomic) NSInteger cellIndex;

@end
