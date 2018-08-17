//
// User.m
//  Kamu
//
//  Created by YGTech on 2018/7/11.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "User.h"


@implementation User

///内部 Model
+(NSDictionary *)mj_objectClassInArray {
    return @{
            @"user_devices" : @"Device",
            };
}
/*
 id    1
 ipc
 0
 _id    "70005605"
 user    "admin"
 password    "admin"
 owner    "1"
 status    0
 name    "测试"
 1
 _id    "50160270"
 user    "admin"
 password    "admin"
 owner    "1"
 status    0
 
 */
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    ///  JSON 的 key 替换为你模型属性
    return @{
             @"user_id":@"id",
             @"user_devices":@"ipc"
             
             };
}

///主键  -- 可以使用 addOrUpdate 方法
+ (NSString *)primaryKey {
    return @"user_id";
}
@end
