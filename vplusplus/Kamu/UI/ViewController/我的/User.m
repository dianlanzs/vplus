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
//- (void)setUser_id:(NSString *)user_id {
//    if (![_user_id isEqualToString:user_id]) {
//        [self setUser_portrait:UIImageJPEGRepresentation([UIImage imageNamed:@""], 0.5)];
//    }
//}


- (User *)matchingWithLogin:(BOOL)isLogin{
    ///都是 一对一 guan'x  ， 设备可以 解绑 ，cam 不可以解绑
    
    ///根据服务器 设备   查找对应本地设备
    NSMutableArray *devices = [NSMutableArray array];
    for (Device *response_device in self.user_devices) {
        Device *db_device = RLM_R_NVR(response_device.nvr_id);
        if(db_device) {
            [RLM transactionWithBlock:^{
                [db_device setNvr_isCloud:YES];
            }];
            [devices addObject:db_device];
            
        }else {
            [devices addObject:[[Device alloc] initWithValue:@{@"nvr_id": response_device.nvr_id ,@"nvr_isCloud" : @(YES) }]];
        }
    }
    
     ///self--- = response user
    
    User *db_user =    [[User objectsWhere:[NSString stringWithFormat:@"user_id = '%@'",self.user_id]] firstObject];
    if (isLogin && db_user) {
        self.user_devices  = (RLMArray<Device> *)devices;
        self.user_portrait = db_user.user_portrait;
        [RLM transactionWithBlock:^{
            [RLM addOrUpdateObject:self];
        }];
    }else {
        [RLM transactionWithBlock:^{
            USER.user_devices = (RLMArray<Device> *)devices; ///增删 devices
        }];
    }
    
    return self;
}




@end
