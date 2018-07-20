//
//  LoginReqest.h
//  Kamu
//
//  Created by YGTech on 2018/7/12.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "NetWorkTools.h"




//#ifdef KAMU
static NSString * const TEST_HOST = @"https://192.168.1.158";
static NSString * const TEST_PORT = @"8443";

static NSString * const KM_HOST = @"https://cloud.ygtek.cn";
static NSString * const KM_PORT = @"8443";

//#endif

#ifndef KM_API_URL
#define KM_API_URL(resourcePath)  [NSString stringWithFormat:@"%@:%@/%@", KM_HOST, KM_PORT, resourcePath]
#endif












@interface KMReqest : NetWorkTools
@end
