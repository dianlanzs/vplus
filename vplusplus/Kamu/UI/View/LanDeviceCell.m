//
//  LanDeviceCell.m
//  ilnkDemo
//
//  Created by YGTech on 2017/11/29.
//  Copyright © 2017年 com.ilnkDemo.cme. All rights reserved.
//

#import "LanDeviceCell.h"
@interface LanDeviceCell ()



@end





@implementation LanDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.imv.layer setCornerRadius:30] ;
    [self.imv.layer setMasksToBounds:YES];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BButton *)addButton {

    _addButton.color = [UIColor orangeColor];
    
    return _addButton;
    
}



@end
