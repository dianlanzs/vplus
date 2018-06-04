//
//  PlaybackControl.h
//  Kamu
//
//  Created by Zhoulei on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+PlayerControl.h"
#import "ASValueTrackingSlider.h"







@interface PlaybackControl : UIView



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
@property (nonatomic, strong) UIButton                *repeatBtn;


@end
