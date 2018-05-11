//
//  UIWindow+ZLCurrentViewController.h
//  Kamu
//
//  Created by YGTech on 2018/1/8.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (ZLCurrentViewController)

/*!
 @method currentViewController
 
 @return Returns the topViewController in stack of topMostController.
 */


+ (UIViewController*)zl_currentViewController;

@end
