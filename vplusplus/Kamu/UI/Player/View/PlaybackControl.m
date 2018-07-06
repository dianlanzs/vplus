//
//  PlaybackControl.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "PlaybackControl.h"
#import "ZLPlayerModel.h"
#import "UIView+EqualMargin.h"
#import "ReactiveObjC.h"
#import "ZLBrightnessView.h"
#import "PlayerControl.h"
#import "CommonPlayerControl.h"
@interface PlaybackControl () <UIGestureRecognizerDelegate, ASValueTrackingSliderDataSource>
//@property (nonatomic, strong) CommonPlayerControl *commonControl;

@end


@implementation PlaybackControl
#pragma mark -  life circle
//- (CommonPlayerControl *)commonControl {
//    if (!_commonControl) {
//        UIResponder *next = self.nextResponder;
//        while (next != nil) {
//            if ([next isKindOfClass:[CommonPlayerControl class]]) {
//                _commonControl = (CommonPlayerControl *)next;
//            }
//            next = next.nextResponder;
//        }
//    }
// return _commonControl;
//    
//}
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        //add new 
        [self.fullScreenBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.bottomImageView).offset(-5);
        }];
        
        [self.bottomImageView addSubview:self.startBtn];
        [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bottomImageView).offset(5);
            make.centerY.equalTo(self.bottomImageView);
            make.width.height.mas_equalTo(30);
        }];
//        [self.bottomImageView  addSubview:self.startBtn];
//        [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//            make.width.height.mas_equalTo(60);
//        }];
        
        
        [self.bottomImageView addSubview:self.currentTimeLabel];
        [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.startBtn.mas_trailing).offset(5);
            make.centerY.equalTo(self.bottomImageView);
            make.width.mas_equalTo(43);
        }];
        [self.bottomImageView addSubview:self.progressView];
        [self.bottomImageView addSubview:self.totalTimeLabel];

        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
            make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
            make.centerY.equalTo(self.currentTimeLabel);
        }];
        [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.fullScreenBtn.mas_leading).offset(3);
            make.centerY.equalTo(self.currentTimeLabel);
            make.width.mas_equalTo(43);
        }];

        [self.bottomImageView addSubview:self.videoSlider];
        [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
            make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
            make.centerY.equalTo(self.currentTimeLabel).offset(-1);
            make.height.mas_equalTo(10);
        }];
       
        [self.bottomImageView addSubview:self.bottomProgressView];
        [self.bottomProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_offset(0);
        }];
        
        
        [self addSubview:self.repeatBtn];
        [self.repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        
        [self addSubview:self.fastView];
        [self.fastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(125);
            make.height.mas_equalTo(80);
            make.center.equalTo(self);
        }];
        
        
        [self resetControl];
        
              
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

#pragma mark - public method


     
//
//- (void)zl_changeSilderValueWithDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview {
//
//    
//
//
//
//}


#pragma mark - Gesture Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGRect rect = [self thumbRect];
    CGPoint point = [touch locationInView:self.videoSlider];
    if ([touch.view isKindOfClass:[UISlider class]]) {
        if (point.x >= rect.origin.x && point.x <= rect.origin.x + rect.size.width  ) {
            return NO;
        }
    }
    return YES;
}
- (CGRect)thumbRect {
    return [self.videoSlider thumbRectForBounds:self.videoSlider.bounds trackRect:[self.videoSlider trackRectForBounds:self.videoSlider.bounds] value:self.videoSlider.value];
}


#pragma mark - Public Method
- (void)zl_playerDraggedEnd {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          self.fastView.hidden = YES;
    });
    
    
    [self setDragged:NO];

}

- (void)zl_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value {
    
    NSInteger proMin = currentTime / 60;
    NSInteger proSec = currentTime % 60;
    NSInteger durMin = totalTime / 60;
    NSInteger durSec = totalTime % 60;
    if (!self.isDragged) {
        self.videoSlider.value           = value;
        NSLog(@"slider %f", self.videoSlider.value);
        self.bottomProgressView.progress = value;
        self.currentTimeLabel.text       = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    }
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}
- (void)playBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.delegate zl_controlView:self playAction:sender];
}




#pragma mark - fast view
- (UIView *)fastView {
    if (!_fastView) {
        _fastView                     = [[UIView alloc] init];
        _fastView.backgroundColor     = RGBA(0, 0, 0, 0.8);
        [_fastView addSubview:self.fastImageView];
        [_fastView addSubview:self.fastTimeLabel];
        [_fastView addSubview:self.fastProgressView];
        
        [self.fastImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(32);
            make.height.mas_offset(32);
            make.top.mas_equalTo(5);
            make.centerX.mas_equalTo(self.fastView.mas_centerX);
        }];
        [self.fastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.with.trailing.mas_equalTo(0);
            make.top.mas_equalTo(self.fastImageView.mas_bottom).offset(2);
        }];
        [self.fastProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(12);
            make.trailing.mas_equalTo(-12);
            make.top.mas_equalTo(self.fastTimeLabel.mas_bottom).offset(10);
        }];
    }
    return _fastView;
}
- (UIImageView *)fastImageView {
    if (!_fastImageView) {
        _fastImageView = [[UIImageView alloc] init];
    }
    return _fastImageView;
}
- (UIProgressView *)fastProgressView {
    if (!_fastProgressView) {
        _fastProgressView                   = [[UIProgressView alloc] init];
        _fastProgressView.progressTintColor = [UIColor whiteColor];
        _fastProgressView.trackTintColor    = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    }
    return _fastProgressView;
}
- (UILabel *)fastTimeLabel {
    if (!_fastTimeLabel) {
        _fastTimeLabel               = [[UILabel alloc] init];
        _fastTimeLabel.textColor     = [UIColor whiteColor];
        _fastTimeLabel.textAlignment = NSTextAlignmentCenter;
        _fastTimeLabel.font          = [UIFont systemFontOfSize:14.0];
    }
    return _fastTimeLabel;
}






- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:ZLPlayerImage(@"ZLPlayer_play") forState:UIControlStateNormal];
        [_startBtn setImage:ZLPlayerImage(@"ZLPlayer_pause") forState:UIControlStateSelected];
        [_startBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (ASValueTrackingSlider *)videoSlider {
    if (!_videoSlider) {
        _videoSlider                       = [[ASValueTrackingSlider alloc] init];
        [_videoSlider setContinuous:YES];
        _videoSlider.popUpViewCornerRadius = 0.0;
        _videoSlider.popUpViewColor = RGBA(19, 19, 9, 1);
        _videoSlider.popUpViewArrowLength = 8;
        
        
        
         _videoSlider.dataSource = self;

        
        
        
        [_videoSlider setThumbImage:ZLPlayerImage(@"滑动") forState:UIControlStateNormal];
        _videoSlider.maximumValue          = 1;
        _videoSlider.minimumTrackTintColor = [UIColor redColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
        
        
        
        
        [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        
        
        
        
        
        ///tap  & pan gesture for slider
        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
        [_videoSlider addGestureRecognizer:sliderTap];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
        panRecognizer.delegate = self;
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelaysTouchesBegan:YES];
        [panRecognizer setDelaysTouchesEnded:YES];
        [panRecognizer setCancelsTouchesInView:YES];
        [_videoSlider addGestureRecognizer:panRecognizer];
    }
    return _videoSlider;
}




- (void)progressSliderTouchBegan:(ASValueTrackingSlider *)sender {
//    [(PlayerControl *)self.superview zl_playerCancelAutoFadeOutControlView];
//    self.videoSlider.popUpView.hidden = YES;
//    [self.delegate zl_controlView:self progressSliderTouchBegan:sender]; // not implemt
}



- (void)progressSliderValueChanged:(ASValueTrackingSlider *)slider {
//    [self.delegate zl_controlView:self progressSliderValueChanged:sender];
    
  
    
    
}
- (void)progressSliderTouchEnded:(ASValueTrackingSlider *)sender {
    [self.delegate zl_controlView:self progressSliderTouchEnded:sender];
    
   
    
}


- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        // 视频跳转的value
        CGFloat tapValue = point.x / slider.frame.size.width;
        if ([self.delegate respondsToSelector:@selector(zl_controlView:progressSliderTap:)]) {
            [self.delegate zl_controlView:self progressSliderTap:tapValue]; //跳转
        }
    }
}

// 不做处理，只是为了滑动slider其他地方不响应其他手势
- (void)panRecognizer:(UIPanGestureRecognizer *)sender {}


















#pragma mark - fast & progress view



- (UIProgressView *)bottomProgressView {
    if (!_bottomProgressView) {
        _bottomProgressView                   = [[UIProgressView alloc] init];
        _bottomProgressView.progressTintColor = [UIColor whiteColor];
        _bottomProgressView.trackTintColor    = [UIColor clearColor];
    }
    return _bottomProgressView;
}
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor    = [UIColor clearColor];
    }
    return _progressView;
}



#pragma mark - time label

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}
- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel               = [[UILabel alloc] init];
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

//repeat play
- (UIButton *)repeatBtn {
    if (!_repeatBtn) {
        _repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatBtn setImage:ZLPlayerImage(@"ZLPlayer_repeat_video") forState:UIControlStateNormal];
        [_repeatBtn addTarget:self action:@selector(repeatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _repeatBtn;
}
- (void)repeatBtnClick:(UIButton *)sender {
    [self resetControl];
    [self.delegate zl_controlView:self repeatPlayAction:sender];
}

- (void)showControl {
    
    [super showControl];
    self.bottomProgressView.alpha = 0;
    [self setShowing:YES];

}
- (void)hideControl {
    [super hideControl];
    self.bottomProgressView.alpha = 1;

    // 隐藏resolutionView
    //    self.resolutionBtn.selected = YES;
    //    [self resolutionBtnClick:self.resolutionBtn];
    //    if (self.isFullScreen && !self.playeEnd && !self.isShrink) {
    //        ZFPlayerShared.isStatusBarHidden = YES;
    //    }
    [self setShowing:NO];
}
- (void)resetControl {
    
    [super resetControl];
    self.fastView.hidden             = YES;
    self.repeatBtn.hidden            = YES;
    self.videoSlider.value = 0;
    self.bottomProgressView.progress = 0;
    self.progressView.progress       = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
  
    [self.startBtn setSelected:YES];
}


- (void)setFullScreen:(BOOL)fullScreen {
    
    [super setFullScreen:fullScreen];
    
    
}
- (void)setState:(ZLPlayerState)state {
    
    [super setState:state];
    if (state == ZLPlayerStatePlaying) {
        [(ZLPlayerView *)self.superview createPanGesture];
    }
    
    else if (state == ZLPlayerStateEnd) {
            [self hideControl];
        [self.startBtn setSelected:NO];

            self.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            [self.repeatBtn setHidden:NO];
            self.topImageView.alpha       = 1;
            self.bottomProgressView.alpha = 0;
            [ZLBrightnessView sharedBrightnessView].isStatusBarHidden = NO;
    }
    
    else if (state == ZLPlayerStatePause) {
        [self showControl];
    }
    


}


//
//- (CommonPlayerControl *)getRootControl{
//
//    UIResponder *next = self.nextResponder;
//    while (next != nil) {
//        if ([next isKindOfClass:[CommonPlayerControl class]]) {
//            CommonPlayerControl *root = (CommonPlayerControl *)next;
//            return root;
//        }
//        next = next.nextResponder;
//    }
//    return nil;
//}
//- (CommonPlayerControl *)getRootControl{
//
//    UIView *next = self.superview;
//    while (next != nil) {
//        if ([next isKindOfClass:[CommonPlayerControl class]]) {
//            CommonPlayerControl *root = (CommonPlayerControl *)next;
//            return root;
//        }
//        next = next.superview;
//    }
//    return nil;
//}
@end
