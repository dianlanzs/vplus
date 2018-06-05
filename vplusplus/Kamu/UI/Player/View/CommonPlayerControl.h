//
//  CommonPlayerControl.h
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>



#import "UIView+PlayerControl.h"


@interface CommonPlayerControl : UIView
@property (nonatomic, strong) UIButton                *lockBtn;
@property (nonatomic, strong) UIImageView             *topImageView;
@property (nonatomic, assign) UIInterfaceOrientation  orientation;

@property (nonatomic, strong) UILabel                 *titleLabel;


@property (nonatomic, strong) UIButton                *fullScreenBtn;
@property (nonatomic, strong) UIButton                *backBtn;
@property (nonatomic, strong) UIButton                *failBtn;

@property (nonatomic, assign, getter=isShowing) BOOL  showing;
@property (nonatomic, strong) UIImageView             *bottomImageView;

//middle
@property (nonatomic, strong) UIButton                *repeatBtn;
@property (nonatomic, strong) UIView                  *fastView;

@property (nonatomic, strong) UIProgressView          *fastProgressView;
@property (nonatomic, strong) UILabel                 *fastTimeLabel;
@property (nonatomic, strong) UIImageView             *fastImageView;




@property (nonatomic, strong) UIView                 *functionControl;

- (void)autoFadeOutControlView;
- (void)hideCommonControl;
- (void)showCommonControl;
- (instancetype)initWithFunction:(UIView *)function;
@end
