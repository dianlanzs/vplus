//
//  NSBundle+AppLanguange.h
//  Kamu
//
//  Created by YGTech on 2018/8/16.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *AppLanguageKey = @"AppLanguage";
//语言改变通知
FOUNDATION_EXPORT NSString * const ZZAppLanguageDidChangeNotification;


@interface NSBundle (AppLanguageSwitch)

/**
 设置语言
 
 @param language 参数为语言包的前缀，比如Base.lproj 传入Base、
 中文语言包zh-Hans.lproj传入zh-Hans，前提是工程中已经提前加入了语言包
 */
+ (void)setCusLanguage:(NSString *)language;


/**
 获取当前的自定义语言，如果使用的是跟随系统语言出参为nil
 
 @return 语言类型
 */
+ (NSString *)getCusLanguage;


/**
 恢复成跟随系统语言
 */
+ (void)restoreSysLanguage;
@end
