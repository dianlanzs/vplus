//
//  UIView+ButtonsBar.h
//  Kamu
//
//  Created by YGTech on 2018/1/8.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ButtonsBar)


- (void)addButtons:(NSArray *)icons width:(CGFloat)width constarintToView:(UIView *)refView centerOffset:(CGFloat)offset isZoomMiddle:(BOOL)needZoom;

@end
