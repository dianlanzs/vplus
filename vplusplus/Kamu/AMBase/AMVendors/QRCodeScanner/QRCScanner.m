//
//  QRCScanner.m
//  QRScannerDemo
//
//  Created by zhangfei on 15/10/15.
//  Copyright © 2015年 zhangfei. All rights reserved.
//

#import "QRCScanner.h"
#import "UIImage+MDQRCode.h"

#define LINE_SCAN_TIME  2.0     // 扫描线从上到下扫描所历时间（s）
#define SCANE_W 200
#define SCANE_H 200

static  CGFloat const kTorch_H  = 30;

@interface QRCScanner() <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong)NSTimer *scanLineTimer;
@property (nonatomic,strong)UIView *scanLine;
@property (nonatomic,strong)UILabel *noticeInfoLable;
@property (nonatomic, strong) UILabel *torchLb;
@property (nonatomic,strong)UIButton *lightButton;

@property (nonatomic,assign)CGRect clearDrawRect;
//@property (nonatomic,assign)BOOL isOn;

@property (nonatomic,strong)AVCaptureVideoPreviewLayer *preview;
@property (nonatomic,strong)AVCaptureDeviceInput * input;
@property (nonatomic,strong)AVCaptureMetadataOutput * output;
@property (nonatomic,strong)AVCaptureDevice * device;

@end
@implementation QRCScanner
#pragma mark - 初始化
- (instancetype)initQRCScannerWithView:(UIView *)view{
    QRCScanner *qrcView = [[QRCScanner alloc]initWithFrame:view.frame];
    [qrcView initDataWithView:view];
    return qrcView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        _transparentAreaSize = CGSizeMake(SCANE_W, SCANE_H);
        _cornerLineColor = [UIColor redColor];
        _scanningLieColor = [UIColor redColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self updateLayout];
}
#pragma mark - 对二维码生成的封装
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size{
    return [UIImage mdQRCodeForString:qrString size:size];;
}

+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)fillColor{
    return [UIImage mdQRCodeForString:qrString size:size fillColor:fillColor];
}

+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)fillColor subImage:(UIImage *)subImage{
    UIImage *qrImage = [UIImage mdQRCodeForString:qrString size:size fillColor:fillColor];
    return [self addSubImage:qrImage sub:subImage];
}
#pragma mark  - 从图片中读取二维码
+ (NSString *)scQRReaderForImage:(UIImage *)qrimage{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:qrimage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    NSString *result = feature.messageString;
    return result;
}
#pragma mark - setter and getter
- (void)setTransparentAreaSize:(CGSize)transparentAreaSize{
    _transparentAreaSize = transparentAreaSize;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setScanningLieColor:(UIColor *)scanningLieColor{
    _scanningLieColor = scanningLieColor;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setCornerLineColor:(UIColor *)cornerLineColor{
    _cornerLineColor = cornerLineColor;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}
#pragma mark - UI
#pragma mark 私有方法
- (void)updateLayout{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    //整个二维码扫描界面的颜色
    CGSize screenSize = screenRect.size;
    CGRect screenDrawRect = CGRectMake(0, 0, screenSize.width,screenSize.height);
    
    CGSize transparentArea = _transparentAreaSize;
    //中间清空的矩形框
    _clearDrawRect = CGRectMake(screenDrawRect.size.width / 2 - transparentArea.width / 2,
                                      screenDrawRect.size.height / 2 - transparentArea.height / 2,
                                      transparentArea.width,transparentArea.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:screenDrawRect];
    [self addCenterClearRect:ctx rect:_clearDrawRect];
    [self addWhiteRect:ctx rect:_clearDrawRect];
    [self addCornerLineWithContext:ctx rect:_clearDrawRect];
    [self addScanLine:_clearDrawRect];
    
    
    [self addLightButton:_clearDrawRect];
//    [self addNoticeInfoLable:_clearDrawRect];
    [self addTorchLabel];
    
    
    // TorchLabel 约束：
    [_torchLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.lightButton);
        make.top.equalTo(self.lightButton.mas_bottom).offset(8.f);
        
    }];
    
    if (self.scanLineTimer == nil) {
        
        [self moveUpAndDownLine];
        [self createTimer];
    }
}
#pragma mark 添加提示提心Lable

- (void)addTorchLabel {
    
//    _torchLb = [[UILabel alloc] initWithFrame:CGRectMake((3 * AM_SCREEN_WIDTH + SCANE_W) * 0.25 - kTorch_H, AM_SCREEN_HEIGHT * 0.5 + kTorch_H, 0, 0)];
    _torchLb = [[UILabel alloc] initWithFrame:CGRectZero];

//    _torchLb.center = CGPointMake((3 * AM_SCREEN_WIDTH + SCANE_W) * 0.25, AM_SCREEN_HEIGHT * 0.5 + kTorch_H );
    
 

//    _torchLb.bounds = CGRectMake(0, 0, 30, 20);
    _torchLb.font = [UIFont systemFontOfSize:12.f];
    //默认 电筒按钮是关闭 的 所以 设置默认 标题文字 "打开电筒"
//    [_torchLb setText:@"打开电筒"];
    [_torchLb setTextColor:[UIColor lightGrayColor]];
    //系统默认是 靠左 ，需要设置居中
    _torchLb.textAlignment = NSTextAlignmentCenter;
    [_torchLb sizeToFit];

    [self addSubview:_torchLb];
}
- (void)addNoticeInfoLable:(CGRect)rect{
    
    _noticeInfoLable = [[UILabel alloc]initWithFrame:CGRectMake(0, (rect.origin.y + rect.size.height+10), self.bounds.size.width, 20)];
    [_noticeInfoLable setText:@"将二维码/条形码放入取景框中即可自动扫描"];
    _noticeInfoLable.font = [UIFont systemFontOfSize:15];
    [_noticeInfoLable setTextColor:[UIColor whiteColor]];
    _noticeInfoLable.textAlignment = NSTextAlignmentCenter;
     
   
}
#pragma mark 添加手电筒功能按钮
- (void)addLightButton:(CGRect)rect{
    
//    _lightButton = [[UIButton alloc] initWithFrame:CGRectMake((3 * AM_SCREEN_WIDTH + SCANE_W) * 0.25 - 20, AM_SCREEN_HEIGHT * 0.5, 40, 40)];
    
    _lightButton = [[UIButton alloc] init];
    _lightButton.center = CGPointMake((3 * AM_SCREEN_WIDTH + SCANE_W) * 0.25, AM_SCREEN_HEIGHT * 0.5);
    _lightButton.bounds = CGRectMake(0.f, 0.f, 25.f, 25.f);
    _lightButton.contentMode = UIViewContentModeScaleAspectFit;
    
    
    

    [_lightButton setImage:[UIImage imageNamed:@"button_torch_normal"] forState:UIControlStateNormal];
    [_lightButton setImage:[UIImage imageNamed:@"button_torch_selected"] forState:UIControlStateSelected];
 
    /*
            [_lightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [_lightButton.titleLabel setFont:[UIFont systemFontOfSize:10.f]];
            [_lightButton setTitle:@"关闭电筒" forState:UIControlStateSelected];
            [_lightButton setTitle:@"打开电筒" forState:UIControlStateNormal];
            [_lightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
*/
    
    [_lightButton addTarget:self action:@selector(torchSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [_lightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _isOn = NO;
    [self addSubview:_lightButton];
}
#pragma mark 画背景
- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}
#pragma mark 扣扫描框
- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}
#pragma mark 画框的白线
- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}
#pragma mark 画扫描线
- (void)addScanLine:(CGRect)rect{
    self.scanLine = [[UIView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 1)];
    self.scanLine.backgroundColor = _scanningLieColor;
    [self addSubview:self.scanLine];
}
#pragma mark 画框的四个角
- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    [self setStrokeColor:_cornerLineColor withContext:ctx];
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}
- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}
#pragma mark - 功能方法
#pragma mark 定时器
- (void)createTimer {
    self.scanLineTimer =
    [NSTimer scheduledTimerWithTimeInterval:LINE_SCAN_TIME
                                     target:self
                                   selector:@selector(moveUpAndDownLine)
                                   userInfo:nil
                                    repeats:YES];
}
#pragma mark 移动扫描线
- (void)moveUpAndDownLine {
    CGRect readerFrame = self.frame;
    CGSize viewFinderSize = _clearDrawRect.size;
    CGRect scanLineframe = self.scanLine.frame;
    scanLineframe.origin.y = (readerFrame.size.height - viewFinderSize.height)/2;
    self.scanLine.frame = scanLineframe;
    self.scanLine.hidden = NO;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:LINE_SCAN_TIME - 0.05
                     animations:^{
                         CGRect scanLineframe = weakSelf.scanLine.frame;
                         scanLineframe.origin.y =
                         (readerFrame.size.height + viewFinderSize.height)/2 -
                         weakSelf.scanLine.frame.size.height;
                         weakSelf.scanLine.frame = scanLineframe;
                     }
                     completion:^(BOOL finished) {
                         weakSelf.scanLine.hidden = YES;
                     }];
    
}
//设置画笔颜色
- (void)setStrokeColor:(UIColor *)color withContext:(CGContextRef)ctx{
    NSMutableArray *rgbColorArray = [self changeUIColorToRGB:color];
    CGFloat r = [rgbColorArray[0] floatValue];
    CGFloat g = [rgbColorArray[1] floatValue];
    CGFloat b = [rgbColorArray[2] floatValue];
    CGContextSetRGBStrokeColor(ctx,r,g,b,1);
}
#pragma mark 照明灯切换
- (void)torchSwitch:(UIButton *)sender {
    
    //切换选中 状态 NO --> YES
    sender.selected = !sender.selected;
    
    if (sender.selected) {
//        [_torchLb setText:@"关闭电筒"];
        [_torchLb setTextColor:[UIColor whiteColor]];
    }
    else{
        
//        [_torchLb setText:@"开启电筒"];
        [_torchLb setTextColor:[UIColor lightGrayColor]];
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    
    if (device.hasTorch) {  // 判断设备是否有闪光灯
        BOOL b = [device lockForConfiguration:&error];
        if (!b) {
            
            if (error) {
                NSLog(@"lock torch configuration error:%@", error.localizedDescription);
            }
            return;
        }
        device.torchMode =
        (device.torchMode == AVCaptureTorchModeOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff);
        [device unlockForConfiguration];
    }
}
#pragma mark - 扫描
- (void)initDataWithView:(UIView *)parentView{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    /**
     *设置聚焦区域
    CGSize size = parentView.bounds.size;
    CGRect cropRect = CGRectMake((size.width - _transparentAreaSize.width)/2, (size.height - _transparentAreaSize.height)/2, _transparentAreaSize.width, _transparentAreaSize.height);
    _output.rectOfInterest = CGRectMake(cropRect.origin.y/size.width,
                                              cropRect.origin.x/size.height,
                                              cropRect.size.height/size.height,
                                              cropRect.size.width/size.width);
     */
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:_input])
    {
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_output])
    {
        [_session addOutput:_output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    //_output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    //增加条形码扫描
    _output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                    AVMetadataObjectTypeEAN8Code,
                                    AVMetadataObjectTypeCode128Code,
                                    AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResize;
    [_preview setFrame:parentView.bounds];
    [parentView.layer insertSublayer:_preview atIndex:0];
    
    [_session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    ///停止，‘不然会不停调用 didScaned 代理方法’  导致内存升高！

    [self.session stopRunning];
    
    //实时预览 相机输出 视图 ，暂时 不移除  。如果关闭 会卡住 不输出 实时画面 ，可用于视频抓图
    [self.preview removeFromSuperlayer];
    
    //设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        if ([self.delegate respondsToSelector:@selector(didScannedQRCode:)]) {
            [self.delegate didScannedQRCode:obj.stringValue];
        }
        else{
            NSLog(@"没有收到扫描结果，看看是不是没有实现协议！");
        }
    }
    [self removeFromSuperview];
}
#pragma mark  - 辅助方法
//将UIColor转换为RGB值
- (NSMutableArray *) changeUIColorToRGB:(UIColor *)color
{
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值
    float r = [[RGBArr objectAtIndex:1] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",r];
    [RGBStrValueArr addObject:RGBStr];
    //获取绿色值
    float g = [[RGBArr objectAtIndex:2] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",g];
    [RGBStrValueArr addObject:RGBStr];
    //获取蓝色值
    float b = [[RGBArr objectAtIndex:3] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",b];
    [RGBStrValueArr addObject:RGBStr];
    //返回保存RGB值的数组
    return RGBStrValueArr;
}
+ (UIImage *)addSubImage:(UIImage *)img sub:(UIImage *) subImage
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
    int subWidth = subImage.size.width;
    int subHeight = subImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake( (w-subWidth)/2, (h - subHeight)/2, subWidth, subHeight), [subImage CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
    //  CGContextDrawImage(contextRef, CGRectMake(100, 50, 200, 80), [smallImg CGImage]);
}
@end
