//
//  LivePlayControl.h
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonPlayerControl.h"



@protocol LivePlayDelegate <NSObject>
@optional
- (void)zl_controlView:(UIView *)controlView muteAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView speakerAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView snapAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView recordVideoAction:(UIButton *)sender;
- (void)recordStart:(UIButton *)sender;
- (void)recordEnd:(UIButton *)sender;
- (void)recordCancel:(UIButton *)sender;
@end




@interface LivePlayControl : UIView

@property (nonatomic, strong) CommonPlayerControl *commonControl;
@property (nonatomic, strong) id<LivePlayDelegate> delegate;

@property (nonatomic, strong) UIButton                *muteBtn;

@property (nonatomic, strong) UIButton          *speakerBtn_horizental;
@property (nonatomic, strong) MRoundedButton          *speakerBtn_vertical;

@property (nonatomic, strong) UIButton                *recordBtn;
@property (nonatomic, strong) UIButton                *captureBtn;






@end
