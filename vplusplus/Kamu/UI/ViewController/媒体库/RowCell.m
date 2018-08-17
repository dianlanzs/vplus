//
//  ItemCell.m
//  Kamu
//
//  Created by Zhoulei on 2018/5/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "RowCell.h"
#import "ItemCell.h"
@implementation RowCell

+ (NSString *)cellReuseIdentifier {
    return @"RowCell";
}





#pragma mark - 生命方法
+ (instancetype)createCellWithIndexPath:(NSIndexPath *)indexPath {

    RowCell *cell = [[RowCell alloc] init];
    [cell setIndexPath:indexPath];
//    [cell configureCell];
    [cell setupCell];
    return cell;
}
- (UILabel *)regionLb {
    if (!_regionLb) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
          paragraphStyle.firstLineHeadIndent = 32;
        NSAttributedString *attr_s = [NSAttributedString stringWithText:LS(@"选择摄像头") withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blackColor] aligment:NSTextAlignmentLeft hasUnderline:NO headIndent:20];
        _regionLb = [UILabel new];
        [_regionLb setAttributedText:attr_s];
        [_regionLb setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    }
    return _regionLb;
}
- (void)layoutSubviews {
    [super layoutSubviews];
     [_cvLayout setItemSize:CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 60.f)];
    NSLog(@"XXXXXXXX%@",NSStringFromCGRect(self.contentView.frame));
    NSLog(@"XXXXXXXXcell%@",NSStringFromCGRect(self.bounds));
}


- (void)setupCell {
    
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.regionLb];
    [self.contentView addSubview:self.mainCollectionView];
    
//    if (@available(iOS 11.0, *)) {
//        [self.contentView setDirectionalLayoutMargins:NSDirectionalEdgeInsetsMake(64, 20, 0, 0)];
//    } else {
//        [self.contentView setLayoutMargins:UIEdgeInsetsMake(64, 20, 0, 0)];
//    }
    
    [self.regionLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(40.f);
    }];
    
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.regionLb.mas_bottom);
        make.leading.trailing.equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
    }];
    [self.mainCollectionView registerClass:[ItemCell class] forCellWithReuseIdentifier:[ItemCell cellReuseIdentifier]];
}


- (void)updateCellWithModel:(RegionModel **)model
                  indexPath:(NSIndexPath *)indexPath {
    
    
    self.indexPath = indexPath;
    self.regionModel = *model; //sectionModel;
    
//    [self.regionLb setText:self.regionModel.regionTitle];
    
    //content
    self.items = self.regionModel.itemList;
    
    
    //icon
//    if (self.regionModel.isShowAll) {
//        [_controlIcon setImage:[UIImage imageNamed:@"icon_up"]];
//    } else {
//        [_controlIcon setImage:[UIImage imageNamed:@"icon_down"]];
//    }
    
    
    
    //controlLabel
    self.selectedItemList = [NSMutableArray arrayWithArray:self.regionModel.selectedItemList];
    
    
    
    
//    [self generateControlLabelText];
    
    /**
    数据源model customDict中可配置的key_value
    */
#define REGION_SELECTION_TYPE @"REGION_SELECTION_TYPE"
    //selectionType
//    NSNumber *selectionType = self.regionModel.customDict[REGION_SELECTION_TYPE];
//    if (selectionType) {
        self.selectionType = 1;
//    }
    
    
    
//
//    Cam *cam = self.cams[indexPath.row];
//    self.camName.text = _items
    

    //UI
    [self.mainCollectionView reloadData];
    [self fitCollectonViewHeight];
}

#define NUM_OF_ITEM_ONCE_ROW 1.f
#define LINE_SPACE_COLLECTION_ITEM 20
#define ITEM_WIDTH CGRectGetWidth(self.bounds)
#define ITEM_HEIGHT  CGRectGetHeight(self.bounds)

//根据数据源个数决定collectionView高度
- (void)fitCollectonViewHeight {
    CGFloat displayNumOfRow;
//    if (_regionModel.isShowAll) {
    if (1) {

        displayNumOfRow = ceil(_items.count/NUM_OF_ITEM_ONCE_ROW);
    }
    else {
        displayNumOfRow = 1;
    }
//    CGFloat collectionViewHeight = displayNumOfRow * ITEM_HEIGHT + (displayNumOfRow - 1)*LINE_SPACE_COLLECTION_ITEM;
    
    
//    self.collectionViewHeightConstraint.constant = collectionViewHeight;
//    [self.mainCollectionView updateHeight:collectionViewHeight];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (void)tap2SelectItem:(NSIndexPath *)cv_indexPath {
   
            ItemModel *item = [self.items objectAtIndex:cv_indexPath.item];
 switch (_selectionType) {
        case RowCellSelectedTypeSingle: {
//            NSArray *itemArray = _regionModel.itemList;
            
            if (!item.selected) {//点击前的状态
                for (ItemModel *item in self.items) {
                    item.selected = NO;  //所有item 置为 不选中
                }
                [self.selectedItemList removeAllObjects];
                [self.selectedItemList addObject:item];  //，如果之前没 selected  ，点击 add
            } else {
                [self.selectedItemList removeObject:item]; // ，如果之前 selected  ，点击 remove
            }
            item.selected = !item.selected;  //反选
        }
            break;
        case RowCellSelectedTypeMultiple: {
//            NSArray *itemArray = _regionModel.itemList;
//            ItemModel *item = [self.items objectAtIndex:cv_indexPath.item];
            item.selected = !item.selected;  //获取点击后的状态
            if (item.selected) {
                [self.selectedItemList addObject:item];
            } else {
                [self.selectedItemList removeObject:item];
            }
        }
            break;
       
    }
    _regionModel.selectedItemList = _selectedItemList;
//    [self generateControlLabelText];
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         //如果你的tableView没有数据，是不会改变高度的。先随便填点数据看下，高度就变了

//
//        [self.contentView setBackgroundColor:[UIColor redColor]];
//        [self.contentView addSubview:self.mainCollectionView];
//        self.mainCollectionView.delegate = self;
//        self.mainCollectionView.dataSource = self;
////        [self.mainCollectionView setContentInset:UIEdgeInsetsMake(0, 10.f, 0, 10.f)];
//        [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.contentView);
//        }];
//
//        [self.mainCollectionView registerClass:[ItemCell class] forCellWithReuseIdentifier:[ItemCell cellReuseIdentifier]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


//+ (CGFloat)cellHeight{
//    return 400;
//}

#pragma mark - DataSource Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:[ItemCell cellReuseIdentifier] forIndexPath:indexPath];
    ItemModel *itemModel = [self.items objectAtIndex:indexPath.row];
    [itemCell updateCellWithModel:itemModel]; //setModel forCell
    return itemCell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return LINE_SPACE_COLLECTION_ITEM;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 0.5*GAP_COLLECTION_ITEM;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self tap2SelectItem:indexPath];
    [_mainCollectionView reloadData];
}
#pragma mark - getter

- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.cvLayout];
        [_mainCollectionView setBackgroundColor:[UIColor whiteColor]];
    }
    
    return _mainCollectionView;
}


- (UICollectionViewFlowLayout *)cvLayout {
    
    if (!_cvLayout) {
        //the item width must be less than the width of the UICollectionView minus the section insets left and right values, minus the content insets left and right values.
        _cvLayout = [[UICollectionViewFlowLayout alloc] init];
       //CGRectGetWidth(self.bounds)CGRectGetWidth(self.contentView.bounds)
        
        NSLog(@"XXXXXXXX%@",NSStringFromCGRect(self.contentView.frame));
   
        [_cvLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
//        [self.contentView setNeedsLayout];
        
    }
    
    return _cvLayout;
}




- (NSMutableArray *)selectedItemList {
    if (!_selectedItemList) {
        _selectedItemList = [NSMutableArray array];
    }
    return _selectedItemList;
}






@end
