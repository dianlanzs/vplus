//
//  DeviceFooter.m
//  Kamu
//
//  Created by Zhoulei on 2018/5/9.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "DeviceFooter.h"
#define ICON_CLOUD
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
        
        
        _syncedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        _syncLable = [UILabel labelWithText:@"" withFont:[UIFont systemFontOfSize:14] color:[UIColor blackColor] aligment:NSTextAlignmentLeft];
        
        
        
        
        
        
        //settings
        _settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingsBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);

        [_settingsBtn setTintColor:[UIColor blackColor]];
        UIImage *icon = [[UIImage imageNamed:@"button_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_settingsBtn setImage:icon forState:normal];
        [_settingsBtn setTitle:LS(@"设置") forState:UIControlStateNormal];
        [_settingsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_settingsBtn addTarget:self action:@selector(entrySettings:) forControlEvents:UIControlEventTouchUpInside];
        
        //medias
        _meidiasBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _meidiasBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
        [_meidiasBtn setTintColor:[UIColor blackColor]];
        UIImage *meidaIcon = [[UIImage imageNamed:@"mediaLib_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_meidiasBtn setImage:meidaIcon forState:normal];
        [_meidiasBtn setTitle:LS(@"媒体库") forState:UIControlStateNormal];
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
        
     
#ifdef ICON_CLOUD
        [self addSubview:_syncedIcon];
        [_syncedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leading.equalTo(_deviceLb.mas_trailing).offset(5);
        }];
#else
        [self addSubview:_syncLable];
        [_syncLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(0);
            make.leading.equalTo(_deviceLb.mas_trailing).offset(5);
            
            
        }];
#endif
        

        
        
        
        
        
        
        
        
        
        
        [_settingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.trailing.equalTo(self).offset(-20);

        }];
        
        [_meidiasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
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
