//
//  NvrSettingsController.h
//  Kamu
//
//  Created by YGTech on 2018/1/26.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"
//#import "ExampleAppDelegate.h"
@interface NvrSettingsController : QuickDialogController

@property (nonatomic, copy) void(^deleteNvr)();

@end
