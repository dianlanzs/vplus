////
////  UITextField+deleteEvent.m
////  测试Demo
////
////  Created by YGTech on 2018/3/22.
////  Copyright © 2018年 com.Kamu.cme. All rights reserved.
////
//
//#import "UITextField+deleteEvent.h"
//#import <objc/runtime.h>
//
//
//
//NSString * const WJTextFieldDidDeleteBackwardNotification = @"com.whojun.textfield.did.notification";
//@implementation UITextField (deleteEvent)
//
//
//+ (void)load {
//    
//    
//    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"deleteBackward"));
//    Method method2 = class_getInstanceMethod([self class], @selector(wj_deleteBackward));
//    method_exchangeImplementations(method1, method2);
//    
//}
//
//
//- (void)wj_deleteBackward {
//    [self wj_deleteBackward];
//    if ([self.delegate respondsToSelector:@selector(textFieldDidDeleteBackward:)]) {
//        id <WJTextFieldDelegate> delegate = (id<WJTextFieldDelegate>)self.delegate;
//        [delegate textFieldDidDeleteBackward:self];
//        
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:WJTextFieldDidDeleteBackwardNotification object:self];
//    
//}
//
//
//@end

