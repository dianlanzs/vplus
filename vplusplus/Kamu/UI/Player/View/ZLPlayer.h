//
//  ZLPlayer.h
//  Kamu
//
//  Created by YGTech on 2018/1/18.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#ifndef ZLPlayer_h
#define ZLPlayer_h


#endif /* ZLPlayer_h */




#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

// 监听TableView的contentOffset
#define kZLPlayerViewContentOffset          @"contentOffset"
// player的单例
#define ZLPlayerShared                      [ZLBrightnessView sharedBrightnessView]
// 屏幕的宽
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
// 屏幕的高
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
// 颜色值RGB
#define RGBA(r,g,b,a)                       [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
// 图片路径
#define ZLPlayerSrcName(file)               [@"ZLPlayer.bundle" stringByAppendingPathComponent:file]

#define ZLPlayerFrameworkSrcName(file)      [@"Frameworks/ZLPlayer.framework/ZLPlayer.bundle" stringByAppendingPathComponent:file]

#define ZLPlayerImage(file)                 [UIImage imageNamed:ZLPlayerSrcName(file)] ? :[UIImage imageNamed:ZLPlayerFrameworkSrcName(file)]

#define ZLPlayerOrientationIsLandscape      UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)

#define ZLPlayerOrientationIsPortrait       UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)


#import "ZLPlayerView.h"
#import "ZLPlayerModel.h"
#import "ZLPlayerControlView.h"
#import "ZLBrightnessView.h"
#import "UIViewController+ZLPlayerRotation.h"
//#import "UIImageView+ZLCache.h"
#import "UIWindow+ZLCurrentViewController.h"
#import "ZLPlayerControlViewDelegate.h"
