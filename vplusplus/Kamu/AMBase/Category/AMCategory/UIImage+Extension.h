//
//  UIImage+Extension.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

//#import <UIKit/UIKit.h>

@interface UIImage (Extension)

- (UIImage *)centerResize;
- (UIImage *)rotatedByDegree:(CGFloat)degrees;

- (UIImage *)imageKBytesSizeMax:(NSInteger)kByteSize;

/*
- (UIImage *)scaleToSize:(CGSize)size;

// Round
-(UIImage *)createRoundedRectImage:(CGSize)size ovalSize:(CGSize)ovalSize;
-(UIImage *)createEllipseImage:(CGSize)size;


// Clip
- (UIImage *)clipToAspectRatio:(CGFloat)ratio;


- (UIImage *)scaleToFitSize:(CGSize)target_size;
- (UIImage *)transToToolbarItemImage;
- (UIImage *)transToAvatarItem;
- (UIImage *)transWithColor:(UIColor *)color;
- (UIImageView *)imageViewWithFrame:(CGRect)rect andInsets:(UIEdgeInsets)insets;

+ (UIImage *)rotateImage:(UIImage *)aImage;
*/

@end
