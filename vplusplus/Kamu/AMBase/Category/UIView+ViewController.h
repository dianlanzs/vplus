//
//  UIView+ViewController.h
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (ViewController)
@property (strong, nonatomic) UIViewController *vc;

- (UIViewController *)getViewController;
@end
