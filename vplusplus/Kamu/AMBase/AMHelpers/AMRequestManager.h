//
//  AMRequestManager.h
//  测试Demo
//
//  Created by Zhoulei on 2018/3/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

//#import <AFNetworking/AFNetworking.h>


@protocol NetWorkToolsProtcol <NSObject>

@optional
- (NSURLSessionDataTask *_Nullable)dataTaskWithHTTPMethod:(NSString *_Nullable)method
                                                URLString:(NSString *_Nullable)URLString
                                               parameters:(id _Nullable )parameters
                                           uploadProgress:(nullable void (^)(NSProgress * _Nullable uploadProgress)) uploadProgress
                                         downloadProgress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                                                  success:(void (^_Nullable)(NSURLSessionDataTask *_Nullable, id _Nullable ))success
                                                  failure:(void (^_Nullable)(NSURLSessionDataTask *_Nullable, NSError *_Nullable))failure;
@end



@interface AMRequestManager : AFHTTPSessionManager <NetWorkToolsProtcol>

+ (instancetype _Nullable )defaultManager;


@end
