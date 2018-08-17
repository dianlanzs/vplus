//
//  DeviceManager.h
//  测试Demo
//
//  Created by YGTech on 2018/4/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceManager : NSObject
@property (nonatomic, strong)NSMutableArray *src;

//when class load inital this method
+(instancetype)sharedDevice;
@end

