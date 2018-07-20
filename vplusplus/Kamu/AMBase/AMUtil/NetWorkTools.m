//
//  NetWorkTools.m
//  测试Demo
//
//  Created by Zhoulei on 2018/3/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "NetWorkTools.h"
#import "AMRequestManager.h"





@interface NetWorkTools () 

@end

@implementation NetWorkTools


- (void)request:(AMRequestMethod)method urlString:(NSString *)urlString parameters:(id)parameters finished:(void (^)(id responseObject,NSError *error))finished{
    
    NSString *methodName = (method == GET)? @"GET":@"POST";
    
    // dataTaskWithHTTPMethod本类没有实现方法 == （没有重写父类方法），但是父类实现了
    // 在调用方法的时候，如果本类没有提供，直接调用父类的方法，AFN 内部已经实现！
//    [AMRequestManager defaultManager]
    [[ [AMRequestManager defaultManager] dataTaskWithHTTPMethod:methodName URLString:urlString  parameters:parameters uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        finished(responseObject,nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        finished(nil,error);
    }] resume];
    
    
}


- (void)requestData:(NSString *)URL {
    [self request:self.method urlString:URL parameters:self.params finished:self.finished];
}


#pragma mark - subclass imp method
- (void)configURLPrams:(id)data{
    self.params = data;
}

- (void)excute{
    ;
}
@end








@implementation AMResponse
@end
