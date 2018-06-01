//
//  FilterCell.h
//  Kamu
//
//  Created by Zhoulei on 2018/5/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegionModel.h"


//@class SideSlipBaseTableViewCell;
@protocol FilterCellDelegate <NSObject>
@optional
- (void)sideSlipTableViewCellNeedsReload:(NSIndexPath *)indexPath;
- (void)sideSlipTableViewCellNeedsPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)sideSlipTableViewCellNeedsScrollToCell:(UITableViewCell *)cell atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
@end












@interface FilterCell : UITableViewCell
@property (weak, nonatomic) id<FilterCellDelegate> delegate;
+ (NSString *)cellReuseIdentifier;
+ (CGFloat)cellHeight; //option
+ (instancetype)createCellWithIndexPath:(NSIndexPath *)indexPath;
- (void)updateCellWithModel:(RegionModel **)model indexPath:(NSIndexPath *)indexPath;
- (void)resetData;
@end
