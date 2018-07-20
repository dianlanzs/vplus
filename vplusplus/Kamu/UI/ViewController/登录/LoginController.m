//
//  LoginController.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "LoginController.h"
#import "HyTransitions.h"

@interface LoginController ()<UIViewControllerTransitioningDelegate,ZLLoginViewDelegate>

@end

@implementation LoginController


- (instancetype)init {
    if (self = [super init]) {
        
        ///先创建 vc 先创建 loginview ，VC才能访问自己的loginview
        [self.view addSubview:self.loginView]; /// loadViewIfRequied === > self.loginview == nil
        NSLog(@"🏆LOGIN-VIEW %@",self.loginView);
        [self.loginView setLoginType:ZLLoginType_prior];
        self.transitioningDelegate = self;
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
  
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

#pragma mark - getter!
- (ZLLoginView *)loginView {
    
    if (!_loginView) {
        _loginView = [[ZLLoginView alloc] initWithFrame:self.view.bounds];
        [_loginView setBackgroundColor:[UIColor whiteColor]];
        [_loginView setDelegate:self];
    }
    return _loginView;
}
- (void)action:(UIButton *)sender actionType:(ZLLoginType)type {

    if (type == ZLLoginType_dismiss) {
        [self.loginView setLoginType:ZLLoginType_prior];
        [self.view addSubview:self.loginView];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        UIViewController *regController = [UIViewController new];
        [self.loginView setLoginType:type];
        [regController.view addSubview:self.loginView];
        [self presentViewController:regController animated:YES completion:^{
            ;
        }];
    }
    
    ///修改了 superview 指针？？？ regVc .view = 0x10473ccb0  self.view =  0x104533f80
//    NSLog(@"%@",self.loginView.superview);
}

@end
