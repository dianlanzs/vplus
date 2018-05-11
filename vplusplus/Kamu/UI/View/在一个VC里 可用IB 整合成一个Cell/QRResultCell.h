//
//  QRResultCell.h
//  Kamu
//
//  Created by YGTech on 2017/12/7.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

#import "DeviceFooter.h"
#import "VideoCell.h"


@class QRResultCell;



@interface QRResultCell : UITableViewCell

@property (nonatomic, strong) DeviceFooter *footer;
@property (strong, nonatomic) UICollectionView *QRcv;

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) Device *nvrModel;

//push 回调
@property (nonatomic, copy) void(^play)(QRResultCell *cell, NSIndexPath *itemPath);
@property (nonatomic, copy) void(^add) (QRResultCell *cell, NSIndexPath *itemPath);

//连接中动画
@property (nonatomic, strong) RTSpinKitView *spinner;
@property (strong, nonatomic) UILabel *statusLb;


@property (nonatomic, strong)Popup *p_alarm;
@property (nonatomic, copy)NSString *str_param;
@property (nonatomic, assign) BOOL showedPopup;

@end
