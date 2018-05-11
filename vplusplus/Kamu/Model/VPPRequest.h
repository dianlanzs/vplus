//
//  VPPRequest.h
//  测试Demo
//
//  Created by YGTech on 2018/3/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//



#import "NetWorkTools.h"



static NSString * const host_pushURL = @"http://push.iotcplatform.com";
#define VPP_PUSH_URL(cmd)  [NSString stringWithFormat:@"%@/%@", host_pushURL, cmd]

@interface VPPRequest : NetWorkTools



- (void)excute;
- (void)configPramsWith:(NSDictionary *)dict;
@end
