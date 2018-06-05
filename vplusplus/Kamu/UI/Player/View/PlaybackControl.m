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
@property (nonatomic, strong) CommonPlayerControl *commonControl;

@end


@implementation PlaybackControl
#pragma mark -  life circle
- (CommonPlayerControl *)commonControl {
    if (!_commonControl) {
        UIResponder *next = self.nextResponder;
        while (next != nil) {
            if ([next isKindOfClass:[CommonPlayerControl class]]) {
                _commonControl = (CommonPlayerControl *)next;
            }
            next = next.nextResponder;
        }
    }
 return _commonControl;
    
}
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self addSubview:self.startBtn];
        [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(5);
            make.centerY.equalTo(self);
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
            make.trailing.equalTo(self).offset(3);
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
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02lu:%02zd", (long)proMin, proSec];
    [self.videoSlider setImage:image];
    [self.videoSlider setText:currentTimeStr];
    self.commonControl.fastView.hidden = YES;
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
          self.commonControl.fastImageView.image = ZLPlayerImage(@"ZFPlayer_fast_forward");
    } else {
         self.commonControl.fastImageView.image = ZLPlayerImage(@"ZFPlayer_fast_backward");
    }
    self.commonControl.fastView.hidden           = preview;
    self.commonControl.fastTimeLabel.text        = timeStr;
    self.commonControl.fastProgressView.progress = draggedValue;
}


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
          self.commonControl.fastView.hidden = YES;
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
        [_videoSlider setContinuous:YES];
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
//    [(PlayerControl *)self.superview zl_playerCancelAutoFadeOutControlView];
//    self.videoSlider.popUpView.hidden = YES;
//    [self.delegate zl_controlView:self progressSliderTouchBegan:sender]; // not implemt
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





- (void)resetFuncControl {
    self.videoSlider.value = 0;
    self.bottomProgressView.progress = 0;
    self.progressView.progress       = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
  
    [self.startBtn setSelected:YES];
}
- (void)zl_playEnd {
    
    [self.startBtn setSelected:NO];
    [self.commonControl.repeatBtn setHidden:NO];
//    [self hideCommonControl]; /// MARK: turn out : no effect!!!!!!!
    [self.commonControl.bottomImageView setHidden:YES];
    [self.commonControl.topImageView setHidden:YES];
    self.commonControl.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [ZLBrightnessView sharedBrightnessView].isStatusBarHidden = NO;
    self.bottomProgressView.alpha = 0;
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
