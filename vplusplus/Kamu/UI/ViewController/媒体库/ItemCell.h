//
//  ItemCell.h
//  Kamu
//
//  Created by YGTech on 2018/5/11.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemModel.h"
@interface ItemCell : UICollectionViewCell


//baseClass
+ (NSString *)cellReuseIdentifier;
- (void)updateCellWithModel:(ItemModel *)model;
- (void)tap2SelectItem:(BOOL)selected;

//childClass

@end
