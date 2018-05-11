//
//  LoginController.m
//  Kamu
//
//  Created by YGTech on 2018/1/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "LoginController.h"
#import "HyTransitions.h"
#import "AppDelegate.h"

@interface LoginController ()<UIViewControllerTransitioningDelegate>

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.loginView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 模态 控制器代理方法
//展现动画 代理
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    return [[HyTransitions alloc] initWithTransitionDuration:0.4f StartingAlpha:0.5f isPush:true];
} 
//消失 动画代理
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    return [[HyTransitions alloc] initWithTransitionDuration:0.4f StartingAlpha:0.8f isPush:false];
}

#pragma mark - Required!
- (LoginView *)loginView {
    
    if (!_loginView) {
        
        _loginView = [[LoginView alloc] initWithFrame:self.view.bounds];
        
        
        
        __weak typeof(self) weakSelf = self;
        _loginView.notify = ^(UIButton *sender ,BOOL isSucceed) {
            
            AppDelegate  *delegate = (AppDelegate  *)[UIApplication sharedApplication].delegate;
            RDVTabBarController *t = [delegate tabBarController];
            //拦截系统转场动画：=========》 Hy自定义转场动画 ,需要在 根容器拦截!!
            t.transitioningDelegate = weakSelf;

                if (isSucceed) {
                    [(HyLoginButton *)sender succeedAnimationWithCompletion:^{
                        [weakSelf presentViewController:(UIViewController *)t animated:YES completion:nil];
                    }];
                }
                
                else {
                    [(HyLoginButton *)sender failedAnimationWithCompletion:^{
                        
//                        [MBProgressHUD showError:@"Error! "];
                    }];
                }

        };
    }
    
    return _loginView;
}
@end
