//
//  UILabel+RichText.m
//  Kamu
//
//  Created by YGTech on 2017/12/5.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "UILabel+RichText.h"

@implementation UILabel (RichText)

//+ (UILabel *)labelWithText:(NSString *)text withFont:(UIFont *)font {
//
//    return [UILabel labelWithText:text withFont:font color:[UIColor whiteColor] aligment:NSTextAlignmentCenter];
//}



+ (UILabel *)labelWithText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)color aligment:(NSTextAlignment)aligment {
    
    
    //Default
    if (!color) {
        color = [UIColor blackColor];
    }
    
    if (!font) {
        font = [UIFont systemFontOfSize:15.f];
    }
    
    
    
    
    
    
    UILabel *lb = [[UILabel alloc] init];
    lb.font = font;
    lb.text = text;
    lb.textAlignment = aligment;
    lb.textColor = color;
    
    /*
    //段落样式
    NSMutableParagraphStyle *paragraphStyle = [[ NSMutableParagraphStyle alloc ] init];
    
    //居中对齐  、尾部最后一行自然对齐
    paragraphStyle.alignment = aligment;
    //单词和字符的断行模式 ，单词断行！
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSForegroundColorAttributeName:color,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    
    
    
    
    //Label
    
    UILabel *label = [[UILabel alloc] init];
    
    label.attributedText =  [[NSAttributedString alloc] initWithString:text attributes:attributes];
    label.numberOfLines = 0;
    [label sizeToFit];
    
    return label;
*/
    
    return lb;
    
}
@end
