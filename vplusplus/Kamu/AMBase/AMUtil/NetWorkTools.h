//
//  NetWorkTools.h
//  测试Demo
//
//  Created by Zhoulei on 2018/3/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"



//===================================  REQUEST MODEL ===================================


@class AMResponse;
typedef enum : NSUInteger {
    GET,
    POST,
} AMRequestMethod;


//
//typedef void(^AMRequestSuccess)(AMResponse *response);
//typedef void(^AMRequestFailure)(NSError *error);
typedef void(^AMRequestFinished)(id responseObject,NSError *error);






@interface NetWorkTools : NSObject

@property (nonatomic, copy)NSString *taskTag;
@property (nonatomic, copy) NSString *commond;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, assign) AMRequestMethod method;
@property (nonatomic, copy) AMRequestFinished finished;





//@property (nonatomic, copy) AMRequestSuccess success;
//@property (nonatomic, copy) AMRequestFailure failure;

@property (nonatomic, copy, readonly) NSDictionary *headers;
@property (nonatomic, strong) NSURLSessionDataTask *currentTask;






- (void)configPramsWith:(id)data;
- (void)sendWithCommond:(NSString *)cmd;





- (void)request:(AMRequestMethod)method urlString:(NSString *)urlString parameters:(id)parameters finished:(void (^)(id responseObject,NSError *error))finished;



@end























//===================================  RESPONSE DATA ===================================
@interface AMResponse : NSObject

@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, copy) NSArray *data;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, copy) NSString *errorMsg;

@end
