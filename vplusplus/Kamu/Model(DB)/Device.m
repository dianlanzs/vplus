//
//  Device.m


#import "Device.h"
#import "MJExtension.h"

#import "KMReqest.h"

@implementation Device

+ (NSArray *)ignoredProperties {

    //@"deviceHandle"
    return @[@"nvr_pwd",
             @"alarmShowed",
             @"nvr_data",
             @"avDelegate",
             @"listDelegate",
             @"nvr_isCloud"];
}


///add 的时候 设置了 type
- (void)setNvr_id:(NSString *)nvr_id {
    if (nvr_id != _nvr_id) {
        _nvr_id = nvr_id;
        _nvr_type = cloud_get_device_type_by_did([nvr_id UTF8String]);
    }
}
+ (NSString *)primaryKey {
    return @"nvr_id";
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
             @"nvr_id":@"_id",
             @"nvr_owner":@"owner"
             };
    
}
+ (NSDictionary *)linkingObjectsProperties {
    return @{ @"nvr_users": [RLMPropertyDescriptor descriptorWithClass:User.class propertyName:@"user_devices"],};
}

- (void)checkingIsCloud{
    
  __block  BOOL flag = NO;
    [[NetWorkTools new] request:GET urlString:KM_API_URL(@"profile") parameters:nil finished:^(id responseDict, NSString *errorMsg) {
        User *response_user =  [User mj_objectWithKeyValues:responseDict];
        if(response_user && [response_user.user_id isEqualToString:USER.user_id]) {
            for (Device *response_device in response_user.user_devices) {
                if ([response_device.nvr_id isEqualToString:self.nvr_id]) {
                    flag = YES;
                }
            }
        }
    }];
}
@end

