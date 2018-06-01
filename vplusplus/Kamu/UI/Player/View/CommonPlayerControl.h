//
//  CommonPlayerControl.h
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CommonControlDelegate <NSObject>

- (void)zl_controlView:(UIView *)controlView backAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView fullScreenAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView lockScreenAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView failAction:(UIButton *)sender;
@end





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


@property (nonatomic, strong) id <CommonControlDelegate> delegate;


@end
