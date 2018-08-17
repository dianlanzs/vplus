//
//  VPPRequest.h
//  测试Demo
//
//  Created by Zhoulei on 2018/3/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//



#import "NetWorkTools.h"

///VPP  vplusplus

static NSString * const host_pushURL = @"http://push.iotcplatform.com";
#define VPP_PUSH_URL(resourcePath)  [NSString stringWithFormat:@"%@/%@", host_pushURL, resourcePath]

@interface VPPRequest : NetWorkTools



@end
