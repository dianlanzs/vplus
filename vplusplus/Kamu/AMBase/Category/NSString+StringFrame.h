//
//  NSString+StringFrame.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/1.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (StringFrame)

- (CGFloat)boundingRectWithFont:(UIFont *)useFont;
- (CGSize)text:(NSString *)str width:(float)width font:(UIFont *)useFont;
@end
