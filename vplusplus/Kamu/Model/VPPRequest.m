//
//  VPPRequest.m
//  测试Demo
//
//  Created by Zhoulei on 2018/3/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "VPPRequest.h"
#import "AppDelegate.h"
#import <AdSupport/AdSupport.h>


@interface VPPRequest()

@end



@implementation VPPRequest

//请求URL
- (void)excute {
    
//    if ([[self.params valueForKey:@"cmd"] isEqual:@"sync"]) {
//         self.method = POST;
//    }else {
//        self.method = GET;
//    }
    
    self.method = GET;
   __weak typeof(self) weakSelf = self;
//    self.finished = ^(id responseObject, NSError *error) {
//        if (!error) {
//            NSLog(@"%@  SUCCESS:%@ -- ERROR:%@",[[weakSelf params] valueForKey:@"cmd"],[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding],error); //调用的是最后一次  block ，只有一个任务
//        }
//    };
    [self sendWithCommond:VPP_PUSH_URL(@"apns/apns.php")];
}



//请求头 与服务器 商定
- (NSDictionary *)headers {
//    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    return [NSDictionary dictionaryWithDictionary:dict];
}
//SIGIN ，加密
- (void)sign{
    
}


- (void)configPramsWith:(NSDictionary *)dict{
    
    if (dict) {
        //push token
        NSString *inDeviceTokenStr = [[dict valueForKey:@"token"] description];
        NSString *tokenString = [inDeviceTokenStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];//替换空格
        tokenString = [[NSString alloc] initWithString:tokenString];
        
        
        NSString *systemVer = [[UIDevice currentDevice] systemVersion] ;
        NSString *appVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *appidString = [[NSBundle mainBundle] bundleIdentifier]; //bundle ID
        NSString *deviceType = [[UIDevice currentDevice] model]; //iphone6
        NSString *encodeUrl = [deviceType stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]; //UTF8 编码
        NSString *uuid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]; //广告标识符
        NSString *langCode = [self getLangCode];
        
        self.params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                      @"cmd":@"reg_client",
                                                                      @"token":tokenString,
                                                                      @"appid":appidString,
                                                                      @"udid":uuid,
                                                                      @"os":@"ios",
                                                                      
                                                                      @"lang":langCode,
                                                                      @"osver":systemVer,
                                                                      @"appver":appVer,
                                                                      @"model":encodeUrl
                                                                      }];

    }
    
}






//获取语言代码
-(NSString *)getLangCode {
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: @"zh_TW", @"zh-Hant", @"en_US", @"en", @"fr_FR", @"fr", @"de_DE", @"de", @"zh_CN", @"zh-Hans", @"ja_JP", @"ja", @"nl_NL", @"nl", @"it_IT", @"it", @"es_ES", @"es",nil];
    NSString *code = [dict objectForKey:[languages objectAtIndex:0]];
    if ( nil == code) {
        code = @"en_US" ;
        
    }
    return code ;
    
}






@end
