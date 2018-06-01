//
//  DeviceFooter.h
//  Kamu
//
//  Created by Zhoulei on 2018/5/9.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceFooter : UIView


@property (strong, nonatomic) UILabel *deviceLb;
@property (strong, nonatomic) UIButton *settingsBtn;


@property (nonatomic, copy) void(^setNvr)(DeviceFooter *footer);
@property (nonatomic, copy) void(^entryMedias)(DeviceFooter *footer);


@property (nonatomic, strong) UIButton *meidiasBtn;

@end
