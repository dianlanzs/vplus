//
//  NSAttributedString+Attributes.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/4.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Attributes)

+ (NSAttributedString *)attrText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)color aligment:(NSTextAlignment)aligment;


+ (NSAttributedString *)underlineAttrText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)color aligment:(NSTextAlignment)aligment;
@end
