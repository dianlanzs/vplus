//
//  NSBundle+AppLanguange.m
//  Kamu
//
//  Created by YGTech on 2018/8/16.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "NSBundle+AppLanguange.h"
#import <objc/runtime.h>


NSString * const ZZAppLanguageDidChangeNotification = @"cc.devfu.languagedidchange";

static const char kBundleKey = 0;
@interface ZLBundleEx : NSBundle
@end

@implementation ZLBundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = objc_getAssociatedObject(self, &kBundleKey);
    if (bundle) {
        return [bundle localizedStringForKey:key value:value table:tableName];
    } else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}
@end















@implementation NSBundle (AppLanguageSwitch)
+ (void)setCusLanguage:(NSString *)language {
    id value = nil;
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    if (language && ![[df valueForKey:AppLanguageKey] isEqualToString:language]) {
        value = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]];
        NSAssert(value != nil, @"value不能为空,请检查参数是否正确");
        [df setObject:language forKey:AppLanguageKey];
        [df synchronize];
        
        objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[NSNotificationCenter defaultCenter] postNotificationName:ZZAppLanguageDidChangeNotification object:nil];
    }
    
    
//    else {
//        [df removeObjectForKey:AppLanguageKey];
//        [df synchronize];
//    }
//    objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    [[NSNotificationCenter defaultCenter] postNotificationName:ZZAppLanguageDidChangeNotification object:nil];
}

+ (NSString *)getCusLanguage {
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *language = [df objectForKey:AppLanguageKey];
    return language;
}

+ (void)restoreSysLanguage {
    [self setCusLanguage:nil];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle],[ZLBundleEx class]);
        NSString *language = [self getCusLanguage];
        if (language) {
            [self setCusLanguage:language];
        }
    });
}
@end
