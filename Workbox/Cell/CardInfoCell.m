//
//  CardInfoCell.m
//  Workbox
//
//  Created by developer on 3/8/18.
//  Copyright © 2018 developer. All rights reserved.
//

#import "CardInfoCell.h"

@implementation CardInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onTapDelete:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnCellAtIndex:withData:)]) {
        [self.delegate didClickOnCellAtIndex:_cellIndex withData:@""];
    }
}
- (IBAction)onActive:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnCellAtIndex:withData:)]) {
        [self.delegate didClickActiveAtIndex:_cellIndex withData:@""];
    }
}

@end
