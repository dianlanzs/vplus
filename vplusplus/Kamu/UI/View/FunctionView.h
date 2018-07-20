//
//  FunctionView.h
//  Kamu
//
//  Created by Zhoulei on 2018/1/17.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunctionView : UIView

@property (nonatomic, strong) UIView *batteryView;
@property (nonatomic, strong) UILabel *batteryLabel;
@property (nonatomic, strong) UIImageView *lightingLogo;
@property (nonatomic, strong) UIView *wifi;



//电量接口
- (void)setBatteryProgress:(NSInteger)progressValue;
- (void)setWifiProgress:(NSInteger)progressValue;
@end
