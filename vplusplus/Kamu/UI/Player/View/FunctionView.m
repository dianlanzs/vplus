//
//  FunctionView.m
//  Kamu
//
//  Created by YGTech on 2018/1/17.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "FunctionView.h"

@interface FunctionView()

@property (nonatomic, strong) UIButton  *wifiBtn;
@property (nonatomic, strong) UIButton  *batteryBtn;
@property (nonatomic, strong) UIButton  *usbDiskBtn;
@property (nonatomic, strong) UIButton  *settingsBtn;



@end






@implementation FunctionView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    
    if (self) {
        
        
        [self addSubview:self.wifiBtn];
        [self addSubview:self.batteryBtn];
        [self addSubview:self.usbDiskBtn];
//        [self addSubview:self.settingsBtn];
        
        
    }
    
    return self;
}

- (void)layoutSubviews {
    // 添加子控件的约束
    [self setConstraints];
}
- (void)setConstraints {
    
    CGFloat padding = 10.f;
    CGFloat btnW = 20.f;
    CGFloat btnH = 20.f;

    
    [self.wifiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(0 *(padding + btnW) + 12.f);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnW, btnH));
    }];
    
    
    
    [self.batteryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(1 *(padding + btnW) + 12.f);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnW, btnH));
    }];
    
    
    
    [self.usbDiskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(2 *(padding + btnW)  + 12.f);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(btnW, btnH));
    }];
    
//
//    [self.settingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.equalTo(self).offset(0 *(padding + btnW) + (-12.f));
//        make.centerY.equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(btnW, btnH));
//    }];
//
    
    
}

#pragma mark - Required!
- (UIButton *)wifiBtn {
    
    if (!_wifiBtn) {
        
        _wifiBtn = [[UIButton alloc] init];
        [_wifiBtn setImage:[UIImage imageNamed:@"button_wifi_normal"] forState:UIControlStateNormal];
    }
    
    return _wifiBtn;
}



- (UIButton *)batteryBtn {
    
    if (!_batteryBtn) {
        
        _batteryBtn = [[UIButton alloc] init];
        [_batteryBtn setImage:[UIImage imageNamed:@"button_battery_normal"] forState:UIControlStateNormal];
    }
    
    return _batteryBtn;
}

- (UIButton *)usbDiskBtn {
    
    if (!_usbDiskBtn) {
        
        _usbDiskBtn = [[UIButton alloc] init];
        [_usbDiskBtn setImage:[UIImage imageNamed:@"button_uDisk_normal"] forState:UIControlStateNormal];
    }
    
    return _usbDiskBtn;
}

//- (UIButton *)settingsBtn {
//
//    if (!_settingsBtn) {
//
//        _settingsBtn = [[UIButton alloc] init];
//
//        UIImage *btn_settings = [[UIImage imageNamed:@"button_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        [_settingsBtn setTintColor:[UIColor whiteColor]];
//        [_settingsBtn setImage:btn_settings forState:UIControlStateNormal];
//        [_settingsBtn addTarget:self action:@selector(settingsBtn:) forControlEvents:UIControlEventTouchUpInside];
//    }
//
//    return _settingsBtn;
//}
//- (void)settingsBtn:(id)sender {
//    self.signal_settings(sender);
//}
@end
