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
            UIViewController *root = (UIViewController *)next;
            return root;
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
@end
