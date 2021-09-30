//
//  ProfileVideoCollectionViewCell.m
//  Workbox
//
//  Created by developer on 1/9/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "ProfileVideoCollectionViewCell.h"

@interface ProfileVideoCollectionViewCell (){
    __weak IBOutlet UIImageView *img;
    __weak IBOutlet UILabel *lblDesc;    
}

@end

@implementation ProfileVideoCollectionViewCell
- (IBAction)onDeletePreviousJob:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnCellAtIndex:withData:)]) {
        [self.delegate didClickOnCellAtIndex:_cellIndex withData:@""];
    }
}

@end
