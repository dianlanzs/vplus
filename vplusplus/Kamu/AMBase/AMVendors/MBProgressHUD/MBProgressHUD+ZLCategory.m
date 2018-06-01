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

#pragma mark - 纯文本提示框
+ (void)showPromptWithText:(NSString *)text inView:(UIView *)view {
    [MBProgressHUD hideHUD];//删除，，，重要 ，window 上有HUD？ ，有隐藏时候 删除  ---》隐藏（删除）

    
//    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];

//    if (view == nil) view = [UIWindow lastWindow];
//    if (view == nil) view = [[UIApplication sharedApplication].windows firstObject];
    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];


    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(text, @"HUD message title");
    
    // 偏移到底部中心位置
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    
//    hud.removeFromSuperViewOnHide = YES;
    
    [hud hideAnimated:YES afterDelay:1.f];
    
}

+ (void)showPromptWithText:(NSString *)text {
    [MBProgressHUD showPromptWithText:(NSString *)text inView:nil];
}


#pragma mark - 自定义视图
+ (void)showCustom:(NSString *)text icon:(UIImage *)image inView:(UIView *)view {
    
    [MBProgressHUD hideHUD];//删除，，，重要 ，window 上有HUD？ ，有隐藏时候 删除  ---》隐藏（删除）
    
    
    
    
    

//    if (view == nil) view = [UIWindow lastWindow];
//    if (view == nil) view = [UIApplication sharedApplication].delegate.window;

//    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
        if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
    NSLog(@"MessageWindow = %@",[[UIApplication sharedApplication] keyWindow]);

//    if (view == nil) view = [[UIApplication sharedApplication].windows firstObject];
    
    
    
    
    
    
    
    
    

    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:image];
    
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // ** 隐藏时候从父控件中移除  ，前面设置过了 ，前面隐藏了 ，删除了
//    hud.removeFromSuperViewOnHide = YES;
    
    // 2s 之后再消失 ,,---》自动删除？？？
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
    
    
    ///MARK: ？？ 开启这个  ，一隐藏 就删除了！！！ ，如果window 上 有 HUD
 
     [MBProgressHUD hideHUD];  //重要 ，先删除 ，没有HUD ，不隐藏

    // Show the HUD on the root view (self.view is a scrollable table view and thus not suitable,
    // as the HUD would move with the content as we scroll).
    
    
    
    
    
    
    
//    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
    
    NSLog(@"spiningWindow = %@",[[UIApplication sharedApplication] keyWindow]);
//    if (view == nil) view = [[UIApplication sharedApplication].windows firstObject];

//    if (view == nil) view = [UIWindow lastWindow];
    
    
//    if (view == nil) view = [UIApplication sharedApplication].delegate.window;



    
    
    
    
    
    
    
    
    
    
//    // Covers the entire screen. Similar to using the root view controller view.
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    
  // UIActivityIndicatorView.
//    MBProgressHUDModeIndeterminate,
//    /// A round, pie-chart like, progress view.
//    MBProgressHUDModeDeterminate,
//    /// Horizontal progress bar.
//    MBProgressHUDModeDeterminateHorizontalBar,
//    /// Ring-shaped progress view.
//    MBProgressHUDModeAnnularDeterminate,
//    /// Shows a custom view.
//    MBProgressHUDModeCustomView,
//    /// Shows only labels.
//    MBProgressHUDModeText
    
    
    
    
    
    

    
    
//   MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    
//    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = message;
    
    
//    hud.removeFromSuperViewOnHide = YES;

    
    
    
    
#pragma mark - dim 模式
    // Change the background view style and color.
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    
    //0~1 黑到白的变化值
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.7f];
    
    
//    [hud hideAnimated:YES afterDelay:2.0f];
    
//    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    
    
//    hud.backgroundView.style = MBProgressHUDBackgroundStyleBlur;
//    hud.removeFromSuperViewOnHide = YES;
/*
    
    // Fire off an asynchronous task, giving UIKit the opportunity to redraw wit the HUD added to the
    // view hierarchy.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // Do something useful in the background
        [self doSomeWork];
        // IMPORTANT - Dispatch back to the main thread. Always access UI
        // classes (including MBProgressHUD) on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        
        
    });
    
  */
    
    return hud;
    
}

+ (MBProgressHUD *)showSpinningWithMessage:(NSString *)message {
    
   return  [self showSpinningWithMessage:message toView:nil];
    
}



//正在加载状态 ,背景模糊
//+ (void)dimBackgroundLodaingInView:(UIView *)view {
//MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//
//    // Change the background view style and color.
//    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
//
//
//    //2.背景模糊 ，可以设置 UIVisualEffectView or UIToolbar.layer background view
//    //hud.backgroundView.style = MBProgressHUDBackgroundStyleBlur;
//    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];
//
//    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
////    [self doSomeWork];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [hud hideAnimated:YES];
//    });
//});
//
//}









#pragma mark - 隐藏 HUD
+ (void)hideHUDForView:(UIView *)view {
    // 在传递参数的时候, 设置view为windows, 因为在添加的时候是基于第一个window的

//      if (view == nil)  view = [[UIApplication sharedApplication].windows lastObject];
//       if (view == nil) view = [[UIApplication sharedApplication].windows firstObject];

//        if (view == nil) view = [UIWindow lastWindow];
        if (view == nil) view = [[UIApplication sharedApplication] keyWindow];

    NSLog(@"For hide Window = %@",[[UIApplication sharedApplication] keyWindow]);

//    if (view == nil) view = [UIApplication sharedApplication].delegate.window;

    
    
    
    
    
    

    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD {
    
    [self hideHUDForView:nil];
}





//测试 模拟耗时操作....
+ (void)doSomeWork {
    [NSThread sleepForTimeInterval:1];
}





//======================= SpinKit =====================================


+ (MBProgressHUD *)showIndicator:(RTSpinKitView *)spinner onView:(UIView *)view {
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    [hud setSquare:YES]; //設置 正方形
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = spinner;
    
    
    
    
    
    
//    hud.labelText = NSLocalizedString(@"Loading", @"Loading");
    hud.label.text = @"连接中";
    
    [spinner startAnimating];
    
    return hud;
}

@end
