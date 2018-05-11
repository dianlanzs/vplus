//
//  ZLPlayerControlView.h
//  Kamu
//
//  Created by YGTech on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPlayerControlViewDelegate.h"

@interface ZLPlayerControlView : UIView


@property (nonatomic, strong) UIButton                *muteBtn;



@property (nonatomic, strong) UIButton          *speakerBtn_horizental;
@property (nonatomic, strong) MRoundedButton          *speakerBtn_vertical;





/** 播放按钮状态 */
//- (void)zl_playerPlayBtnState:(BOOL)state;


/** topView */
@property (nonatomic, strong) UIImageView             *topImageView;
/** 锁定屏幕方向按钮 */
@property (nonatomic, strong) UIButton                *lockBtn;




@property (nonatomic, assign) UIInterfaceOrientation  orientation;

- (void)makeConstraints;
@end
