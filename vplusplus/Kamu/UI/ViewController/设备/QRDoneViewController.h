//
//  QRDoneViewController.h
//  Kamu
//
//  Created by YGTech on 2017/12/5.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

//连接状态
typedef void(^ConSucceed)(NSString *deviceID, NSString *deviceType ,NSInteger deviceCount);
typedef void(^ConFailed)(NSString *deviceID, NSError *error);

@interface QRDoneViewController : UIViewController

//连接成功回调
@property (nonatomic, strong) ConSucceed succeed;
//连接失败回调
@property (nonatomic, strong) ConFailed failed;
//二维码扫描设备号
@property (nonatomic , strong)NSString *qr_String;

@end
