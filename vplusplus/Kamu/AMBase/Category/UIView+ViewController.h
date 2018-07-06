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
@property (strong, nonatomic) UINavigationController *navigationController;

#warning 分类中 覆盖了navigationController ，属性了 ! 导致 navigationController 属性 == nil!!  ????????
- (UIViewController *)getViewController;
- (UINavigationController *)getNavigationController;
@end
