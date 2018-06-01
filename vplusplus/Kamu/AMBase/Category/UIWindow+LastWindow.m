//
//  UIWindow+LastWindow.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/28.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "UIWindow+LastWindow.h"

@implementation UIWindow (LastWindow)
// 严谨 lastWindow 最上层window获取！
+ (UIWindow *)lastWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    
    //按照索引号从大到小访问数组的元素,而不是从小到大访问数组的元素。
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        
        if ([window isKindOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            
            NSLog(@"🔴 window = %@",window);
            return window;
    }
    
    return [UIApplication sharedApplication].keyWindow;
}
@end
