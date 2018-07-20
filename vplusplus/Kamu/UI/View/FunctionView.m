//
//  FunctionView.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/17.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "FunctionView.h"


CGFloat padding = 10.f;

CGFloat batteryW = 30.f;
CGFloat lineW = 1.f;
CGFloat positiveWidth = 2.f;
CGFloat lightingWidth = 15.f;

CGFloat batteryH = 12.f;
CGFloat cornerRadius = 2.f;
@interface FunctionView()

@property (nonatomic, strong) UIButton  *wifiBtn;
@property (nonatomic, strong) UIButton  *batteryBtn;
@property (nonatomic, strong) UIButton  *usbDiskBtn;
@property (nonatomic, strong) UIButton  *settingsBtn;


@property (nonatomic, strong) UILabel *signalLb;



@end






@implementation FunctionView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    
    if (self) {
        
        //
        //        [self addSubview:self.wifiBtn];
        //        [self addSubview:self.batteryBtn];
        //        [self addSubview:self.usbDiskBtn];
        [self drawBatteryWidth:batteryW height:batteryH x:padding y:(CGRectGetHeight(self.bounds) - batteryH) / 2 lineW:lineW];
        [self addSubview:self.wifi];
        [self addSubview:self.signalLb];
        [self addSubview:self.lightingLogo];
        [self.signalLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.wifi.mas_trailing).offset(10.f);
            make.centerY.equalTo(self);
        }];
        
        [self.wifi mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.batteryLabel.mas_trailing).offset(padding);
            make.centerY.equalTo(self).offset(-2.f);//fine tuning
            make.size.mas_equalTo(CGSizeMake(CGRectGetHeight(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5));
        }];
        
        
        [self.lightingLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(batteryW + padding + positiveWidth);
            make.centerY.equalTo(self.batteryView);
            make.size.mas_equalTo(CGSizeMake(lightingWidth, lightingWidth));
        }];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    // 添加子控件的约束
    //    [self setConstraints]; //
    //    [self drawBatteryWidth:batteryW height:batteryH x:padding y: lineW:lineW]; //和 frame 没关系
    
    
}
- (void)setConstraints {
    
    
    
    //
    
    //
    //
    //
    //    [self.batteryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.leading.equalTo(self).offset(1 *(padding + btnW) + 12.f);
    //        make.centerY.equalTo(self);
    //        make.size.mas_equalTo(CGSizeMake(btnW, btnH));
    //    }];
    //
    //
    //
    //    [self.usbDiskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.leading.equalTo(self).offset(2 *(padding + btnW)  + 12.f);
    //        make.centerY.equalTo(self);
    //        make.size.mas_equalTo(CGSizeMake(btnW, btnH));
    //    }];
    
    
    
}

#pragma mark - Required!
//- (UIButton *)wifiBtn {
//
//    if (!_wifiBtn) {
//
////        _wifiBtn = [[UIButton alloc] init];
////        [_wifiBtn setImage:[UIImage imageNamed:@"button_wifi_normal"] forState:UIControlStateNormal];
//        [self drawBatteryWidth:40 height:15 x:0 y:0 lineW:1];
//    }
//
//    return _wifiBtn;
//}
- (UIImageView *)lightingLogo {
    if (!_lightingLogo) {
        _lightingLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar_lighting"]];
    }
    return _lightingLogo;
}
- (UIView *)wifi {
    if (!_wifi) {
        _wifi = [[UIView alloc] init];
        
        NSArray *images = @[@"wifi_0_10",@"wifi_10_40",@"wifi_40_70",@"wifi_70_100"];
       NSArray *reverseImages = [[images reverseObjectEnumerator] allObjects]; //reverse images array
        for (NSInteger i = 0; i < images.count; i++) {
            UIImage *signalPercent =  [[UIImage imageNamed:reverseImages[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *imv = [[UIImageView alloc] initWithImage:signalPercent];
            [imv setTintColor:[UIColor lightGrayColor]];
            [imv setTag:1000 + i];
            [_wifi addSubview:imv];
        }

    }
    
    return _wifi;
}



- (void)setWifiProgress:(NSInteger)progressValue {
    
    if (progressValue >= 70 && progressValue <= 100) {
        for (UIImageView *imv in self.wifi.subviews) {
            if ([imv isKindOfClass:[UIImageView class]]) {
            [imv setTintColor:[UIColor greenColor]];
            }
         
        }
    }
    
    
    else if (progressValue >= 40 && progressValue <= 70) {
        
        NSInteger idx = 0;
        for (UIImageView *imv in self.wifi.subviews) {
            if ([imv isKindOfClass:[UIImageView class]]) {
                
                if (idx == 0) { ///  index = 0   = 70_100 image ,reverse!!!
                        [imv setTintColor:[UIColor lightGrayColor]];
                } else {
                    [imv setTintColor:[UIColor greenColor]];

                }
            
            }
            idx++;
        }
    }
    
   else if (progressValue >= 10 && progressValue <= 40) {
        
        NSInteger idx = 0;
        for (UIImageView *imv in self.wifi.subviews) {
            if ([imv isKindOfClass:[UIImageView class]]) {
                
                if (idx == 0 || idx == 1) {
                    [imv setTintColor:[UIColor lightGrayColor]];
                } else {
                    [imv setTintColor:[UIColor yellowColor]];
                    
                }
                
            }
             idx++;
        }
    }
    
     else if (progressValue >= 3 && progressValue <= 10)  {
       NSInteger idx = 0;
       for (UIImageView *imv in self.wifi.subviews) {
           if ([imv isKindOfClass:[UIImageView class]]) {
               
               if (idx == 3) {
                    [imv setTintColor:[UIColor greenColor]];
              
               } else {
             [imv setTintColor:[UIColor lightGrayColor]];
                   
               }
               
           }
            idx++;
       }
   }
    
     else  {
         NSInteger idx = 0;
         for (UIImageView *imv in self.wifi.subviews) {
             if ([imv isKindOfClass:[UIImageView class]]) {

                     [imv setTintColor:[UIColor lightGrayColor]];
             }
             idx++;
         }
     }
    self.signalLb.text = [[NSString stringWithFormat:@"%lu",(long)progressValue] stringByAppendingString:@"%"];
//    [self setNeedsDisplay];
}


- (UILabel *)signalLb {
    if (!_signalLb) {
        _signalLb = [UILabel labelWithText:nil withFont:[UIFont systemFontOfSize:14.f] color:[UIColor whiteColor] aligment:NSTextAlignmentLeft];
    }
    
    return _signalLb;
}
//- (UIButton *)batteryBtn {
//
//    if (!_batteryBtn) {
//
//        _batteryBtn = [[UIButton alloc] init];
//        [_batteryBtn setImage:[UIImage imageNamed:@"button_battery_normal"] forState:UIControlStateNormal];
//    }
//
//    return _batteryBtn;
//}
- (void)drawBatteryWidth:(CGFloat)w height:(CGFloat)h x:(CGFloat)x y:(CGFloat)y lineW:(CGFloat)lineW{
    //电池的宽度
    //    w = 40;
    //电池的x的坐标
    //    CGFloat x = (self.view.frame.size.width-w)/2;
    //电池的y的坐标
    //    CGFloat y = 64;
    //电池的线宽
    //   CGFloat lineW = 1;
    //电池的高度
    //    CGFloat h = 15;
    
    
    
    
    //电池logo
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w, h) cornerRadius:cornerRadius];
    CAShapeLayer *batteryLayer = [CAShapeLayer layer];
    batteryLayer.lineWidth = lineW;
    batteryLayer.strokeColor = [UIColor lightGrayColor].CGColor; //stroke
    batteryLayer.fillColor = [UIColor clearColor].CGColor;
    batteryLayer.path = [path1 CGPath];
    [self.layer addSublayer:batteryLayer];
    
    
    //正极logo
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(x + w + 1, y + h / 3)];//正极1/3位置
    [path2 addLineToPoint:CGPointMake(x + w + 1, y + h * 2 / 3)];//2/3 位置
    CAShapeLayer *layer2 = [CAShapeLayer layer];
    layer2.lineWidth = positiveWidth; //lineWidth
    layer2.strokeColor = [UIColor lightGrayColor].CGColor;
    layer2.fillColor = [UIColor clearColor].CGColor;
    layer2.path = [path2 CGPath];
    [self.layer addSublayer:layer2];
    
    //绘制进度 嵌套 solid view
    self.batteryView = [[UIView alloc]initWithFrame:CGRectMake(x + 2 * lineW ,y + 2 * lineW, 0, h - 2 * (lineW * 2) )];
    self.batteryView.layer.cornerRadius = 1;
    self.batteryView.backgroundColor = [UIColor colorWithRed:0.324 green:0.941 blue:0.413 alpha:1.000]; ///亮绿色
    [self addSubview:self.batteryView];
    
    
    // -(x) + w + 5 |
    self.batteryLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding + batteryW + positiveWidth + lightingWidth , (CGRectGetHeight(self.bounds)- [@"20%" boundingRectWithFont:[UIFont systemFontOfSize:14.f]]) / 2, 0, 0)];
    self. batteryLabel.textColor = [UIColor whiteColor];
    self.batteryLabel.textAlignment = NSTextAlignmentLeft;
    self. batteryLabel.font = [UIFont systemFontOfSize:14.f];
    [self addSubview:self.batteryLabel];
    
}

- (void)setBatteryProgress:(NSInteger)progressValue{
    
    float eQulity = progressValue;
    if (progressValue >= 1000) {
        eQulity -= 1000;
        [self.lightingLogo setHidden:NO];
    }else {
        [self.lightingLogo setHidden:YES];

    }
    [UIView animateWithDuration:1 animations:^{
        CGRect frame = self.batteryView.frame;
        float percent = eQulity / 100.f;
        frame.size.width = percent * (batteryW - lineW * 4); //battery include width of stroke line
        self.batteryView.frame  = frame;
        self.batteryLabel.text = [[NSString stringWithFormat:@"%lu",(long)eQulity] stringByAppendingString:@"%"];

        if (eQulity < 20) {
            self.batteryView.backgroundColor = [UIColor redColor];
        }else{
            self.batteryView.backgroundColor = [UIColor greenColor];
        }
    }];
    
        [self.batteryLabel sizeToFit];
        [self setNeedsLayout];
    //    [self layoutIfNeeded];
    
    //    [self setNeedsDisplay]
}

//- (UIButton *)usbDiskBtn {
//
//    if (!_usbDiskBtn) {
//
//        _usbDiskBtn = [[UIButton alloc] init];
//        [_usbDiskBtn setImage:[UIImage imageNamed:@"button_uDisk_normal"] forState:UIControlStateNormal];
//    }
//
//    return _usbDiskBtn;
//}

@end
