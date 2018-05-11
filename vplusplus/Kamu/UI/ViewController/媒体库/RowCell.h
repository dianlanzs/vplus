//
//  ItemCell.h
//  Kamu
//
//  Created by YGTech on 2018/5/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "FilterCell.h"
#import "RegionModel.h"


//#import "RowModel.h"
typedef NS_ENUM(NSUInteger, SelectionType) {
   RowCellSelectedTypeSingle = 0,
   RowCellSelectedTypeMultiple = 1,
};
@interface RowCell : FilterCell<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property (nonatomic, strong) UILabel *camName;
@property (nonatomic, strong) UIImageView *selectedIcon;

@property (assign, nonatomic) SelectionType selectionType;
@property (nonatomic, strong) RegionModel *regionModel;  //RowModel





@property (strong, nonatomic) NSMutableArray *selectedItemList;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSArray *items;




@property (strong, nonatomic)  UICollectionView *mainCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *cvLayout;
@property (weak, nonatomic) NSLayoutConstraint *collectionViewHeightConstraint;


@end
