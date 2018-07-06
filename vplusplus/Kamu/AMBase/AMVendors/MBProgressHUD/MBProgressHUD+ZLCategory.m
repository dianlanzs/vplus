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


#import "ZLBrightnessView.h"
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
+ (MBProgressHUD *)showStatus:(cloud_device_state_t)status onView:(UIView *)view {
    
    ///prepare:
    
    
    
    [MBProgressHUD hideHUD];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (view == nil)  view = keyWindow;
    UIViewController *root_vc = [(UIWindow *) view  rootViewController];
    
    
    
    
    
    
    
    
    UILabel *stateLb = [UILabel labelWithText:nil withFont:[UIFont systemFontOfSize:15.f] color:[UIColor whiteColor] aligment:NSTextAlignmentCenter];
    UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AM_SCREEN_WIDTH, 64)];
    [stateView addSubview:stateLb];
    [stateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(stateView).offset(10); //offset 10
        make.leading.equalTo(stateView).offset(10 + 20 + 10);
        make.height.mas_equalTo(20.f);
    }];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [hud setSquare:NO];
    //    [hud setMinSize:CGSizeMake(AM_SCREEN_WIDTH, 64)];
    //    [hud setMargin:0];
    hud.mode = MBProgressHUDModeCustomView;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.frame = CGRectMake(0, 0, AM_SCREEN_WIDTH, 64);
    
    
    
    /// check state
    if (status == CLOUD_DEVICE_STATE_UNKNOWN) {
        RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArc color:[UIColor whiteColor] spinnerSize:25.f];
        spinner.contentMode = UIViewContentModeCenter;
        [spinner setHidesWhenStopped:YES];
        [stateLb setText:@"CLOUD_DEVICE_CONNECTING...."];
        [stateView setBackgroundColor:[UIColor cyanColor]];
        
        [stateView addSubview:spinner];
        [spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(stateLb.mas_leading).offset(-10.f);
            make.centerY.equalTo(stateLb);
        }];
        
//        [keyWindow setWindowLevel:UIWindowLevelAlert];
//        ZLPlayerShared.isStatusBarHidden = YES;
    }
    
    else {
        UIImageView *imv = [[UIImageView alloc] init];
        [imv setTintColor:[UIColor whiteColor]];
        if (status == CLOUD_DEVICE_STATE_DISCONNECTED) {
            
            
///            UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;

            hud.actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self setButton:hud.actionBtn  title:@"重连"];
            [hud.actionBtn addTarget:[(RDVTabBarController *)root_vc selectedViewController] action:@selector(reconnect:) forControlEvents:UIControlEventTouchUpInside];
            [stateView addSubview:hud.actionBtn];
            
            
            
            hud.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self setButton:hud.backBtn title:@"取消"];
            [hud.backBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
            [stateView addSubview:hud.backBtn];
            

          
            [hud.actionBtn  mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(stateLb.mas_trailing).offset(10.f);
                make.centerY.equalTo(stateLb);
            }];
            
        
            [hud.backBtn  mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(hud.actionBtn.mas_trailing).offset(10.f);
                make.centerY.equalTo(stateLb);
                make.width.height.equalTo(hud.actionBtn);
            }];
            
            
            
            
            UIImage *errorImg = [[UIImage imageNamed:@"Error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [imv setImage:errorImg];
            [stateLb setText:@"DISCONNECTED"];
            [stateView setBackgroundColor:[UIColor redColor]];
            //        hud.bezelView.color = [UIColor redColor];
            
//            ZLPlayerShared.isStatusBarHidden = YES;
//            [keyWindow setWindowLevel:UIWindowLevelAlert];

            
        }
        
  
        
        else if (status == CLOUD_DEVICE_STATE_CONNECTED) {
            
            
            UIImage *checkImg = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [imv setImage:checkImg];
            [stateLb setText:@"CONNECTED"];
            [stateView setBackgroundColor:[UIColor greenColor]];
            //        hud.bezelView.color = [UIColor greenColor];
            
            [hud hideAnimated:YES afterDelay:.0f];
//            ZLPlayerShared.isStatusBarHidden = NO;
//            [keyWindow setWindowLevel:UIWindowLevelNormal];

        }
         
    
        
        
        [stateView addSubview:imv];
        [imv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(stateLb.mas_leading).offset(-10.f);
            make.centerY.equalTo(stateLb);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
    }
    
    hud.customView = nil;
    [hud addSubview:stateView];
    return hud;
}

+ (MBProgressHUD *)showStatus:(cloud_device_state_t)status  {
    return [MBProgressHUD showStatus:status onView:nil];
}


#pragma mark - getter
- (void)setActionBtn:(UIButton *)actionBtn {
    objc_setAssociatedObject(self, @selector(actionBtn), actionBtn, OBJC_ASSOCIATION_RETAIN);
}
- (UIButton *)actionBtn {
    return objc_getAssociatedObject(self, _cmd); //_cmd : selector imp
}

- (void)setBackBtn:(UIButton *)backBtn {
    objc_setAssociatedObject(self, @selector(backBtn), backBtn, OBJC_ASSOCIATION_RETAIN);
}
- (UIButton *)backBtn {
    return objc_getAssociatedObject(self, _cmd); //_cmd : selector imp
}
+(void)cancel:(UIButton *)sender {
    [MBProgressHUD hideHUD];
}
+ (void)setButton:(UIButton *)btn title:(NSString *)title {
    
  
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    btn.contentEdgeInsets = UIEdgeInsetsMake(2, 10, 2, 10);
    [btn sizeToFit]; ///update actionBtn size
    [btn.layer setCornerRadius:btn.bounds.size.height / 2];
    [btn.layer setMasksToBounds:YES];
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    btn.layer.borderWidth = 1.f;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    [btn setHidden:NO];
    
    

}
@end
