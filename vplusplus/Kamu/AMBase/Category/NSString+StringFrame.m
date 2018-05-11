//
//  NSString+StringFrame.m
//  Kamu
//
//  Created by YGTech on 2017/12/1.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "NSString+StringFrame.h"

@implementation NSString (StringFrame)

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
- (CGSize) getSizeWithStr:(NSString *) str width:(float)width fontSize:(float)fontSize
{
    NSDictionary * attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize tempSize = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attribute
                                        context:nil].size;
    return tempSize;
}
@end
