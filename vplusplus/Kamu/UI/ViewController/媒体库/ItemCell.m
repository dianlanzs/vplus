//
//  ItemCell.m
//  Kamu
//
//  Created by Zhoulei on 2018/5/11.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "ItemCell.h"

@interface ItemCell ()
@property (strong, nonatomic)  UIButton *nameButton;  //如果纯代码 创建  ，这里 不能有 IBOutlet  修饰符 ，不然 创建出的 button 永远是 nil!!  ,是weak 导致的 为NIl!!
@property (copy, nonatomic) NSString *itemId;
@property (nonatomic, strong) UILabel *camLabel;
@end

@implementation ItemCell
+ (NSString *)cellReuseIdentifier {
    return @"itemCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.nameButton];
        [self.nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
//        self.selectedBackgroundView = nil;
    }
    return self;
}

//set model
- (void)updateCellWithModel:(ItemModel *)item {
    [self.nameButton setTitle:item.itemName forState:UIControlStateNormal];
    [self.nameButton setBackgroundColor:[UIColor whiteColor]];
//    [_camLabel setText:item.itemName];
    self.itemId = item.itemId;
    [self tap2SelectItem:item.selected];
}

- (void)tap2SelectItem:(BOOL)selected {
    if (selected) {
//        [self setBackgroundColor:[UIColor hexColor:FILTER_COLLECTION_ITEM_COLOR_SELECTED_STRING]];

//        [_nameButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        self.layer.borderWidth = .5f;
//        self.layer.borderColor = [UIColor blueColor].CGColor;
        [_nameButton setImage:[UIImage imageNamed:@"button_selected"] forState:UIControlStateNormal];
    } else {
        [self setBackgroundColor:[UIColor lightGrayColor]];
        [_nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        self.layer.borderWidth = 0;
//        [_nameButton setImage:nil forState:UIControlStateNormal]; //清空 image
        
        UIImage *unselectedImg = [[UIImage imageNamed:@"button_nonSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_nameButton.imageView setTintColor:[UIColor lightGrayColor]];
        [_nameButton setImage:unselectedImg forState:UIControlStateNormal];

    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (UIButton *)nameButton {
    
    if (!_nameButton) {
        _nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nameButton setImage:[UIImage imageNamed:@"button_nonSelected"] forState:UIControlStateNormal];
        [_nameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_nameButton setUserInteractionEnabled:NO];
        [_nameButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.f, 0, 0)];
        [_nameButton setBackgroundColor:[UIColor whiteColor]];
    }
    
    return _nameButton;
}

@end
