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
    NSLog(@"---------------------------------请求的URL%@---------------------------------",urlString);

    self.method = method;
    self.URL = urlString;
    self.params = parameters;
    self.finished = finished;
    
    NSString *methodName = (method == GET)? @"GET":@"POST";
    
    /// dataTaskWithHTTPMethod本类没有实现方法 == （没有重写父类方法），但是父类实现了  在调用方法的时候，如果本类没有提供，直接调用父类的方法，AFN 内部已经实现！
    
    AMRequestManager *mgr = [AMRequestManager defaultManager];
    [[mgr dataTaskWithHTTPMethod:methodName URLString:urlString  parameters:parameters uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        finished(responseObject,nil);
//        NSHTTPURLResponse *r = (  NSHTTPURLResponse *) task.response;
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookiesForURL:[NSURL URLWithString:urlString]];
//        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:r.allHeaderFields forURL:[NSURL URLWithString:urlString]];
        for (NSHTTPCookie *tempCookie in cookies) {
            NSLog(@"getCookie:%@",tempCookie);            //打印cookies
        }
//        NSLog(@"============CURRENT REQEST:%@ ============== TASK_RESPONSE:%@",task.currentRequest.allHTTPHeaderFields ,r.allHeaderFields);
//        [[NSUserDefaults standardUserDefaults] setValue:r.allHeaderFields[@"set-cookie"] forKey:@"USER_COOKIE"];
        NSDictionary *requestDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];/// Return a dictionary of header fields that can be used to       add the  specified cookies to the request.
        NSString *ssid_response = [requestDict objectForKey:@"Cookie"] ;
        NSString *ssid_local = [[NSUserDefaults standardUserDefaults] valueForKey:@"USER_COOKIES"];
        NSLog(@"📞LOCAL_SSID ---- %@         RESPONSE_SSID---- %@",ssid_local,ssid_response);

        if(ssid_response && ![ssid_response isEqualToString:ssid_local] ) { ///nil 发消息 返回还是 nil  !nil == 1
            [[NSUserDefaults standardUserDefaults] setObject:ssid_response forKey:@"USER_COOKIES"];
            NSLog(@"SSID!=================================");
        }
    
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
