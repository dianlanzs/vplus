//
//  UITextField+TF_FloatUp.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/14.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (TF_FloatUp)


//针对图标 和字体 一样大 的
+ (instancetype)textFiedWithText:(NSMutableAttributedString *)attrText;
///MARK:自定义 图标大小
+ (instancetype)textFiedWithText:(NSMutableAttributedString *)attrText iconSize:(CGFloat)iconSize;

//自定义 字体 和图标 大小
+ (instancetype)textFiedWithText:(NSMutableAttributedString *)attrText iconSize:(CGFloat)iconSize  labelFont:(UIFont *)labelFont;

@end
