//
//  UIView+PlayerControl.m
//  Kamu
//
//  Created by YGTech on 2018/6/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "UIView+PlayerControl.h"
#import <objc/runtime.h>

@implementation UIView (PlayerControl)

- (void)setDelegate:(id<PlayerControlDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<PlayerControlDelegate>)delegate {
    return objc_getAssociatedObject(self, _cmd);
}



- (void)hideCommonControl {
    ;
}
- (void)showCommonControl {
    ;
}
- (void)resetCommonControl {
    ;
}

- (void)resetFuncControl {
    ;
}
- (void)zl_playEnd {
    ;
}
//must implement
- (void)zl_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value {
    ;
}
- (void)zl_playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview{
    ;
}
- (void)zl_playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image{
    ;
}
- (void)zl_playerDraggedEnd{
    ;
}
@end
