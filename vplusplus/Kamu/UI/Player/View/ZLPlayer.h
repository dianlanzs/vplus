//
//  ZLPlayer.h
//  Kamu
//
//  Created by Zhoulei on 2018/1/18.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#ifndef ZLPlayer_h
#define ZLPlayer_h


#endif /* ZLPlayer_h */




#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

// 监听TableView的contentOffset
#define kZLPlayerViewContentOffset          @"contentOffset"





#import "ZLPlayerView.h"
#import "ZLPlayerModel.h"
#import "ZLBrightnessView.h"
#import "UIViewController+ZLPlayerRotation.h"
//#import "UIImageView+ZLCache.h"
#import "UIWindow+ZLCurrentViewController.h"
