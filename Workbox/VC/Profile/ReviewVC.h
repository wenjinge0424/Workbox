//
//  ReviewVC.h
//  Workbox
//
//  Created by developer  on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "HCSStarRatingView.h"

@interface ReviewVC : UIViewController
@property (nonatomic) NSMutableArray* arr_reviews;
@property (nonatomic) PFUser* me;
- (void) getReviews;
@end
