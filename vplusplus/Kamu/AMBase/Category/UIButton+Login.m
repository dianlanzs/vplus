//
//  UIButton+Login.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/11.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "UIButton+Login.h"
#import "HyLoginButton.h"

#import "AppDelegate.h"

@implementation UIButton (Login)
- (void)loginWithFirstField:(UITextField *)first secondField:(UITextField *)second s:(cmd_succeed)succeed f:(cmd_failed)failed {
    
    //强制退出键盘！
    [second endEditing:YES];
    
    //账号 密码 为空
    if (!first.text.length && !second.text.length) {
        
        [MBProgressHUD showPromptWithText:@"请输入设备号和密码" inView:nil];
    }
    //密码为空
    else if (first.text.length && !second.text.length) {
        [MBProgressHUD showPromptWithText:@"密码不能为空" inView:nil];
    }
    //账户 为空
    else if (!first.text.length && second.text.length) {
        [MBProgressHUD showPromptWithText:@"设备号不能为空" inView:nil];
    }
    
    
    else {
//        [MBProgressHUD showSpinningWithMessage:@"登录中..."];

        [(HyLoginButton *)self scaleAnimation];
        if ([first.text isEqualToString:@"q"] && [second.text isEqualToString:@"q"]) {
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   succeed();
            });
         
            
            
          
            
        }
        
        else{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                failed();
            });
        }
        
    }
        
}

@end
