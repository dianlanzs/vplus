//
//  UIView+CustomControlView.m
//  Kamu
//
//  Created by YGTech on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "UIView+ZLCustomControlView.h"
#import <objc/runtime.h>



@implementation UIView (ZLCustomControlView)

- (void)setDelegate:(id<ZLPlayerControlViewDelegate>)delegate {
    
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<ZLPlayerControlViewDelegate>)delegate {
    
    return objc_getAssociatedObject(self, _cmd);
}


/**
 * 设置播放模型
 */
- (void)zf_playerModel:(ZLPlayerModel *)playerModel{}


- (void)zf_playerShowOrHideControlView{}



/**
 * 显示控制层
 */
- (void)zf_playerShowControlView{}


/**
 * 隐藏控制层*/
- (void)zf_playerHideControlView{}




/**
 * 重置ControlView
 */
//- (void)zf_playerResetControlView{}

/**
 * 切换分辨率时重置ControlView
 */
- (void)zf_playerResetControlViewForResolution{}


/**
 * 取消自动隐藏控制层view
 */
- (void)zf_playerCancelAutoFadeOutControlView{}



/**
 * 开始播放（用来隐藏placeholderImageView）
 */
- (void)zf_playerItemPlaying{}




/**
 * 是否有下载功能
 */
- (void)zf_playerHasDownloadFunction:(BOOL)sender{}


/**
 * 是否有切换分辨率功能
 * @param resolutionArray 分辨率名称的数组
 */
- (void)zf_playerResolutionArray:(NSArray *)resolutionArray{}


/**
 * 播放按钮状态 (播放、暂停状态)
 */
//- (void)zf_playerPlayBtnState:(BOOL)state{}





/**
 * 锁定屏幕方向按钮状态
 */
- (void)zf_playerLockBtnState:(BOOL)state{}


/**
 * 下载按钮状态
 */
- (void)zf_playerDownloadBtnState:(BOOL)state{}

/**
 * 加载的菊花
 */
//- (void)zf_playerActivity:(BOOL)animated{}



@end
