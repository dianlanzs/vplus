//
//  ZLPlayerControlViewDelegate.h
//  Kamu
//
//  Created by Zhoulei on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#ifndef ZLPlayerControlViewDelegate_h
#define ZLPlayerControlViewDelegate_h


#endif /* ZLPlayerControlViewDelegate_h */
@protocol ZLPlayerControlViewDelegate <NSObject>


#pragma mark - Action命令 触发事件
@optional
/** 返回按钮事件 */

/** cell播放中小屏状态 关闭按钮事件 */
//- (void)zl_controlView:(UIView *)controlView closeAction:(UIButton *)sender;


/** 播放按钮事件 */


/** 全屏按钮事件 */

/** 锁定屏幕方向按钮事件 */

/** 静音按钮事件 */

/** 重播按钮事件 */
//- (void)zl_controlView:(UIView *)controlView repeatPlayAction:(UIButton *)sender;

/** 中间播放按钮事件 */
- (void)zl_controlView:(UIView *)controlView centerPlayAction:(UIButton *)sender;


/** 下载按钮事件 */
- (void)zl_controlView:(UIView *)controlView downloadVideoAction:(UIButton *)sender;

/** 切换分辨率按钮事件 */
- (void)zl_controlView:(UIView *)controlView resolutionAction:(UIButton *)sender;






//turn on speaker


/** 加载失败按钮事件 */







//============================ 控制层 state notify =============================

/** 控制层即将显示 */
- (void)zl_controlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen;

/** 控制层即将隐藏 */
- (void)zl_controlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen;




//录制声音
















@end
