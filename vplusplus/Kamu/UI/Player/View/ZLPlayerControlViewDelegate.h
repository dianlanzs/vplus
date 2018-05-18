//
//  ZLPlayerControlViewDelegate.h
//  Kamu
//
//  Created by YGTech on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#ifndef ZLPlayerControlViewDelegate_h
#define ZLPlayerControlViewDelegate_h


#endif /* ZLPlayerControlViewDelegate_h */
@protocol ZLPlayerControlViewDelegate <NSObject>


#pragma mark - Action命令 触发事件
@optional
/** 返回按钮事件 */
- (void)zl_controlView:(UIView *)controlView backAction:(UIButton *)sender;

/** cell播放中小屏状态 关闭按钮事件 */
//- (void)zl_controlView:(UIView *)controlView closeAction:(UIButton *)sender;


/** 播放按钮事件 */
- (void)zl_controlView:(UIView *)controlView playAction:(UIButton *)sender;


/** 全屏按钮事件 */
- (void)zl_controlView:(UIView *)controlView fullScreenAction:(UIButton *)sender;

/** 锁定屏幕方向按钮事件 */
- (void)zl_controlView:(UIView *)controlView lockScreenAction:(UIButton *)sender;

/** 静音按钮事件 */
- (void)zl_controlView:(UIView *)controlView muteAction:(UIButton *)sender;

/** 重播按钮事件 */
//- (void)zl_controlView:(UIView *)controlView repeatPlayAction:(UIButton *)sender;

/** 中间播放按钮事件 */
- (void)zl_controlView:(UIView *)controlView centerPlayAction:(UIButton *)sender;

/** 加载失败按钮事件 */
//- (void)zl_controlView:(UIView *)controlView failAction:(UIButton *)sender;

/** 下载按钮事件 */
- (void)zl_controlView:(UIView *)controlView downloadVideoAction:(UIButton *)sender;

/** 切换分辨率按钮事件 */
- (void)zl_controlView:(UIView *)controlView resolutionAction:(UIButton *)sender;

/** slider的点击事件（点击slider控制进度） */
//- (void)zl_controlView:(UIView *)controlView progressSliderTap:(CGFloat)value;

/** 开始触摸slider */
//- (void)zl_controlView:(UIView *)controlView progressSliderTouchBegan:(UISlider *)slider;

/** slider触摸中 */
//- (void)zl_controlView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider;

/** slider触摸结束 */
//- (void)zl_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider;




//turn on speaker
- (void)zl_controlView:(UIView *)controlView speakerAction:(UIButton *)sender;


///MARK:存储API
- (void)zl_controlView:(UIView *)controlView snapAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView recordVideoAction:(UIButton *)sender;

/** 加载失败按钮事件 */
- (void)zl_controlView:(UIView *)controlView failAction:(UIButton *)sender;







//============================ 控制层 state notify =============================

/** 控制层即将显示 */
- (void)zl_controlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen;

/** 控制层即将隐藏 */
- (void)zl_controlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen;




//录制声音
- (void)recordStart:(UIButton *)sender;
- (void)recordEnd:(UIButton *)sender;
- (void)recordCancel:(UIButton *)sender;
@end
