//
//  CellDelegate.h
//  Workbox
//
//  Created by developer on 3/7/18.
//  Copyright © 2018 developer. All rights reserved.
//

#ifndef CellDelegate_h
#define CellDelegate_h

@protocol CellDelegate <NSObject>
- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withData:(id)data;
- (void)didClickActiveAtIndex:(NSInteger)cellIndex withData:(id)data;
@end
#endif /* CellDelegate_h */
