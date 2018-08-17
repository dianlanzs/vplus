//
//  Cam.m
//  Kamu
//
//  Created by Zhoulei on 2018/2/27.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "Cam.h"

@implementation Cam
+ (NSDictionary *)linkingObjectsProperties {
    return @{ @"nvrs": [RLMPropertyDescriptor descriptorWithClass:Device.class propertyName:@"nvr_cams"],};
}


+ (NSArray *)ignoredProperties {
    return @[@"cam_cloudMedias"];
}

- (NSMutableArray *)cam_cloudMedias {
    
    if (!_cam_cloudMedias) {
//        _cam_cloudMedias = @[].mutableCopy;
        _cam_cloudMedias = [NSMutableArray array];
    }
    return _cam_cloudMedias;
}
+ (NSString *)primaryKey {
    return @"cam_id";
}
@end

