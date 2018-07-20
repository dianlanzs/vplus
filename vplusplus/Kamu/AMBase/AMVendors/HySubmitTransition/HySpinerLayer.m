//
//  SpinerLayer.m
//  Example
//
//  Created by  东海 on 15/9/2.
//  Copyright (c) 2015年 Jonathan Tribouharet. All rights reserved.
//

#import "HySpinerLayer.h"
#import <UIKit/UIKit.h>

@implementation HySpinerLayer


//-(instancetype)initWithFrame:(CGRect)frame {
+(instancetype)spinnerLayerWithHeight:(CGFloat)button_h {

//    self = [super init];
//    if (self) {
    
        HySpinerLayer *shapeLayer = [HySpinerLayer new];
        CGFloat radius = button_h / 4;
        shapeLayer.frame = CGRectMake(0, 0, button_h, button_h);
        CGPoint center = CGPointMake(button_h/ 2, button_h / 2);
//        CGRectGetHeight(frame)//CGRectGetMidY(self.bounds)
        CGFloat startAngle = 0 - M_PI_2;
        CGFloat endAngle = M_PI * 2 - M_PI_2;
        BOOL clockwise = true;
        shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise].CGPath;
        shapeLayer.fillColor = nil;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineWidth = 1;
        
        shapeLayer.strokeEnd = 0.4;
        shapeLayer.hidden = true;
//    }
    return shapeLayer;
}

-(void)beginAnimation {
    self.hidden = false;
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.fromValue = 0;
    rotate.toValue = @(M_PI * 2);
    rotate.duration = 0.4;
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotate.repeatCount = HUGE;
    rotate.fillMode = kCAFillModeForwards;
    rotate.removedOnCompletion = false;
    [self addAnimation:rotate forKey:rotate.keyPath];
}

-(void)stopAnimation {
    self.hidden = true;
    [self removeAllAnimations];
}

@end
