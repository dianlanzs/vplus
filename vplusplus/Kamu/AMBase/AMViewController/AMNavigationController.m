//
//  AMNavigationController.m
//  Kamu
//
//  Created by Zhoulei on 2017/11/20.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "AMNavigationController.h"
#import "UIBarButtonItem+Item.h"

#import "MainViewController.h"


#import "AppDelegate.h"
@interface AMNavigationController () <UINavigationControllerDelegate ,UIGestureRecognizerDelegate >

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) Alert *statusAlert;

@end

@implementation AMNavigationController

#pragma mark - 全局设置 navigationBar 界面
+(void)initialize {
    //父类的方法会被优先调用一次不需要显式的调用父类的initialize，子类的+initialize将要调用时会激发父类调用的+initialize方法，所以也不需要在子类写明[super initialize]。
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    UIBarButtonItem *barButtonAppearance = [UIBarButtonItem appearance];
    //字体格式
    NSDictionary *textAttributes = nil;
    textAttributes = @{
                       NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                       NSForegroundColorAttributeName: [UIColor whiteColor],
                       };
    
    //统一设置 navigation bar 字体样式
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    //顶部 状态栏样式
    [navigationBarAppearance setBarStyle:UIBarStyleDefault];
    //渲染颜色
    navigationBarAppearance.barTintColor = [UIColor blueColor];
    navigationBarAppearance.tintColor = [UIColor whiteColor];  //视图层级 从底层开始渲染
    //设置背景图片
//    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"mb_black"] forBarMetrics:UIBarMetricsDefault];
    //设置阴影 图片 为 透明
//    [navigationBarAppearance setShadowImage:[UIImage imageNamed:@"transparent"]];
    [barButtonAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:14.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [barButtonAppearance setTintColor: [UIColor whiteColor]];
}

#pragma mark - 视图生命周期
- (Alert *)statusAlert {
    if (!_statusAlert) {
        _statusAlert = [[Alert alloc] initWithTitle:nil inidicator:nil completion:nil];

    }
    
    return _statusAlert;
}

- (void)stateNotification:(NSNotification *)notification {
    
    Device *stateChangedDevice = notification.object;
    if (stateChangedDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED ) {
        [self.statusAlert dismissAlert]; //need to play cam !
       
    }else {
        cloud_connect_device((void *)self.pushedDevice.nvr_h, "admin", "123");
        [self.statusAlert.titleLabel setText:@"connnecting..."];
        [self.statusAlert showAlert];
    
    }
}


- (void)setPushedDevice:(Device *)pushedDevice {
    
    if (pushedDevice != _pushedDevice && ![self.topViewController isKindOfClass:[MainViewController class]]) {
        _pushedDevice = pushedDevice;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateNotification:) name:@"CLOUD_DEVICE_STATE" object:pushedDevice];
    }
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    //View Frame  navBar 底部
    [self.navigationBar setTranslucent:NO];
    [self.appDelegate.tabBarController setTabBarHidden:YES];
    

    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        //重新签代理
//        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    if ([self.topViewController isKindOfClass:NSClassFromString(@"PlayVideoController")] ) {
        return self.topViewController.preferredStatusBarStyle;
        
    }
    
    return UIStatusBarStyleLightContent;
    
}

- (BOOL)prefersStatusBarHidden{
    return [self.topViewController prefersStatusBarHidden];
}

- (BOOL)shouldAutorotate {
    
    return NO;
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];;
}
#pragma mark - 拦截‘push'操作 统一设置 返回按钮

- (void)pushVc:(UIViewController *)vc withDevice:(Device *)pushedDevice {
    
    [self pushViewController:vc animated:YES];
    if (pushedDevice) {
        [self setPushedDevice:pushedDevice];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {



    //拦截 push 之后 count > 1 ,push  之前 count > 0
    if (self.childViewControllers.count > 0) {
//        if ([viewController isKindOfClass:NSClassFromString(@"QRDoneViewController")] ) {
//
//            self.selector = @selector(backHome:);
//            self.navTitle = self.viewControllers[0].title;
//        } else {
//
//            self.selector = @selector(backPrevious:);
//            if (self.visibleViewController.title) {
//                self.navTitle = self.visibleViewController.title; //上一个控制器的 title
//            }else {
//                self.navTitle = @"返回";
//            }
//
//        }
//
//        [self.navigationItem hidesBackButton];
//        UIImage *buttonImage = [[UIImage imageNamed:@"navigation_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem barItemWithimage:buttonImage highImage:buttonImage   target:self action:@selector(backPrevious:) title:@""];//self.navTitle

        //隐藏
        [self.appDelegate.tabBarController setTabBarHidden:YES animated:YES];


    }


    //恢复 默认 push 行为
    [super pushViewController:viewController animated:animated];

}

//- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
//
//    UIImage *buttonImage = [[UIImage imageNamed:@"navigation_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    viewControllerToPresent.navigationItem.leftBarButtonItem = [UIBarButtonItem barItemWithimage:buttonImage highImage:buttonImage   target:self action:self.selector title:self.navTitle];
//
//    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
//}
#pragma mark - pop 操作
// 自定义返回操作 ,,判断是否 ‘根控制器’
- (void)backPrevious:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (void)backHome:(id)sender {
    [self popToRootViewControllerAnimated:YES];
}




///MARK:根控制器 ，tabBar 和 navBar 设置不隐藏
- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    if (self.viewControllers.count == 2) {
//        [self.appDelegate.tabBarController setTabBarHidden:NO animated:YES];
        [self setNavigationBarHidden:NO];
    }
    
    return [super popViewControllerAnimated:YES];
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    
//    [self.appDelegate.tabBarController setTabBarHidden:NO animated:YES];
    

    [self setNavigationBarHidden:NO];
    return [super popToRootViewControllerAnimated:YES];
    
}




#pragma mark - data required



- (AppDelegate *)appDelegate {
    
    if (!_appDelegate) {
        _appDelegate =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return _appDelegate;
}
@end
