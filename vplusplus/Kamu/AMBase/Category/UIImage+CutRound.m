//
//  UIImage+CutRound.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/5.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "UIImage+CutRound.h"

@implementation UIImage (CutRound)

- (UIImage *)cutRoundImage {
    
    // 开启图形上下文 （这个就用到前面的UIView的分类可以直接点出来）
    UIGraphicsBeginImageContext(self.size);
    
    // 获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 矩形框
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // 添加一个圆
    CGContextAddEllipseInRect(ctx, rect);
    
    // 裁剪(裁剪成刚才添加的图形形状)
    CGContextClip(ctx);
    
    // 往圆上面画一张图片
    [self drawInRect:rect];
    
    // 获得上下文中的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}

@end
