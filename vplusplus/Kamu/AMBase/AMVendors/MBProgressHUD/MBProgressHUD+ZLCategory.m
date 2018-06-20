//
//  UIViewController+HUD.m
//  Kamu
//
//  Created by Zhoulei on 2017/11/23.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "MBProgressHUD+ZLCategory.h"
#import "UIWindow+LastWindow.h"
#import <objc/runtime.h>
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
//+ (MBProgressHUD *)device:(Device *)device showStatus:(DeviceConnectStatus)status onView:(UIView *)view {
+ (MBProgressHUD *)showStatus:(DeviceConnectStatus)status onView:(UIView *)view {


    [MBProgressHUD hideHUD];
    if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
    UILabel *stateLb = [UILabel labelWithText:nil withFont:[UIFont systemFontOfSize:17.f] color:[UIColor whiteColor] aligment:NSTextAlignmentCenter];
    UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AM_SCREEN_WIDTH, 64)];
//    UIView *stateView = [[UIView alloc] initWithFrame:CGRectZero];

   
    [stateView addSubview:stateLb];
    [stateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(stateView);
        make.height.mas_equalTo(20.f);
    }];
    

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    [hud.bezelView setUserInteractionEnabled:YES];
    [hud setSquare:NO];
//    [hud setMinSize:CGSizeMake(AM_SCREEN_WIDTH, 64)];
//    [hud setMargin:0];
    hud.mode = MBProgressHUDModeCustomView;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.frame = CGRectMake(0, 0, AM_SCREEN_WIDTH, 64);
    
    
    
    /// check state
    if (status == DeviceConnecting) {
        RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArc color:[UIColor whiteColor] spinnerSize:25.f];
        spinner.contentMode = UIViewContentModeCenter;
        [spinner setHidesWhenStopped:YES];
        [stateLb setText:@"Connecting...."];
//        hud.bezelView.color = [UIColor cyanColor];
        [stateView setBackgroundColor:[UIColor cyanColor]];

        [stateView addSubview:spinner];
        [spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(stateLb.mas_leading).offset(-10.f);
            make.centerY.equalTo(stateLb);
        }];
    }
    
    else {
        UIImageView *imv = [[UIImageView alloc] init];
        [imv setTintColor:[UIColor whiteColor]];
        if (status == DeviceDisconnected) {
            
            hud.actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [hud.actionBtn setTitle:@"重连设备" forState:UIControlStateNormal];
            [hud.actionBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
            hud.actionBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
            [hud.actionBtn sizeToFit]; //update actionBtn size
            [hud.actionBtn.layer setCornerRadius:hud.actionBtn.bounds.size.height / 2];
            [hud.actionBtn.layer setMasksToBounds:YES];
            hud.actionBtn.layer.borderColor = [UIColor blackColor].CGColor;
            hud.actionBtn.layer.borderWidth = 1.f;
            hud.actionBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            [stateView addSubview:hud.actionBtn];
            [hud.actionBtn  mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(stateLb.mas_trailing).offset(10.f);
                make.centerY.equalTo(stateLb);
            }];
            
            
            
            
            UIImage *errorImg = [[UIImage imageNamed:@"Error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [imv setImage:errorImg];
            [stateLb setText:@"连接失败"];
           [stateView setBackgroundColor:[UIColor redColor]];
                //        hud.bezelView.color = [UIColor redColor];

        }else if (status == DeviceConnected) {
            UIImage *checkImg = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [imv setImage:checkImg];
            [stateLb setText:@"连接成功"];
            [stateView setBackgroundColor:[UIColor greenColor]];
            //        hud.bezelView.color = [UIColor greenColor];

             [hud hideAnimated:YES afterDelay:2.f];
        }
        
        [stateView addSubview:imv];
        [imv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(stateLb.mas_leading).offset(-10.f);
            make.centerY.equalTo(stateLb);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
       
    }
    
     hud.customView = nil;
    [hud addSubview:stateView];
    return hud;
}

//+ (MBProgressHUD *)device:(Device *)device showStatus:(DeviceConnectStatus)status  {
//    return [MBProgressHUD device:device showStatus:status];
//}

+ (MBProgressHUD *)showStatus:(DeviceConnectStatus)status  {
    return [MBProgressHUD showStatus:status onView:nil];
}


#pragma mark - getter
- (void)setActionBtn:(UIButton *)actionBtn {
    objc_setAssociatedObject(self, @selector(actionBtn), actionBtn, OBJC_ASSOCIATION_RETAIN);
}
- (UIButton *)actionBtn {
    return objc_getAssociatedObject(self, _cmd); //_cmd : selector imp
}
@end
