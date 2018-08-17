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
- (void)excute {
    self.method = GET;
    [self requestData:VPP_PUSH_URL(@"apns/apns.php")];
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


- (void)configURLPrams:(NSDictionary *)passedDict{
    
    if (passedDict) {
        //push token
        NSString *inDeviceTokenStr = [[passedDict valueForKey:@"token"] description];
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
        
        
        
        ///--------------------------- URL prams --------------------------------
        
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
