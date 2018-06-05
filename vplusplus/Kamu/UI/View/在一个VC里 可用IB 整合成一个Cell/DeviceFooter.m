//
//  DeviceFooter.m
//  Kamu
//
//  Created by Zhoulei on 2018/5/9.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "DeviceFooter.h"

@implementation DeviceFooter


- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        _deviceLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _deviceLb.textAlignment = NSTextAlignmentCenter;
        /*
        [_deviceLb.layer setCornerRadius:5.f];
        [_deviceLb.layer setMasksToBounds:YES];
        [_deviceLb.layer setBorderWidth:1.f];
        */
        [_deviceLb setFont:[UIFont boldSystemFontOfSize:21.f]];
        
        //settings
        _settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingsBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);

        [_settingsBtn setTintColor:[UIColor blackColor]];
        UIImage *icon = [[UIImage imageNamed:@"button_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_settingsBtn setImage:icon forState:normal];
        [_settingsBtn setTitle:@"settings" forState:UIControlStateNormal];
        [_settingsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_settingsBtn addTarget:self action:@selector(entrySettings:) forControlEvents:UIControlEventTouchUpInside];
        
        //medias
        _meidiasBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _meidiasBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
        [_meidiasBtn setTintColor:[UIColor blackColor]];
        UIImage *meidaIcon = [[UIImage imageNamed:@"mediaLib_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_meidiasBtn setImage:meidaIcon forState:normal];
        [_meidiasBtn setTitle:@"medias" forState:UIControlStateNormal];
        [_meidiasBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_meidiasBtn addTarget:self action:@selector(entryMedias:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_settingsBtn];
        [self addSubview:_meidiasBtn];
        [self addSubview:_deviceLb];
        
        
        
        
        [_deviceLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
//            make.size.mas_equalTo(CGSizeMake(200, [@"foo" boundingRectWithFont:[UIFont systemFontOfSize:18.f]]  + 5.f));
            make.leading.equalTo(self).offset(20);
        }];
        
        [_settingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(100, 40.f));
            make.trailing.equalTo(self).offset(-20);

        }];
        
        [_meidiasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(100, 40.f));
            make.trailing.equalTo(_settingsBtn.mas_leading).offset(-10);

        }];
//        [self distributeSpacingHorizontallyWith:@[_deviceLb,_meidiasBtn,_settingsBtn]];
        
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
