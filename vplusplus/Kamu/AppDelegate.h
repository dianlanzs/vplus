//
//  AppDelegate.h
//  Kamu
//
//  Created by tom on 2017/11/10.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDVTabBarController.h"
#import "LoginController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window; //全局的window


//登录 和 内容控制器                        
@property (strong, nonatomic)  LoginController *loginController;
@property (nonatomic, strong)  RDVTabBarController *tabBarController;



//unsigned char * 型指针 unsigned char *ptr; 动态分配单元后ptr 可以看成数组 ptr[m].
@property (nonatomic) Byte *m_pYUVData; //绘图全局变量

//YUV data
@property (nonatomic) Byte *y_data;
@property (nonatomic) Byte *u_data;
@property (nonatomic) Byte *v_data;


//    self.m_pYUVData = new Byte[1920 * 1080 * 3 / 2]; //数组容量  ptr[m]
@property(nonatomic,assign)int netStatus;
@property (nonatomic, strong) NSDictionary *triggerOptions;

@end

