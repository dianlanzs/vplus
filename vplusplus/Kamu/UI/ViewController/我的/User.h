//
// User.h
//  Kamu
//
//  Created by YGTech on 2018/7/11.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"




RLM_ARRAY_TYPE(Device);
@interface User : RLMObject

@property  RLMArray<Device> *user_devices;  ///退出登录 清除 devices

//@property (nonatomic, assign) NSNumber<RLMInt> *user_id;
@property (nonatomic, assign) NSString *user_id;

@property (nonatomic, assign) int  user_logoutDate;
@property (nonatomic, assign) int  user_loginDate;


@property (nonatomic, copy)   NSString *user_pwd;

@property (nonatomic, copy)  NSString *user_email;
@property (nonatomic, copy)  NSString *user_name;
@property (nonatomic, copy)  NSString *user_phone;
@property (nonatomic, copy)  NSData  *user_portrait;
@property (nonatomic, copy)  NSData  *user_cover;

@property (nonatomic, assign) BOOL user_isLogin;


@end
