//
//  AppDelegate.m
//  Kamu
//
//  Created by tom on 2017/11/10.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#include <signal.h>

// 引入JPush功能所需头文件
#import "JPUSHService.h"

// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

#import "AppDelegate.h"
#import "AMNavigationController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"



#import "ReactiveObjC.h"

#import "VPPRequest.h"
#import "AFNetworkActivityIndicatorManager.h"


#import "MainViewController.h"
static NSString *appKey = @"ab43e34db3569dc318b8fc47";
static NSString *channel = @"AppStore";
static BOOL isProduction = NO;


@interface AppDelegate ()<JPUSHRegisterDelegate>


@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic, strong) NSMutableArray *navigationControllers;
@property (nonatomic, strong) NSString *token;

@property (nonatomic, strong)VPPRequest *vp_pushReq;

@property (nonatomic, assign) BOOL isTutkPushRegistered;
@end


#define DEVICES [Device allObjects]
@implementation AppDelegate


void sigpipe_handler(int unused){
    printf("Caught signal SIGPIPE %d\n",unused);
    
}

///锁屏触发事件
- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application{
    
    NSLog(@"Lock screen.");
    cloud_notify_network_changed();

}
///解锁事件
- (void) applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:UN_LOCK_SCREEN_NOTIFY
//                                                        object:nil];
    NSLog(@"UnLock screen.");
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"netWorkChangeEventNotification" object:nil];
}

-(void)sendNotation:(NSDictionary *)launchOptions{
    
//    NSDictionary *userInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (userInfo) {
//        [(AMNavigationController *)self.tabBarController.selectedViewController jumpToViewctroller:userInfo];
//
//    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    cloud_init();
   
    
   
//signal(SIGPIPE, SIG_IGN);
//    sigaction(SIGPIPE, &(struct sigaction){sigpipe_handler}, NULL);

    ///Jpush Message Notification
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];

    self.triggerOptions = launchOptions;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:self.tabBarController];

  
    [self setMRButtonAppearance];
    [self configJpushWith:launchOptions];//根据版本第一次加载
    [self.manager.reachabilityManager startMonitoring];
    //Steve
//    self.y_data = new Byte[1920 * 1080 * 1]; //数组容量  ptr[m]
//    self.u_data = new Byte[1920 * 1080 * 1/4]; //数组容量  ptr[m]
//    self.v_data = new Byte[1920 * 1080 * 1/4]; //数组容量  ptr[m]

    /*
     //没有登录过 ，---> 模态 展现登录控制器
     if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
     [self.window setRootViewController:self.loginController];
     
     // 第一次登录 ：是
     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
     // 已经登录  ：是
     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
     }
     //登录过  ---> 配置 navigations
     else {
     [self.window setRootViewController:self.tabBarController];
     // 第一次登录 ： 不是
     [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
     }
     */
    //模拟 服务器请求 token
    //    if (!self.token) {
    //         [self.window setRootViewController:self.loginController];
    //    } else {
    //        [self.window setRootViewController:self.tabBarController];
    //        self.token = @"haveToken && valid";
    //    }
    //
   

//    [self performSelector:@selector(sendNotation:) withObject:launchOptions afterDelay:0];

    return YES;
}

- (void)configJpushWith:(NSDictionary *)launchOptions {
    ///初始化APNs
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];

    ///初始化Jpush
    [JPUSHService setupWithOption:launchOptions
                           appKey:appKey
                          channel:nil
                 apsForProduction:isProduction
            advertisingIdentifier:nil];


}


//token 回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [self configTutkPushWith:deviceToken];
    [JPUSHService registerDeviceToken:deviceToken];// Required - 上报DeviceToken给极光服务器
  

}
- (void)networkDidLogin:(NSNotification *)notification {
  const  char * rid =  [[JPUSHService registrationID] UTF8String];
    if (rid) {
        cloud_set_appinfo(rid);
    }
    
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
//    
//    
//    NSDictionary * userInfo = response.notification.request.content.userInfo;
//    
//}
    



//#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- Jpush Delegate ,  Packaged iOS 10 UN API
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    ;
}
///后台，前台 （后台有横幅，前台没有）--- 推送消息：（Required:content-avalible:1）
/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        ;
        //应用在前台，接收远程推送，会进入这个状态
    }
    else if (state == UIApplicationStateInactive) {
        ;
        //应用在后台，通过点击远程推送通知，进入这个状态
    }
    else if (state == UIApplicationStateBackground) {
        ;
        //应用在后台，收到静默推送，进入这个状态
    }
    //记得加上这句话，要不然应用在后台时不触发方法3。
//    completionHandler(UIBackgroundFetchResultNewData);
}
*/

///前台 --- 展示推送 （可以自定义 有无 横幅，声音等）
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    /*
     NSNumber *badge = content.badge;
     NSString *body = content.body;
     UNNotificationSound *sound = content.sound;
     NSString *subtitle = content.subtitle;
     NSString *title = content.title;
     */
    
    [self handleRemoteNotification:notification];
//    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
//        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
//    }
}

///前台、后台，杀死 -- 点击推送
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    [self handleRemoteNotification:response.notification];
    completionHandler();  
}
// log NSSet with UTF8  if not ,log will be  Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 = [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return str;
}


- (void)handleRemoteNotification:(UNNotification *)notification {
    
    
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    NSDictionary * userInfo = content.userInfo;
    NSLog(@"APP_STATUS:%zd",[UIApplication sharedApplication].applicationState);
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo]; //上报 Jpush 推送信息
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:[self logDic:userInfo] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"接听" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [(AMNavigationController *)self.tabBarController.selectedViewController jumpToViewctroller:userInfo];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self.tabBarController presentViewController:alertController animated:YES completion:nil];
        
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [JPUSHService setBadge:0]; //点击 某个 Cell  上报服务器 bageNumber -1
    }
}
- (void)configTutkPushWith:(NSData *)token{
    NSMutableArray *tempArray = [NSMutableArray array];
    VPPRequest *vp_pushReq = [[VPPRequest alloc] init];
    [vp_pushReq configPramsWith:@{@"token":token}];
    
    
    
    vp_pushReq.taskTag = @"register";
    NSLog(@"client:%@",vp_pushReq.params);
    
    __block typeof(vp_pushReq) w_vp_pushReq = vp_pushReq;
    vp_pushReq.finished = ^(id responseObject, NSError *error) {
        if (!error) {
            NSLog(@"%@  SUCCESS:%@ -- ERROR:%@",[[w_vp_pushReq params] valueForKey:@"cmd"],[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding],error); //调用的是最后一次  block ，只有一个任务
            
            VPPRequest *vp_pushReq2 = [[VPPRequest alloc] init];
            for (Device *nvr in [Device allObjects]) {
                [tempArray addObject:nvr.nvr_id];
                [vp_pushReq2 configPramsWith:@{@"token":token}];
                
                [vp_pushReq2.params removeObjectsForKeys:@[@"osver",@"appver",@"model"]];
                [vp_pushReq2.params setObject:nvr.nvr_id forKey:@"uid"];
                [vp_pushReq2.params setValue:@"reg_mapping" forKey:@"cmd"];
                [vp_pushReq2.params setObject:[NSNumber numberWithInteger:2] forKey:@"interval"];
                vp_pushReq2.taskTag = @"mapping";
                NSLog(@"mapping:%@",vp_pushReq2.params);
                
                __block typeof(vp_pushReq2) w_vp_pushReq2 = vp_pushReq2;
                vp_pushReq2.finished = ^(id responseObject, NSError *error) {
                    if (!error) {
                        NSLog(@"%@  SUCCESS:%@ -- ERROR:%@",[[w_vp_pushReq2 params] valueForKey:@"cmd"],[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding],error); //调用的是最后一次  block ，只有一个任务
                        
                        VPPRequest *  vp_pushReq3 = [[VPPRequest alloc] init];
                        [vp_pushReq3 configPramsWith:@{@"token":token}];
                        [vp_pushReq3.params setValue:@"mapsync" forKey:@"cmd"];
                        [vp_pushReq3.params setValue:tempArray forKey:@"map"];
                        vp_pushReq3.taskTag = @"map_sync";
                        
                        __block typeof(vp_pushReq3) w_vp_pushReq3 = vp_pushReq3;
                        vp_pushReq3.finished = ^(id responseObject, NSError *error) {
                            if (!error) {
                                NSLog(@"%@  SUCCESS:%@ -- ERROR:%@",[[w_vp_pushReq3 params] valueForKey:@"cmd"],[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding],error); //调用的是最后一次  block ，只有一个任务
                            }
                            
                        };
                        
                        NSLog(@"mapsync_params:%@",vp_pushReq3.params);
                        [vp_pushReq3 excute];   //2-1.sync 同步'uid'数据
                        
                    }
                    
                    w_vp_pushReq2 = nil;
                };
                
                [vp_pushReq2 excute];    //2.device mapping 绑定
            }
            
        }
        w_vp_pushReq = nil;
    };
    
    [vp_pushReq excute];//1.cilent register 注册
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data {
    
    
}


//解绑定

/*
 - (void)unRegMapping:(NSString *)uid {
 NSString *systemVer = [[UIDevice currentDevice] systemVersion] ;
 NSString *appVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
 NSString *deviceType = [[UIDevice currentDevice] model];
 NSString *encodeUrl = [deviceType stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
 NSString *uuid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
 NSString *langCode = [self getLangCode];
 dispatch_queue_t queue = dispatch_queue_create("apns-unreg_client", NULL);
 dispatch_async(queue, ^{ if (true) { NSError *error = nil;
 
 NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
 NSString *hostString = @"http://{your_server_addr}/apns/apns.php";
 NSString *argsString = @"%@?cmd=unreg_mapping&token=%@&uid=%@&appid=%@";
 argsString = [argsString stringByAppendingString:@"&lang=%@&udid=%@&os=ios&osver=%@&appver=%@&model=%@"];
 NSString *getURLString = [NSString stringWithFormat:argsString, hostString, _deviceTokenString, uid, appidString, langCode , uuid,  systemVer , appVer , encodeUrl];
 NSString *unregisterResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
 NSLog( @">>> %@", unregisterResult );
 if (error != NULL) {
 NSLog(@"%@",[error localizedDescription]);
 if (database != NULL) {
 [database executeUpdate:@"INSERT INTO apnsremovelst(dev_uid) VALUES(?)",uid];
 
 }
 
 }
 
 }
 
 });
 
 }
 */


//删除上一次记录
/*
 - (void)deleteRemoveLstRecords {
 //    if (database != NULL) {
 NSMutableArray *tempArr = [[NSMutableArray alloc] init];
 NSMutableArray *arrDelData = [[NSMutableArray alloc] init];
 FMResultSet *rs = [database executeQuery:@"SELECT * FROM apnsremovelst"];
 while([rs next]) {
 
 NSString *uid = [rs stringForColumn:@"dev_uid"];
 [tempArr addObject:uid];
 
 }
 [rs close];
 NSString *systemVer = [[UIDevice currentDevice] systemVersion] ;
 NSString *appVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
 NSString *deviceType = [[UIDevice currentDevice] model];
 NSString *encodeUrl = [deviceType stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
 NSString *uuid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
 NSString *langCode = [self getLangCode];
 
 for (NSString *uid in tempArr){
 NSError *error = nil; NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
 NSString *hostString = @"http://{your_server_addr}/apns/apns.php";
 NSString *argsString = @"%@?cmd=unreg_mapping&token=%@&uid=%@&appid=%@";
 argsString = [argsString stringByAppendingString:@"&lang=%@&udid=%@&os=ios&osver=%@&appver=%@&model=%@"];
 NSString *getURLString = [NSString stringWithFormat:argsString, hostString, _deviceTokenString, uid, appidString, langCode , uuid,  systemVer , appVer , encodeUrl];
 NSString *unregisterResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
 NSLog( @">>> %@", unregisterResult );
 if (error != NULL) {
 NSLog(@"%@",[error localizedDescription]);
 
 } else {
 [arrDelData addObject:uid];
 NSLog(@"camera(%@) removed from apnsremovelst", uid);
 
 }
 
 }
 
 for (NSString *uid in arrDelData){
 [database executeUpdate:@"DELETE FROM apnsremovelst where dev_uid=?", uid];
 }
 
 for (NSString *uid in arrDelData){
 [database executeUpdate:@"DELETE FROM apnsremovelst where dev_uid=?", uid];
 
 }
 
 
 //    }
 
 }
 */
















































-(BOOL)didUserPressLockButton{
    //获取屏幕亮度
    CGFloat oldBrightness = [UIScreen mainScreen].brightness;
    //以较小的数量改变屏幕亮度
    [UIScreen mainScreen].brightness = oldBrightness + (oldBrightness <= 0.01 ? (0.01) : (-0.01));
    CGFloat newBrightness = [UIScreen mainScreen].brightness;
    //恢复屏幕亮度
    [UIScreen mainScreen].brightness = oldBrightness;
    //判断屏幕亮度是否能够被改变
    return oldBrightness != newBrightness;
    
}
    
    




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//
//    if ([self didUserPressLockButton]) {
//        //User pressed lock button
//        NSLog(@"Lock screen.");
    
    
//    for (Device *closeDevice in DEVICES) {
//        cloud_close_device((void *)closeDevice.nvr_h);
//    }
//
    
//           cloud_exit();
//    } else {
//        NSLog(@"Home.");
//        //user pressed home button
//
//    }
        
        
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    for (Device *openDevice in DEVICES) {
//        cloud_open_device([openDevice.nvr_id UTF8String]);
//    }
//    cloud_init();
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    AMNavigationController *nav = (AMNavigationController *)self.tabBarController.selectedViewController;
    for (Device *d in nav.results) {
        [RLM transactionWithBlock:^{
            d.nvr_status = CLOUD_DEVICE_STATE_UNKNOWN;
        }];
    }
    
}


//-(void)applicationProtectedDataWillBecomeUnavailable:(NSNotificationCenter *)notification {
//    NSLog(@"锁屏");
//
//    cloud_exit();
////    signal(SIGPIPE, SIG_IGN);
////    exit(0);
//
//}


//- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
//    cloud_init();
//    NSLog(@"解锁");
//    
//}




#pragma mark - 设置‘TabBar’样式
- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    
    //    tabBarController.tabBar.translucent = YES;
    tabBarController.tabBar.backgroundView.backgroundColor = [UIColor colorWithRed:245/255.0
                                                                             green:245/255.0
                                                                              blue:245/255.0
                                                                             alpha:0.9];
    
    NSArray *itemIcons = [self.dict valueForKey:@"tabIcons"];
    NSArray *itemTitles = [self.dict valueForKey:@"tabTitles"];
    
    //设置 tabBarItem 图标  和 背景色
    NSInteger index = 0;
    for (RDVTabBarItem *item in [tabBarController tabBar].items) {
        
        UIImage *itemIcon_selected = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",itemIcons[index]]];
        UIImage *itemIcon_unselected = [UIImage imageNamed:[NSString stringWithFormat:@"%@_unselected",itemIcons[index]]];
        [item setFinishedSelectedImage:itemIcon_selected withFinishedUnselectedImage:itemIcon_unselected];
        item.title = itemTitles[index];
        
        
        [item setBackgroundSelectedImage:[UIImage imageNamed:@"bgTab_selected"] withUnselectedImage:nil];
        
        item.selectedTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10.f],
                                         NSForegroundColorAttributeName:[UIColor colorWithHex:@"0066ff"]};
        //555555 darkGray
        item.unselectedTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10.f],
                                           NSForegroundColorAttributeName:[UIColor colorWithHex:@"828282"]};
        //offset
        item.titlePositionAdjustment = UIOffsetMake(0.f, 5.f);
        item.imagePositionAdjustment = UIOffsetMake(0.f, 2.f);
        index++;
    }
    
}




#pragma mark - getter

//TabBar Controller
- (RDVTabBarController *)tabBarController {
    
    if (!_tabBarController) {
        
     
        _tabBarController = [[RDVTabBarController alloc] init];
        //设置TabBar 磨砂效果 ，半透明效果
        [_tabBarController.tabBar setTranslucent:NO];
        [_tabBarController setViewControllers:self.navigationControllers];
        [self customizeTabBarForController:_tabBarController];
        
    }
    
    return _tabBarController;
    
}

//Login Controller
- (LoginController *)loginController {
    
    if (!_loginController) {
        _loginController = [[LoginController alloc] init];
    }
    
    return _loginController;
}

//controllers 配置文件
- (NSDictionary *)dict {
    
    if (!_dict) {
        _dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ConfigTab" ofType:@"plist"]];
    }
    
    return _dict;
}


//创建navigations
- (NSMutableArray *)navigationControllers {
    
    NSMutableArray *navigationControllers = [NSMutableArray array];
    
    for (NSInteger index = 0; index < 1; index++ ) {
        
        NSString *title = [[self.dict valueForKey:@"navTitles"] objectAtIndex:index];
        UIViewController *vc = [NSClassFromString( [[self.dict valueForKey:@"vcNames"] objectAtIndex:index]) new];
        
        AMNavigationController *navigationVc = [[AMNavigationController alloc] initWithRootViewController:vc];//Convenience method pushes the root view controller without animation.
        
        [vc setTitle:title];  // 如果nav 和 tab  没有设置标题 ， 该设置 可以同时设置 上下 和 vc 的标题！
        //        [vc.navigationItem setTitle:title];
        [navigationControllers addObject:navigationVc];
        
        NSLog(@"✅%@,%ld",title,index);
        
    }
    
    return navigationControllers;
}




#pragma mark - 注册按钮外观样式
- (void)setMRButtonAppearance {
    
    
    NSDictionary *appearanceProxy = @{
                                      
                                      //1.圆角半径： 最大，圆形按钮
                                      kMRoundedButtonCornerRadius : @FLT_MAX,
                                      //2.，boderWidth 描边加粗
                                      kMRoundedButtonBorderWidth  : @5,
                                      
                                      
                                      
                                      //3.Boder普通颜色：白色不透明
                                      kMRoundedButtonBorderColor : [[UIColor whiteColor] colorWithAlphaComponent:1.0],
                                      //4.Border点击后动画颜色： 白色
                                      kMRoundedButtonBorderAnimateToColor : [UIColor whiteColor],
                                      
                                      
                                      
                                      //5.** content 内容填充颜色：白色 半/不透明
                                      kMRoundedButtonContentColor : [[UIColor whiteColor] colorWithAlphaComponent:1.0],
                                      //6.** content 点击之后 内容填充颜色：白色
                                      kMRoundedButtonContentAnimateToColor : [UIColor blueColor],
                                      
                                      
                                      
                                      //前景色： 白色不透明！
                                      kMRoundedButtonForegroundColor : [[UIColor grayColor] colorWithAlphaComponent:1.0],
                                      
                                      
                                      //是否重启会恢复按钮Normal状态
                                      kMRoundedButtonRestoreSelectedState : @YES
                                      
                                      };
    
    
    
    NSDictionary *appearanceProxy2 = @{
                                       
                                       //1.圆角半径： 最大，圆形按钮
                                       kMRoundedButtonCornerRadius : @FLT_MAX,
                                       //2.，boderWidth 描边加粗
                                       kMRoundedButtonBorderWidth  : @0.0f,
                                       
                                       
                                       
                                       //3.Boder普通颜色：白色不透明
                                       kMRoundedButtonBorderColor : [[UIColor whiteColor] colorWithAlphaComponent:1.0],
                                       //4.Border点击后动画颜色： 白色
                                       kMRoundedButtonBorderAnimateToColor : [UIColor whiteColor],
                                       
                                       
                                       
                                       //5.** content 内容填充颜色：
                                       kMRoundedButtonContentColor : [[UIColor colorWithHex:@"#50506E"] colorWithAlphaComponent:1.0],
                                       //6.** content 点击之后 内容填充颜色：白色
                                       kMRoundedButtonContentAnimateToColor : [[UIColor blueColor] colorWithAlphaComponent:1.0],
                                       
                                       
                                       
                                       //前景色： 白色不透明！
                                       kMRoundedButtonForegroundColor : [[UIColor grayColor] colorWithAlphaComponent:0.0],
                                       
                                       
                                       //是否重启会恢复按钮Normal状态
                                       kMRoundedButtonRestoreSelectedState : @YES
                                       
                                       };
    
    
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy forIdentifier:@"MRButton_Default"];
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy2 forIdentifier:@"11"];
    
    
    
    
    
    
    
}
//Main Thread Checker: UI API called on a background thread: -[UIApplication currentUserNotificationSettings]

#pragma mark - 检测网络状态变化
- (AFHTTPSessionManager *)manager {
    
    
    if (!_manager) {
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
       _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
      __block   BOOL firstObserved = YES;
      
        [_manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
           
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    [MBProgressHUD showPromptWithText:@"当前使用的是流量模式"];
                    
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [MBProgressHUD showPromptWithText:@"当前使用的是wifi模式"];
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    [MBProgressHUD showError:@"断网了"];
                    break;
                case AFNetworkReachabilityStatusUnknown:
                    [MBProgressHUD showPromptWithText:@"变成了未知网络状态"];
                    break;
            }
            
            if (firstObserved == NO) {
                cloud_notify_network_changed();
            }else {
                firstObserved = NO;
            }
            
        }];
        
        
    }
    
    return _manager;
}

@end
