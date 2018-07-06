//
//  UINavigationController+pushedDevice.h
//  Kamu
//
//  Created by YGTech on 2018/6/26.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (operating)
@property (nonatomic, strong) Device *operatingDevice;
@property (nonatomic, strong) Cam *operatingCam;
@property (nonatomic, strong) MediaEntity *operatingMedia;

- (void)pushViewController:(UIViewController *)vc deviceModel:(Device *)deviceModel camModel:(Cam *)camModel;
- (void)reconnect:(id)sender;

@end
