//
//  QRCScanner.h
//  QRScannerDemo
//
//  Created by zhangfei on 15/10/15.
//  Copyright © 2015年 zhangfei. All rights reserved.
//

#import <UIKit/UIKit.h>

//放到 .m 文件中
#import <AVFoundation/AVFoundation.h>

@protocol QRCodeScanDelegate <NSObject>
/**
 *  扫描成功后返回扫描结果
 *
 *  @param result 扫描结果
 */
- (void)didScannedQRCode:(NSString *)result;

@end

@interface QRCScanner : UIView


//会话
@property (nonatomic,strong)AVCaptureSession *session;


/**
 *  扫描线的颜色,默认红色
 */
@property (nonatomic,strong)UIColor *scanningLieColor;
/**
 *  扫描框边角的颜色，默认红色
 */
@property (nonatomic,strong)UIColor *cornerLineColor;
/**
 *  扫描框的宽高区域，默认(200，200)
 */
@property (nonatomic,assign)CGSize transparentAreaSize;
/**
 *  代理
 */
@property (nonatomic,weak) id<QRCodeScanDelegate>delegate;
/**
 *  初始化方法
 *
 *  @param QRCScannerView的父view
 *
 *  @return QRCScanner实例
 */
//- (instancetype)initQRCScannerWithView:(UIView *)view;
- (instancetype)initQRCScannerWithView:(UIView *)view lightButton:(UIButton *)button;
/**
 *  根据给定的字符串生成一个给定尺寸的二维码image
 *
 *  @param qrString 二维码的内容
 *  @param size     二维码生成后的尺寸大小
 *
 *  @return 二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size;
/**
 *  根据给定的字符串生成一个给定尺寸和给定颜色的二维码image
 *
 *  @param qrString  二维码的内容
 *  @param size      二维码生成后的尺寸大小
 *  @param fillColor 二维码填充颜色
 *
 *  @return 二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)fillColor;
/**
 *  生成中间有logo的二维码
 *
 *  @param qrString  二维码的内容
 *  @param size      二维码生成后的尺寸大小
 *  @param fillColor 二维码填充颜色
 *  @param subImage  二维码的子图
 *
 *  @return 带有子图的二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)fillColor subImage:(UIImage *)subImage;
/**
 *  从图片中读取二维码
 *
 *  @param qrimage 一张二维码图片
 *
 *  @return 二维码信息
 */
+ (NSString *)scQRReaderForImage:(UIImage *)qrimage NS_AVAILABLE_IOS(8_0);

///照明按钮
- (void)torchSwitch:(UIButton *)sender;
@end
