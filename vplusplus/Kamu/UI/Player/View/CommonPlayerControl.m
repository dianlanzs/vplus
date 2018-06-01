//
//  CommonPlayerControl.m
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "CommonPlayerControl.h"
#import "UIView+ViewController.h"
#import "PlaybackControl.h"


@interface CommonPlayerControl()
@property (nonatomic, strong) UIView * bottomControl;
@end


@implementation CommonPlayerControl



- (instancetype)initWithControl:(UIView *)bottomControl {
    
    self = [super init];
    if (self) {
        
        [self setBottomControl:bottomControl];
        [self config];
    }
    [self resetControl];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    //        //监听 设备朝向 通知！
    //        [self listeningOrientation];
    
    return self;
    
}

- (void)resetControl {
    if ([self.bottomControl isKindOfClass:[PlaybackControl class]]) {
        PlaybackControl *pbControl = (PlaybackControl *)self.bottomControl;
        pbControl.videoSlider.value = 0;
        pbControl.bottomProgressView.progress = 0;
        pbControl.progressView.progress       = 0;
        pbControl.currentTimeLabel.text       = @"00:00";
        pbControl.totalTimeLabel.text         = @"00:00";
        pbControl.fastView.hidden             = YES;
    }
    self.failBtn.hidden              = YES;
    self.backgroundColor             = [UIColor clearColor];
    self.lockBtn.hidden              = !self.isFullScreen;  //在playView 控制，竖屏隐藏lock button
    [self showControlView];
}




- (instancetype)config {
    
    
        [self addSubview:self.topImageView];
        [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.equalTo(self.mas_top).offset(0);
            make.height.mas_equalTo(60);
        }];
        [self addSubview:self.lockBtn];
        [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.mas_leading).offset(15);
            make.centerY.equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(32);
        }];
        [self addSubview:self.failBtn];
        [self.failBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(150, 40));
        }];
        
        [self addSubview:self.bottomImageView];
        [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.bottom.equalTo(self).offset(0);
            make.height.mas_equalTo(60);
        }];
      
    }
- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView                        = [[UIImageView alloc] init];
        
        [_topImageView addSubview:self.backBtn];
        [_topImageView addSubview:self.titleLabel];
        _topImageView.image                  = ZLPlayerImage(@"ZLPlayer_top_shadow");
        
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_topImageView.mas_leading).offset(10);
            make.top.equalTo(_topImageView.mas_top).offset(20);
            make.width.height.mas_equalTo(40);
        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.backBtn.mas_trailing).offset(5);
            make.centerY.equalTo(self.backBtn.mas_centerY);
        }];
        
        
    }
    return _topImageView;
}
- (UIButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:ZLPlayerImage(@"ZLPlayer_unlock-nor") forState:UIControlStateNormal];
        [_lockBtn setImage:ZLPlayerImage(@"ZLPlayer_lock-nor") forState:UIControlStateSelected];
        [_lockBtn addTarget:self action:@selector(lockScrrenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _lockBtn;
}
- (void)lockScrrenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
//    [self zl_playerShowControlView];//show contorlView 时候要判断一下 ，锁定按钮状态
}
/*
- (void)zl_playerShowControlView {
    [self zl_playerCancelAutoFadeOutControlView]; //cuz 要显示 ，先取消 上一次的自动隐藏 功能
    [self showControlView];
    [self autoFadeOutControlView]; //再过7秒 最终还是隐藏
}
*/




- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:ZLPlayerImage(@"ZLPlayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn setImage:ZLPlayerImage(@"ZLPlayer_shrinkscreen") forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}
- (void)fullScreenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.delegate zl_controlView:self fullScreenAction:sender];
}




- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"测试标题";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}



- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:ZLPlayerImage(@"ZLPlayer_back_full") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
- (void)backBtnClick:(UIButton *)sender {
    [self.vc.navigationController popViewControllerAnimated:YES];
}




- (UIButton *)failBtn {
    if (!_failBtn) {
        _failBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_failBtn setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        [_failBtn addTarget:self action:@selector(failBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failBtn;
}
- (void)failBtnClick:(UIButton *)sender {
    self.failBtn.hidden = YES;
    [self.delegate zl_controlView:self failAction:sender];
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.alpha                  = 1;
        _bottomImageView.image                  = ZLPlayerImage(@"ZLPlayer_bottom_shadow");
         [_bottomImageView addSubview:self.fullScreenBtn];
        [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(30);
            make.trailing.equalTo(_bottomImageView.mas_trailing).offset(-5);
            make.centerY.equalTo(self);
        }];
    }
    return _bottomImageView;
}

- (void)autoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:7];
}
- (void)zl_playerCancelAutoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
- (void)hide {
    [self setHidden:YES];
}
- (void)show {
    [self setHidden:NO];
}


- (void)ms {


//    [self.placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
//    }];



//返回按钮 约束 高度15

//
//    [self.downLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(40);
//        make.height.mas_equalTo(49);
//        make.trailing.equalTo(self.topImageView.mas_trailing).offset(-10);
//        make.centerY.equalTo(self.backBtn.mas_centerY);
//    }];




//    [self.resolutionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(40);
//        make.height.mas_equalTo(25);
//        make.trailing.equalTo(self.downLoadBtn.mas_leading).offset(-10);
//        make.centerY.equalTo(self.backBtn.mas_centerY);
//    }];
//





    
    //锁定按钮
  

//[self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.leading.trailing.bottom.mas_equalTo(0);
//    make.height.mas_equalTo(60);
//}];
}
@end
