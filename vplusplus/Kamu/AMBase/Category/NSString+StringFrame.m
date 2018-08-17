//
//  NSString+StringFrame.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/1.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "NSString+StringFrame.h"

@implementation NSString (StringFrame)
#pragma mark - 不固定宽度
- (CGFloat)boundingRectWithFont:(UIFont *)useFont {
    
    //CGSizeMake(getScreenWidth(), CGFLOAT_MAX)注意：限制的宽度不同，计算的高度结果也不同。

    
    //段落样式
    NSMutableParagraphStyle *paragraphStyle = [[ NSMutableParagraphStyle alloc ] init];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    //    paragraphStyle.lineSpacing = subtextLingSpace;
    //实际行数
    //    NSInteger lineNum = subtextH / subtextFontSize;
    
    
    
    //options枚举参数
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    
    //富文本属性字典设置
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSFontAttributeName:useFont
                                 };
    
    CGFloat stringH = [self boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, CGFLOAT_MAX)
                                         options:options
                                      attributes:attributes context:nil].size.height;
    return stringH;
}


#pragma mark - 固定宽度和字体大小，获取label的frame
- (CGSize)text:(NSString *)str width:(float)width font:(UIFont *)useFont {
    NSDictionary * attribute = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSFontAttributeName:useFont
                                 };
    CGSize tempSize = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
    return tempSize;
}
@end
