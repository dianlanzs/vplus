//
//  UIViewController+HUD.m
//  Kamu
//
//  Created by Zhoulei on 2017/11/23.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "MBProgressHUD+ZLCategory.h"
#import "UIWindow+LastWindow.h"

@implementation MBProgressHUD (HUD)
//+ (void)showStatusWithText:(NSString *)text inView:(UIView *)view {
//    [MBProgressHUD hideHUD];
//    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    hud.backgroundColor = [UIColor redColor];
//    hud.mode = MBProgressHUDModeText;
//    hud.backgroundView = nil;
//    hud.label.text = NSLocalizedString(text, @"HUD message title");
//    hud.frame = CGRectMake(0, 0, AM_SCREEN_WIDTH, 64);
//}
#pragma mark - 纯文本提示框
+ (void)showPromptWithText:(NSString *)text inView:(UIView *)view {
    [MBProgressHUD hideHUD];
    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(text, @"HUD message title");
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:1.f];
}

+ (void)showPromptWithText:(NSString *)text {
    [MBProgressHUD showPromptWithText:(NSString *)text inView:nil];
}


#pragma mark - 自定义视图
+ (void)showCustom:(NSString *)text icon:(UIImage *)image inView:(UIView *)view {
    [MBProgressHUD hideHUD];
    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
    NSLog(@"MessageWindow = %@",[[UIApplication sharedApplication] keyWindow]);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.mode = MBProgressHUDModeCustomView;
    [hud hideAnimated:YES afterDelay:1.f];
}


//请求成功和失败 便利方法
+ (void)showError:(NSString *)error toView:(UIView *)view {
    [self showCustom:error icon:[UIImage imageNamed:@"Error"] inView:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view {
    [self showCustom:success icon:[UIImage imageNamed:@"Checkmark"] inView:view];
}
+ (void)showSuccess:(NSString *)success {
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error {
    [self showError:error toView:nil];
}


#pragma mark - 耗时任务加载
+ (MBProgressHUD *)showSpinningWithMessage:(NSString *)message toView:(UIView *)view {
     [MBProgressHUD hideHUD];  //重要 ，先删除 ，没有HUD ，不隐藏
    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    //0~1 黑到白的变化值
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.7f];
    return hud;
}

+ (MBProgressHUD *)showSpinningWithMessage:(NSString *)message {
   return  [self showSpinningWithMessage:message toView:nil];
}
#pragma mark - 隐藏 HUD
+ (void)hideHUDForView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD {
    [self hideHUDForView:nil];
}

//======================= SpinKit =====================================
+ (MBProgressHUD *)showIndicator:(RTSpinKitView *)spinner onView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [hud setSquare:YES]; //設置 正方形
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    hud.label.text = @"连接中";
    [spinner startAnimating];
    return hud;
}

@end
