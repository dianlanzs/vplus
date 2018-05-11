//
//  UIImage+Common.h
//  MrBaar
//
//  Created by 姜伦 on 16/12/7.
//  Copyright ® 2016年 MrBear. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end

@interface UIImage (Common)

/// 解决从相机选择图片自动旋转90度的问题
- (UIImage *)fixOrientation;

+(UIImage*) imageWithView:(UIView*)view;

+(UIImage *)imageNamed:(NSString *)name bundleName:(NSString*)bundleName;

+(UIImage *)imageWithColor:(UIColor*)color size:(CGSize)size;

/**
 *	等比缩放照片
 *	@param 	size 缩放的图片尺寸。如果该尺寸不是按照等比设置，则函数按照宽度或高度最大比例进行等比缩放。
 *	@return	等比缩放后的图片对象
 */
-(UIImage *)scaleImageWithSize:(CGSize)size;

// 圆角
- (UIImage *)createRoundedRectWithsize:(CGSize)size
                             ovalWidth:(CGFloat)ovalWidth
                            ovalHeight:(CGFloat)ovalHeight;

// 剪裁
-(UIImage*)clipImageWithRect:(CGRect)rect;

// 灰度化
- (UIImage *)grayImage;






@end
