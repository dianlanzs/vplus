//
//  UIViewController+HUD.h
//  Kamu
//
//  Created by Zhoulei on 2017/11/23.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


#import "cloud.h"


@interface MBProgressHUD (HUD)
//@property (nonatomic, strong) void(^callback)(id sender);
@property (nonatomic, strong) UIButton *actionBtn;
@property (nonatomic, strong) UIButton *backBtn;

//纯 文本显示
+ (void)showPromptWithText:(NSString *)text inView:(UIView *)view;
+ (void)showPromptWithText:(NSString *)text;
//自定义 显示
//+ (void)showCustom:(NSString *)text icon:(UIImage *)image inView:(UIView *)view;



//请求成功和失败 ,便利方法
+ (void)showError:(NSString *)error;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;



//long-running 
+ (MBProgressHUD *)showSpinningWithMessage:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showSpinningWithMessage:(NSString *)message;


//隐藏HUD
+ (void)hideHUD;



//======================= SpinKit =====================================
+ (MBProgressHUD *)showStatus:(cloud_device_state_t)status;









@end
