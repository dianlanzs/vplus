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
#import "PlayVideoController.h"
#import "PlaybackControl.h"

#import "AppDelegate.h"


#import "PlaybackViewController.h"
@interface AMNavigationController () <UINavigationControllerDelegate ,UIGestureRecognizerDelegate >

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) Alert *statusAlert;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;


@property (nonatomic, strong) Device *informedDevice;


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


#pragma mark - 设备连接成功和失败通知
- (void)stateNotification:(NSNotification *)notification {
   
    Device *informedDevice = notification.object;
//    [self setInformedDevice:informedDevice];
    NSLog(@"%@,%@",self.visibleViewController,self.topViewController);
    if ([self.visibleViewController isKindOfClass:[MainViewController class]] || ![((AMViewController *)self.visibleViewController).operatingDevice.nvr_id  isEqualToString:informedDevice.nvr_id]) {
        //不作处理
        return;
    }else {
        
    [(AMViewController *)self.topViewController setOperatingDevice:informedDevice];
    if (informedDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED ) {
        
        if ([self.topViewController isKindOfClass:[PlayVideoController class]]) {
//            RLM_R_CAM(<#cam_id#>)
//            [self setOperatingCam:informedDevice.nvr_cams[0]];
            [((PlayVideoController *)self.topViewController).vp lv_start];
            
        }else if ([self.topViewController isKindOfClass:[PlaybackViewController class]]) {
            [((PlaybackViewController *)self.topViewController).vp pb_start];
        }
      
        [self UI_device_connected];
    }else {
        //reconnect : for half-way offline
        cloud_connect_device((void *)informedDevice.nvr_h, "admin", "123");
        [self UI_device_connecting];

    }
        
        
        
    }
}

- (void)UI_device_connecting {
    [self.statusAlert setAlertType:AlertTypeError];
    [self.statusAlert.titleLabel setText:@"CONNECTING..."];
    [self.activityIndicator startAnimating];
    [self.statusAlert showAlert];
//开启定时器 设置 connecting  timeout
}

- (void)UI_device_connected {
    [self.statusAlert setAlertType:AlertTypeSuccess];
    [self.statusAlert.titleLabel setText:@"CONNECTED"];
    [self.activityIndicator stopAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.statusAlert dismissAlert];
        
    });
}

#pragma mark - 视图生命周期

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
    

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateNotification:) name:@"CLOUD_DEVICE_STATE" object:nil];

    
}
- (void)viewWillAppear:(BOOL)animated {
 
//    NSDictionary *userInfo = [self.appDelegate.triggerOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (userInfo) {
//        [self jumpToViewctroller:userInfo];
//    }
    
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
  
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
- (void)pushViewController:(AMViewController *)vc deviceModel:(Device *)deviceModel camModel:(Cam *)camModel {
    [self pushViewController:vc animated:YES];
//    [self showViewController:nil sender:nil];
    
    if (camModel) {
        vc.operatingCam = camModel;
    }
    if (deviceModel ) {////?? count == 1 推送打开 ? 2:正常打开
        
        //for can't recive device state
        if (vc.operatingDevice.nvr_status != CLOUD_DEVICE_STATE_CONNECTED) {
            [self UI_device_connecting];
        }
      
        vc.operatingDevice = deviceModel;

        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateNotification:) name:@"CLOUD_DEVICE_STATE" object:nil];


   
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



//跳转方法
-(void)jumpToViewctroller:(NSDictionary *)remoteNotification {

    //app killed case:
    //    [self.vc.navigationController dealRemoteNotification]
    NSString *jumpIdx =    remoteNotification[@"jump"];
    NSString *did =  remoteNotification[@"did"];
    NSString *cid =  remoteNotification[@"cid"];
    NSString *file =  remoteNotification[@"file"];

    
    Device *find_db_device =  [[self.results objectsWhere:[NSString stringWithFormat:@"nvr_id = '%@'",did]] firstObject];
    Cam  *find_db_cam =  [[find_db_device.nvr_cams objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",cid]] firstObject];

//    [self.operatingDevice setNvr_id:did];
//    [self.operatingDevice setNvr_status:CLOUD_DEVICE_STATE_UNKNOWN];
//    [self.operatingCam setCam_id:cid];
//
//    [self pushViewController:[self vc_jumpPage:jumpIdx] deviceModel:self.operatingDevice camModel:self.operatingCam];


    if ([jumpIdx isEqualToString:@"1"]) {
        
        
        if (find_db_cam && find_db_device) {
          PlayVideoController *pv_viewcontroller =  [PlayVideoController new];
            [self pushViewController:pv_viewcontroller deviceModel:find_db_device camModel:find_db_cam];

        }else {
            NSLog(@"db has no this camModel");  //alert window
        }
        
    }
    
    
    else if ([jumpIdx isEqualToString:@"2"]) {
        
        if (find_db_cam && find_db_device && file ) {
            PlaybackViewController *pb_viewController = [PlaybackViewController new];
            pb_viewController.operatingMedia.fileName = file;
            [self pushViewController:pb_viewController deviceModel:find_db_device camModel:find_db_cam];
            
        }else {
            NSLog(@"db has no this file");  //alert window
        }
    }
    
    
    
    
    
    
    
    
//    
//    int jumpIndex = (int) [remoteNotification[@"type"] integerValue];
//    NSString *device_id =  remoteNotification[@"device_id"];
//    NSString *cam_id =  remoteNotification[@"cam_id"];


//    if (jumpIndex == 2) {
//
//        Device *remote_pushedDevice = RLM_R_NVR(device_id);//operatingdevice = mainViewController viewDidLoad nvr_model
//        Cam *remote_pushedCam = RLM_R_CAM(cam_id);
//
    
        //nvr_index --->cellModel ,cam_index---->camModel  ,, nav.model =  ,
//        [self pushViewController:[PlaybackViewController new] deviceModel:remote_pushedDevice camModel:remote_pushedCam];
    
        
        /*
         控制器的返回方法。
         if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"present"] isEqualToString:@"1"]) {
         
         [self dismissViewControllerAnimated:YES completion:^{
         
         [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"present"]; // 这里最好完全清除它。
         
         }];
         
         }else{
         
         [self.navigationController popViewControllerAnimated:YES];
         
         }
         
         */
        
        
        
        //        UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:VC];
        
        
//    }

}


- (RLMResults<Device *> *)results {
    return [Device allObjects];
}

- (UIActivityIndicatorView *)activityIndicator {
    
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    }
    return _activityIndicator;
    
}

- (Alert *)statusAlert {
    if (!_statusAlert) {
        _statusAlert = [[Alert alloc] initWithTitle:nil inidicator:self.activityIndicator rootVc:nil];
    }
    
    return _statusAlert;
}
@end
