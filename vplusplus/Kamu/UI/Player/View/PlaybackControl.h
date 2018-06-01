//
//  PlaybackControl.h
//  Kamu
//
//  Created by Zhoulei on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPlayerControlViewDelegate.h"
#import "CommonPlayerControl.h"
#import "ASValueTrackingSlider.h"

@protocol PlaybackControlDelegate <NSObject>
- (void)zl_controlView:(UIView *)controlView progressSliderTap:(CGFloat)value;
- (void)zl_controlView:(UIView *)controlView progressSliderTouchBegan:(UISlider *)slider;
- (void)zl_controlView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider;
- (void)zl_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider;

- (void)zl_controlView:(UIView *)controlView playAction:(UIButton *)sender;

@end



@interface PlaybackControl : UIView
@property (nonatomic, weak) id<PlaybackControlDelegate> delegate;
@property (nonatomic, strong) CommonPlayerControl *commonControl;

@property (nonatomic, assign, getter=isDragged) BOOL  dragged;
@property (nonatomic, strong) UIButton                *startBtn;
@property (nonatomic, strong) UILabel                 *currentTimeLabel;
@property (nonatomic, strong) UILabel                 *totalTimeLabel;

@property (nonatomic, strong) UIProgressView          *progressView;
@property (nonatomic, strong) ASValueTrackingSlider   *videoSlider;


@property (nonatomic, strong) UIView                  *fastView;
@property (nonatomic, strong) UIProgressView          *fastProgressView;
@property (nonatomic, strong) UILabel                 *fastTimeLabel;
@property (nonatomic, strong) UIImageView             *fastImageView;
/** 控制层消失时候在底部显示的播放进度progress */
@property (nonatomic, strong) UIProgressView          *bottomProgressView;

- (void)zl_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;
- (void)zl_playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview;
- (void)zl_playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image;
- (void)zl_playerDraggedEnd;
@end
