//
//  UINavigationController+operating.m
//  Kamu
//
//  Created by YGTech on 2018/6/26.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "UINavigationController+operating.h"
#import <objc/runtime.h>

@implementation UINavigationController (operating)


- (void)pushViewController:(UIViewController *)vc deviceModel:(Device *)deviceModel camModel:(Cam *)camModel {
    ;
}
- (void)reconnect:(id)sender {
    ;
}

- (MediaEntity *)operatingMedia {
   return  objc_getAssociatedObject(self, _cmd);
}
- (void)setOperatingCam:(Cam *)operatingCam {
    objc_setAssociatedObject(self, @selector(operatingCam), operatingCam, OBJC_ASSOCIATION_RETAIN);
}
- (Device *)operatingDevice {
   return  objc_getAssociatedObject(self, _cmd);
}

- (Cam *)operatingCam {
  return   objc_getAssociatedObject(self, _cmd);
}

- (void)setOperatingMedia:(MediaEntity *)operatingMedia {
    objc_setAssociatedObject(self, @selector(operatingMedia), operatingMedia, OBJC_ASSOCIATION_RETAIN);
}
- (void)setOperatingDevice:(Device *)operatingDevice {
    objc_setAssociatedObject(self, @selector(operatingDevice), operatingDevice, OBJC_ASSOCIATION_RETAIN);

}
@end
