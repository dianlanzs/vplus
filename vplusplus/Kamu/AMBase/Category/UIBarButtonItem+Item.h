//
//  UIBarButtonItem+Item.h
//  Kamu
//
//  Created by YGTech on 2017/11/20.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Item)
+ (UIBarButtonItem *)barItemWithTarget:(id)target action:(SEL)action title:(NSString *)title;
+ (UIBarButtonItem *)barItemWithimage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action title:(NSString *)title;

@end
