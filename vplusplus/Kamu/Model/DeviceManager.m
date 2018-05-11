//
//  DeviceManager.m
//  测试Demo
//
//  Created by YGTech on 2018/4/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "DeviceManager.h"
#import "Device.h"


//staic var to store  instance
static DeviceManager *instace = nil;


@implementation DeviceManager

+ (DeviceManager *)sharedDevice {

    
    //staic (to hold the pointer )predicate(onceToken) for check whether the  block is excuted
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [[DeviceManager allocWithZone:NULL] init];
    });
    
    return instace;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        if (!_src) {
            
            _src = [NSMutableArray array];
            for (int i = 0; i < self.results.count; i++) {
                
                Device *managedNvr = [Device new];
                managedNvr.nvr_h    = cloud_create_device([[self.results objectAtIndex:i].nvr_id UTF8String]);
                managedNvr.nvr_id   = [self.results[i] nvr_id];
                managedNvr.nvr_type = [self.results[i] nvr_type];
                managedNvr.nvr_name = [self.results[i] nvr_name];
                managedNvr.nvr_cams = [self.results[i] nvr_cams];
                [_src addObject:managedNvr];
                
            }
            
            
        }
        
    }
    
    return self;
}


- (RLMResults<Device *> *)results {
    return [Device allObjects];
}



@end

