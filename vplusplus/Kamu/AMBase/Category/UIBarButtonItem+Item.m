//
//  UIBarButtonItem+Item.m
//  Kamu
//
//  Created by Zhoulei on 2017/11/20.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "UIBarButtonItem+Item.h"

@implementation UIBarButtonItem (Item)

+ (UIBarButtonItem *)barItemWithTarget:(id)target action:(SEL)action title:(NSString *)title {

    return [self barItemWithimage:nil highImage:nil target:target action:action title:title];
}

+ (UIBarButtonItem *)barItemWithimage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action title:(NSString *)title {
    
    
    
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton setTitle:title forState:UIControlStateNormal];
    [barButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    
    
    
    //[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    
    //设置图标
    [barButton setImage:image forState:UIControlStateNormal];
    [barButton setImage:highImage forState:UIControlStateHighlighted];
    
    
    

    //文字未选中颜色
    [barButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //文字选中颜色
//    [barButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
    
    [barButton sizeToFit];
    barButton.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    
    //设置渲染颜色
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] init];
    barButtonItem.customView = barButton;
    
    
    return  barButtonItem;
    
    
    
    
}



@end
