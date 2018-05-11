//
//  UINavigationBar+Custom.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "UINavigationBar+Custom.h"
#import <objc/runtime.h>

static IMP drawRectCustomSEL;

@implementation UINavigationBar (Custom)

- (void)isNavigationBarCustom:(BOOL)isCustom {
    if (drawRectCustomSEL == nil) {
        drawRectCustomSEL = [self methodForSelector:@selector(drawRect:)];
    }
    
    if (isCustom) {
        if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationbar_background"] forBarMetrics:UIBarMetricsDefault];
        } else {
            class_replaceMethod([self class], @selector(drawRect:), [self methodForSelector:@selector(drawRectCustom:)], nil);
        }
    } else {
        if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        } else {
            class_replaceMethod([self class], @selector(drawRect:), drawRectCustomSEL, nil);
        }
    }
}

- (void)drawRectCustom:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"navigationbar_background"];
    [image drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
}

@end
