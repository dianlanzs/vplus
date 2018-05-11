//
//  UIView+CustomControlView.h
//  Kamu
//
//  Created by YGTech on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPlayerControlViewDelegate.h"
#import "ZLPlayerModel.h"

#import "ZLPlayer.h"



@interface UIView (ZLCustomControlView)


//代理对象
@property (nonatomic, weak) id<ZLPlayerControlViewDelegate> delegate;



/**
 * 设置播放模型
 */
- (void)zl_playerModel:(ZLPlayerModel *)playerModel;

- (void)zl_playerShowOrHideControlView;


/**
 * 显示控制层
 */
- (void)zl_playerShowControlView;

/**
 * 隐藏控制层*/
- (void)zl_playerHideControlView;



/**
 * 重置ControlView
 */
//- (void)zl_playerResetControlView;

/**
 * 切换分辨率时重置ControlView
 */
- (void)zl_playerResetControlViewForResolution;

/**
 * 取消自动隐藏控制层view
 */
- (void)zl_playerCancelAutoFadeOutControlView;


/**
 * 开始播放（用来隐藏placeholderImageView）
 */
- (void)zl_playerItemPlaying;



/**
 * 是否有下载功能
 */
- (void)zl_playerHasDownloadFunction:(BOOL)sender;

/**
 * 是否有切换分辨率功能
 * @param resolutionArray 分辨率名称的数组
 */
- (void)zl_playerResolutionArray:(NSArray *)resolutionArray;

/**
 * 播放按钮状态 (播放、暂停状态)
 */
//- (void)zl_playerPlayBtnState:(BOOL)state;





/**
 * 锁定屏幕方向按钮状态
 */
- (void)zl_playerLockBtnState:(BOOL)state;

/**
 * 下载按钮状态
 */
- (void)zl_playerDownloadBtnState:(BOOL)state;

/**
 * 加载的菊花
 */
//- (void)zl_playerActivity:(BOOL)animated;



@end
