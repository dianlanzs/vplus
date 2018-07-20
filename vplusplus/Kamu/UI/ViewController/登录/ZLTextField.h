//
//  ZLTextField.h
//  Kamu
//
//  Created by YGTech on 2018/7/10.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLTextField : UITextField <UITextFieldDelegate>
@property (nonatomic, copy) void(^filledNotify)(BOOL flag);

@end
