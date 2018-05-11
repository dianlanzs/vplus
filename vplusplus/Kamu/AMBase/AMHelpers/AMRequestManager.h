//
//  AMRequestManager.h
//  测试Demo
//
//  Created by YGTech on 2018/3/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>


@protocol NetWorkToolsProtcol <NSObject>

@optional
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
@end



@interface AMRequestManager : AFHTTPSessionManager <NetWorkToolsProtcol>

+ (instancetype)defaultManager;

@end
