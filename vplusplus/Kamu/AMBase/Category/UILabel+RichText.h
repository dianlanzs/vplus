//
//  UILabel+RichText.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/5.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (RichText)
+ (UILabel *)labelWithText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)color aligment:(NSTextAlignment)aligment;

@end
