//
//  UIViewController+Device.m
//  Kamu
//
//  Created by YGTech on 2018/6/12.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "UIViewController+Device.h"
#import <objc/runtime.h>



@implementation UIViewController (Device)

- (void)setOperatingCam:(Cam *)operatingCam {
    objc_setAssociatedObject(self, @selector(operatingCam), operatingCam, OBJC_ASSOCIATION_RETAIN);
}
- (Cam *)operatingCam {
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setOperatingDevice:(Device *)operatingDevice {
    objc_setAssociatedObject(self, @selector(operatingDevice), operatingDevice, OBJC_ASSOCIATION_RETAIN);
}
- (Device *)operatingDevice {
    return objc_getAssociatedObject(self, _cmd);
}
@end
