//
//  UICameraController.h
//  Kamu
//
//  Created by YGTech on 2017/11/27.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
@interface UICameraController : UIViewController


@property (nonatomic, strong) Device *device;
//传递声音
@property (nonatomic, assign) BOOL isMotion;
@property (nonatomic, copy) NSString *viewID;




@end
