//
//  PersonalController.h
//  Kamu
//
//  Created by YGTech on 2018/7/11.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"


@interface PersonalController : QuickDialogController
@property (nonatomic, copy) void(^userLogout)(User *);
@end
