//
//  LanDeviceCell.h
//  ilnkDemo
//
//  Created by YGTech on 2017/11/29.
//  Copyright © 2017年 com.ilnkDemo.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LanDeviceCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *deviceType;

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *deviceID;
@property (weak, nonatomic) IBOutlet BButton *addButton;



@end






//========== 数据模型 ============
//@interface LanDeviceModel:NSObject
//
//@property (nonatomic, strong) NSString *deviceID;
//
//
//
//@end

