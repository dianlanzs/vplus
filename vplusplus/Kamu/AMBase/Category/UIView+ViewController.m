//
//  UIView+ViewController.m
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "UIView+ViewController.h"
#import <objc/runtime.h>

@implementation UIView (ViewController)


- (UIViewController *)getViewController{
    
    //用循环+类别判断 -> 查找视图所在控制器
    
    UIResponder *next = self.nextResponder;
    
    while (next != nil) {
        
        //2.判断响应者是否是控制器类型
        if ([next isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)next;
            return vc;
        }
        //1.获取下一响应者
        next = next.nextResponder;
    }
    
    return nil;
}
//key  -value
- (void)setVc:(UIViewController *)vc {
    objc_setAssociatedObject(self, @selector(vc), vc, OBJC_ASSOCIATION_RETAIN);
}
- (UIViewController *)vc {
    return objc_getAssociatedObject(self, _cmd); //_cmd : selector imp
}





- (UINavigationController *)getNavigationController{
    UIResponder *next = self.nextResponder;
    
    while (next != nil) {
        if ([next isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)next;
            return nav;
        }
        next = next.nextResponder;
    }
    return nil;
}
- (void)setNavigationController:(UINavigationController *)navigationController {
    objc_setAssociatedObject(self, @selector(navigationController), navigationController, OBJC_ASSOCIATION_RETAIN);
}
- (UINavigationController *)navigationController {
    return objc_getAssociatedObject(self, _cmd); //_cmd : selector imp
}




@end
