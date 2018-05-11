//
//  ItemCell.m
//  Kamu
//
//  Created by YGTech on 2018/5/11.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "ItemCell.h"

@interface ItemCell ()
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (copy, nonatomic) NSString *itemId;
@end

@implementation ItemCell
+ (NSString *)cellReuseIdentifier {
    return @"itemCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
//    return [[NSBundle mainBundle] loadNibNamed:@"FilterCommonCollectionViewCell" owner:nil options:nil][0];
    
    
    if (self) {
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.contentView addSubview:self.nameButton];
        
        [self.nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    
    return self;
}

//set model
- (void)updateCellWithModel:(ItemModel *)item {
    [_nameButton setTitle:item.itemName forState:UIControlStateNormal];
    self.itemId = item.itemId;
    [self tap2SelectItem:item.selected];
}

- (void)tap2SelectItem:(BOOL)selected {
    if (selected) {
//        [self setBackgroundColor:[UIColor hexColor:FILTER_COLLECTION_ITEM_COLOR_SELECTED_STRING]];
        [self setBackgroundColor:[UIColor whiteColor]];

        [_nameButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.layer.borderWidth = .5f;
        self.layer.borderColor = [UIColor blueColor].CGColor;
        [_nameButton setImage:[UIImage imageNamed:@"item_checked"] forState:UIControlStateNormal];
    } else {
        [self setBackgroundColor:[UIColor lightGrayColor]];
        [_nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.layer.borderWidth = 0;
        [_nameButton setImage:nil forState:UIControlStateNormal]; //清空 image
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
