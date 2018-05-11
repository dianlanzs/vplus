//
//  DeviceFooter.m
//  Kamu
//
//  Created by YGTech on 2018/5/9.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "DeviceFooter.h"
#import "NSString+StringFrame.h"

@implementation DeviceFooter


- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        _deviceLb = [[UILabel alloc] initWithFrame:CGRectZero];
        [_deviceLb setFont:[UIFont systemFontOfSize:18.0f]];
        
        //settings
        _settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingsBtn setTintColor:[UIColor blackColor]];
        UIImage *icon = [[UIImage imageNamed:@"button_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_settingsBtn setImage:icon forState:normal];
        [_settingsBtn setTitle:@"settings" forState:UIControlStateNormal];
        [_settingsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_settingsBtn addTarget:self action:@selector(entrySettings:) forControlEvents:UIControlEventTouchUpInside];
        
        //medias
        _meidiasBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_meidiasBtn setTintColor:[UIColor blackColor]];
        UIImage *meidaIcon = [[UIImage imageNamed:@"mediaLib_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_meidiasBtn setImage:meidaIcon forState:normal];
        [_meidiasBtn setTitle:@"medias" forState:UIControlStateNormal];
        [_meidiasBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_meidiasBtn addTarget:self action:@selector(entryMedias:) forControlEvents:UIControlEventTouchUpInside];
        
        [self  addSubview:_settingsBtn];
        [self addSubview:_meidiasBtn];
        [self addSubview:_deviceLb];
        
        
        
        
        [_deviceLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([@"foo" boundingRectWithFont:[UIFont systemFontOfSize:18.f]]  + 5.f);
            make.centerY.equalTo(self);
            make.leading.equalTo(self).offset(15.f);
        }];
        
        [_settingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(100, 40.f));
            make.trailing.equalTo(self.mas_trailing).offset(-10.f);
        }];
        
        [_meidiasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);//centerY
            make.size.mas_equalTo(CGSizeMake(100, 40.f));
//            make.trailing.equalTo(_settingsBtn).offset(-150.f);
        }];
        
    }
    
    
    return self;
}

- (void)entrySettings:(UIButton *)entry {
    self.setNvr(self);
}
- (void)entryMedias:(UIButton *)entry {
    self.entryMedias(self);
}
@end
