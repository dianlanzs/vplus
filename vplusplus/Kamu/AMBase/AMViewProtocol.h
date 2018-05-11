//
//  AMViewProtocol.h
//  Kamu
//
//  Created by YGTech on 2017/11/16.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMViewModel.h"

@protocol AMViewProtocol <NSObject>

@optional
- (instancetype)initWithViewModel:(id<AMViewProtocol>)viewModel;

- (void)initView;
- (void)bindViewModel;

@end

