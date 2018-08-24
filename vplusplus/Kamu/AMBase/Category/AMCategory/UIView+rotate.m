//
//  UIView+rotate.m
//  Kamu
//
//  Created by YGTech on 2018/8/24.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "UIView+rotate.h"

@implementation UIView (rotate)
//timingMode 调速模式
- (void)rotateWithDuration:(CGFloat)aDuration repeatCount:(CGFloat)aRepeatCount timingMode:(enum TimingMode)aMode {
    
    CAKeyframeAnimation *aAnimation = [CAKeyframeAnimation animation];
    aAnimation.values = [NSArray arrayWithObjects:
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,0,1)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0,0,1)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(6.26, 0,0,1)],
                           nil];
    aAnimation.cumulative = YES;
    aAnimation.duration = aDuration;
    aAnimation.repeatCount = aRepeatCount;
    aAnimation.removedOnCompletion = YES;
    aAnimation.autoreverses = YES;
    aAnimation.fillMode = kCAFillModeRemoved;
    
    if(aMode == TimingModeEaseInEaseOut) {
        aAnimation.timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                                                nil];
    }
    [self.layer addAnimation:aAnimation forKey:@"transform"];
}

- (void)rotateWithDuration:(CGFloat)aDuration timingMode:(enum TimingMode)aMode {
    [self rotateWithDuration:aDuration repeatCount:1 timingMode:aMode];
}

- (void)rotateWithDuration:(CGFloat)aDuration {
    [self rotateWithDuration:aDuration repeatCount:1 timingMode:TimingModeLinear];
}


- (void)animationStart {
    // 扫描动画
    [UIView animateWithDuration:5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        self.lineImageView.frame = CGRectMake(0, 220, 220, 2);
    } completion:^(BOOL finished) {
    }];
}
-(void)pauseLayer{
    // 当前时间（暂停时的时间）
    // CACurrentMediaTime() 是基于内建时钟的，能够更精确更原子化地测量，并且不会因为外部时间变化而变化（例如时区变化、夏时制、秒突变等）,但它和系统的uptime有关,系统重启后CACurrentMediaTime()会被重置
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
     //停止动画
    self.layer.speed = 0;
    // 动画的位置（动画进行到当前时间所在的位置，如timeOffset=1表示动画进行1秒时的位置）
    self.layer.timeOffset = pauseTime;
    
}
//恢复layer上的动画
-(void)resumeLayer{
    // 动画的暂停时间
    CFTimeInterval pausedTime = self.layer.timeOffset;
    // 动画初始化
    self.layer.speed = 1;
    self.layer.timeOffset = 0;
    self.layer.beginTime = 0;
    // 程序到这里，动画就能继续进行了，但不是连贯的，而是动画在背后默默“偷跑”的位置，如果超过一个动画周期，则是初始位置
    // 当前时间（恢复时的时间）
    CFTimeInterval continueTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 暂停到恢复之间的空档
    CFTimeInterval timePause = continueTime - pausedTime;
    // 动画从timePause的位置从动画头开始
    self.layer.beginTime = timePause;
    
}
@end
