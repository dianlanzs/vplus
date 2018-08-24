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
typedef void(^AMRequestFinished)(id responseObject,NSString *errorMsg);






@interface NetWorkTools : NSObject

@property (nonatomic, copy) NSString *taskIdentifier;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, assign) AMRequestMethod method;
@property (nonatomic, copy) AMRequestFinished finished;





//@property (nonatomic, copy) AMRequestSuccess success;
//@property (nonatomic, copy) AMRequestFailure failure;

@property (nonatomic, copy, readonly) NSDictionary *headers;
@property (nonatomic, strong) NSURLSessionDataTask *currentTask;





///1
- (void)configURLPrams:(id)data;

///2
- (void)excute;
- (void)requestData:(NSString *)URL;





- (void)request:(AMRequestMethod)method urlString:(NSString *)urlString parameters:(id)parameters finished:(AMRequestFinished)finished;





@end























//===================================  RESPONSE DATA ===================================
@interface AMResponse : NSObject

@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, copy) NSArray *data;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, copy) NSString *errorMsg;

@end
