//
//  AMViewControllerProtocol.h
//  Kamu
//
//  Created by YGTech on 2017/11/16.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//
#import <Foundation/Foundation.h>
//#import "AMViewModel.h"

@protocol AMViewControllerProtocol <NSObject>

@optional
- (void)initView;

@optional
- (void)initData;

@optional
- (void)bindViewModel;

@optional
- (void)relayout;

@optional
- (void)refreshData;

@end
