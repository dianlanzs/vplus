//
//  LoginView.h
//  Kamu
//
//  Created by Zhoulei on 2018/1/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HyLoginButton.h"

@interface LoginView : UIView

@property (nonatomic, copy) void(^notify)(UIButton * , BOOL res);

@end
