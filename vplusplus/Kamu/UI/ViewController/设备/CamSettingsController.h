//
//  CamSettingsController.h
//  Kamu
//
//  Created by YGTech on 2018/2/26.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"
@interface CamSettingsController : QuickDialogController
@property (nonatomic, copy) void(^deleteCam)();
@end
