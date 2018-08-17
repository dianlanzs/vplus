//
//  ZLMaskView.m
//  Kamu
//
//  Created by YGTech on 2018/8/1.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "ZLMaskView.h"

@implementation ZLMaskView

- (instancetype)init {
    self = [super init];
    if(self) {
        [self addSubview:self.blurEffectView];
        [self addSubview:self.statusLabel];
        [self addSubview:self.spinner];
        [self.blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
        
        [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.statusLabel.mas_trailing).offset(5.f);
            make.centerY.equalTo(self.statusLabel);
        }];
        //        [_maskView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]]; //彩色mask no effect!
        
    }
    
    return self;
}


- (UIVisualEffectView *)blurEffectView {
    if(!_blurEffectView) {
        
        UIBlurEffect *effect =  [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _blurEffectView.alpha = 0.8;
    }
    
    return _blurEffectView;
}
- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [UILabel labelWithText:LS(@"正在获取设备状态...") withFont:[UIFont systemFontOfSize:18.f] color:[UIColor whiteColor] aligment:NSTextAlignmentCenter];
    }
    return _statusLabel;
}
- (RTSpinKitView *)spinner {
    if (!_spinner) {
        _spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArc color:[UIColor whiteColor] spinnerSize:20.f];
        [_spinner setHidesWhenStopped:YES];
    }
    return _spinner;
}
@end
