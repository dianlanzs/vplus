//
//  UIButton+Login.h
//  Kamu
//
//  Created by YGTech on 2018/1/11.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^cmd_succeed)();
typedef void(^cmd_failed)();


@interface UIButton (Login)

- (void)loginWithFirstField:(UITextField *)first secondField:(UITextField *)second s:(cmd_succeed)succeed f:(cmd_failed)failed;

@end

