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
@interface PlaybackControl () <UIGestureRecognizerDelegate>


@end


@implementation PlaybackControl
#pragma mark -  life circle
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self addSubview:self.startBtn];
        [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.mas_leading).offset(5);
            make.bottom.equalTo(self.mas_bottom).offset(-5);
            make.width.height.mas_equalTo(30);
        }];
       
        [self addSubview:self.currentTimeLabel];
        [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.startBtn.mas_trailing).offset(-3);
            make.centerY.equalTo(self.startBtn.mas_centerY);
            make.width.mas_equalTo(43);
        }];
        [self addSubview:self.progressView];
        [self addSubview:self.totalTimeLabel];

        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
            make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
            make.centerY.equalTo(self.startBtn.mas_centerY);
        }];
        [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.commonControl.fullScreenBtn.mas_leading).offset(3);
            make.centerY.equalTo(self.startBtn.mas_centerY);
            make.width.mas_equalTo(43);
        }];

        [self addSubview:self.videoSlider];
        [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
            make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
            make.centerY.equalTo(self.currentTimeLabel.mas_centerY).offset(-1);
            make.height.mas_equalTo(10);
        }];
        [self addSubview:self.fastView];
        [self.fastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(125);
            make.height.mas_equalTo(80);
            make.center.equalTo(self);
        }];
        [self addSubview:self.bottomProgressView];
        [self.bottomProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_offset(0);
            make.bottom.mas_offset(0);
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

#pragma mark - public method
- (void)zl_playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image; {
    NSInteger proMin = draggedTime / 60;//当前秒
    NSInteger proSec = draggedTime % 60;//当前分钟
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    [self.videoSlider setImage:image];
    [self.videoSlider setText:currentTimeStr];
    self.fastView.hidden = YES;
}
- (void)zl_playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview {
    //    [self.activity stopAnimating];
    NSInteger proMin = draggedTime / 60;
    NSInteger proSec = draggedTime % 60;
    NSInteger durMin = totalTime / 60;
    NSInteger durSec = totalTime % 60;
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    NSString *totalTimeStr   = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    CGFloat  draggedValue    = (CGFloat)draggedTime/(CGFloat)totalTime;
    NSString *timeStr        = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totalTimeStr];
    self.videoSlider.popUpView.hidden = !preview;
    self.videoSlider.value            = draggedValue;
    self.bottomProgressView.progress  = draggedValue;
    self.currentTimeLabel.text        = currentTimeStr;
    self.dragged = YES;  //Middle UI
    if (forawrd) {
        self.fastImageView.image = ZLPlayerImage(@"ZFPlayer_fast_forward");
    } else {
        self.fastImageView.image = ZLPlayerImage(@"ZFPlayer_fast_backward");
    }
    self.fastView.hidden           = preview;
    self.fastTimeLabel.text        = timeStr;
    self.fastProgressView.progress = draggedValue;
}


#pragma mark - Gesture Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGRect rect = [self thumbRect]; //(77 34; 221 11)  60 -15 = 35  thumb1 (CGRect) rect = (origin = (x = -10, y = -2), size = (width = 30, height = 30))
    CGPoint point = [touch locationInView:self.videoSlider];
    if ([touch.view isKindOfClass:[UISlider class]]) {
        if (point.x >= rect.origin.x && point.x <= rect.origin.x + rect.size.width  ) {
            return NO;// 如果在滑块上点击就不响应pan手势
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
    [self.startBtn setSelected:YES];
    [(PlayerControl *)self.superview autoFadeOutControlView];
}

- (void)zl_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value {
    NSInteger proMin = currentTime / 60;
    NSInteger proSec = currentTime % 60;
    NSInteger durMin = totalTime / 60;
    NSInteger durSec = totalTime % 60;
    if (!self.isDragged) {
        self.videoSlider.value           = value;
        self.bottomProgressView.progress = value;
        self.currentTimeLabel.text       = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    }
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}
- (void)playBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.delegate zl_controlView:self playAction:sender];
}






#pragma mark - getter
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
        [_videoSlider setContinuous:NO];
        _videoSlider.popUpViewCornerRadius = 0.0;
        _videoSlider.popUpViewColor = RGBA(19, 19, 9, 1);
        _videoSlider.popUpViewArrowLength = 8;
        [_videoSlider setThumbImage:ZLPlayerImage(@"滑动") forState:UIControlStateNormal];
        _videoSlider.maximumValue          = 1;
        _videoSlider.minimumTrackTintColor = [UIColor redColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        //tap  & pan gesture for slider
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
    [(PlayerControl *)self.superview zl_playerCancelAutoFadeOutControlView];
    self.videoSlider.popUpView.hidden = YES;
    [self.delegate zl_controlView:self progressSliderTouchBegan:sender];
}

- (void)progressSliderValueChanged:(ASValueTrackingSlider *)sender {
    [self.delegate zl_controlView:self progressSliderValueChanged:sender];
}
- (void)progressSliderTouchEnded:(ASValueTrackingSlider *)sender {
    [self.delegate zl_controlView:self progressSliderTouchEnded:sender];
    
}
- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        if ([self.delegate respondsToSelector:@selector(zl_controlView:progressSliderTap:)]) {
            [self.delegate zl_controlView:self progressSliderTap:tapValue]; //跳转
        }
    }
}

// 不做处理，只是为了滑动slider其他地方不响应其他手势
- (void)panRecognizer:(UIPanGestureRecognizer *)sender {}




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
- (UILabel *)fastTimeLabel {
    if (!_fastTimeLabel) {
        _fastTimeLabel               = [[UILabel alloc] init];
        _fastTimeLabel.textColor     = [UIColor whiteColor];
        _fastTimeLabel.textAlignment = NSTextAlignmentCenter;
        _fastTimeLabel.font          = [UIFont systemFontOfSize:14.0];
    }
    return _fastTimeLabel;
}
- (UIProgressView *)fastProgressView {
    if (!_fastProgressView) {
        _fastProgressView                   = [[UIProgressView alloc] init];
        _fastProgressView.progressTintColor = [UIColor whiteColor];
        _fastProgressView.trackTintColor    = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    }
    return _fastProgressView;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}
- (UIProgressView *)bottomProgressView {
    if (!_bottomProgressView) {
        _bottomProgressView                   = [[UIProgressView alloc] init];
        _bottomProgressView.progressTintColor = [UIColor whiteColor];
        _bottomProgressView.trackTintColor    = [UIColor clearColor];
    }
    return _bottomProgressView;
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

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor    = [UIColor clearColor];
    }
    return _progressView;
}

@end