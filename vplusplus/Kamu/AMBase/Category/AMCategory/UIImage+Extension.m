//
//  UIImage+Extension.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "UIImage+Extension.h"
#import "AFNetworking.h"

//不同图片格式 设置
#import "UIImage+MultiFormat.h"

@implementation UIImage (Extension)

- (UIImage *)centerResize {
	return [self resizableImageWithCapInsets:UIEdgeInsetsMake(self.size.height/2.0, self.size.width/2.0, self.size.height/2.0, self.size.width/2.0) resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)rotatedByDegree:(CGFloat)degrees {
	CGFloat width = CGImageGetWidth(self.CGImage);
	CGFloat height = CGImageGetHeight(self.CGImage);
	CGSize rotatedSize;
	rotatedSize.width = width;
	rotatedSize.height = height;
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	CGContextRotateCTM(bitmap, M_PI);
	CGContextScaleCTM(bitmap, -1.0, 1.0);
	CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}


//KB图片
- (UIImage *)imageKBytesSizeMax:(NSInteger)kByteSize {
	CGFloat quality = 1.0f;
	NSData *data = UIImageJPEGRepresentation(self, quality);
	CGFloat kBytes = data.length/1000.0;
	while (kBytes > kByteSize && quality > 0.01f) {
		quality = quality - 0.01f;
		data = UIImageJPEGRepresentation(self, quality);
		kBytes = data.length/1000.0;
	}
	return [UIImage sd_imageWithData:data];
}

//像素 用比例 0 不用像素
- (UIImage *)scaleToSize:(CGSize)size {
	UIGraphicsBeginImageContextWithOptions(size,NO,0);
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}


/*
// Round
static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
								 float ovalHeight) {
	float fw, fh;
	if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
	}
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM(context, ovalWidth, ovalHeight);
	fw = CGRectGetWidth(rect) / ovalWidth;
	fh = CGRectGetHeight(rect) / ovalHeight;
	
	CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

-(UIImage*) createRoundedRectImage:(CGSize)size ovalSize: (CGSize)ovalSize {
	int w = size.width;
	int h = size.height;
	
	UIImage *img = self;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
	CGRect rect = CGRectMake(0, 0, w, h);
	
	CGContextBeginPath(context);
	addRoundedRectToPath(context, rect, ovalSize.width, ovalSize.height);
	CGContextClosePath(context);
	CGContextClip(context);
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
	CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	
	UIImage* image = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
	return image;
}

-(UIImage*) createEllipseImage:(CGSize)size {
	int w = size.width;
	int h = size.height;
	
	UIImage *img = self;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
	CGRect rect = CGRectMake(0, 0, w, h);
	
	CGContextBeginPath(context);
	
	CGContextAddEllipseInRect(context, rect);
	
	CGContextClosePath(context);
	CGContextClip(context);
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
	CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	UIImage* image = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
	return image;
}

-(UIImage*)clipToAspectRatio:(CGFloat)ratio {
	CGFloat width = self.size.width;
	CGFloat height = self.size.height;
	CGRect rect;
	if (width / height > ratio) {
		rect = CGRectMake((width - height * ratio) / 2 , 0, height * ratio, height);
	} else if (width / height < ratio) {
		rect = CGRectMake(0,(height - width / ratio) / 2,width,width / ratio);
	} else {
		return self;
	}
#if 0
	UIGraphicsBeginImageContext(CGSizeMake(self.size.width,self.size.height));
	[self drawInRect:rect];
	UIImage* ClipImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return ClipImage;
#else
	CGImageRef sourceImageRef = [self CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
	CGImageRelease(newImageRef);
	return newImage;
#endif
}

- (UIImage *)scaleToFitSize:(CGSize)target_size {
	float hfactor = self.size.width / target_size.width;
	float vfactor = self.size.height / target_size.height;
	
	float factor = MAX(hfactor, vfactor);
	factor = MAX(factor, 1.0);
	
	float newWidth = self.size.width / factor;
	float newHeight = self.size.height / factor;
	
	CGRect newRect = CGRectMake(0.0, 0.0, newWidth, newHeight);
	
	UIGraphicsBeginImageContext(newRect.size);
	[self drawInRect:newRect blendMode:kCGBlendModePlusDarker alpha:1];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return scaledImage;
}

- (UIImage *)transToToolbarItemImage {
	CGSize targetSize = CGSizeMake(70.0f, 70.0f);
	UIImage *image_frame = [UIImage imageNamed:@"attach-frame-bg.png"];
	
	UIGraphicsBeginImageContext(targetSize);
	[image_frame drawInRect:CGRectMake(0.0, 0.0, 70.0f, 70.0f)];
	[self drawInRect:CGRectMake(10.0, 18.0, 50.0, 34.0)];
	UIImage *itemImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return itemImage;
}

- (UIImage *)transToAvatarItem {
	CGSize targetSize = CGSizeMake(120.0f, 88.0f);
	UIImage *image_frame = [UIImage imageNamed:@"avatar-frame.png"];
	
	UIGraphicsBeginImageContext(targetSize);
	[image_frame drawInRect:CGRectMake(0.0, 0.0, 120.0, 88.0)];
	
	CGContextRef context=UIGraphicsGetCurrentContext();
	
	CGRect rect = CGRectMake(46.0, 25.0, 40.0, 40.0);
	CGFloat radius = 2.0;
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	
	CGContextClip(context);
	[self drawInRect:rect];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

- (UIImage *)transWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

- (UIImageView *)imageViewWithFrame:(CGRect)rect andInsets:(UIEdgeInsets)insets {
	UIImage *result = [self resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
	imageView.image = result;
	
	return imageView;
}

+ (UIImage *)rotateImage:(UIImage *)aImage {
	CGImageRef imgRef = aImage.CGImage;
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	
	CGFloat scaleRatio = 1;
	
	CGFloat boundHeight;
	UIImageOrientation orient = aImage.imageOrientation;
	switch(orient) {
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(width, height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(height, width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}
 */

@end
