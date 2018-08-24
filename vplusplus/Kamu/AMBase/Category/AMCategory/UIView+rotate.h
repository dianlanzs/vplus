//
//  UIView+rotate.h
//  Kamu
//
//  Created by YGTech on 2018/8/24.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
enum TimingMode {
    TimingModeEaseInEaseOut,
    TimingModeLinear
};
@interface UIView (rotate)
- (void)rotateWithDuration:(CGFloat)aDuration repeatCount:(CGFloat)aRepeatCount timingMode:(enum TimingMode)aMode;
- (void)rotateWithDuration:(CGFloat)aDuration timingMode:(enum TimingMode)aMode;
- (void)rotateWithDuration:(CGFloat)aDuration;

-(void)resumeLayer;
-(void)pauseLayer;
@end
