//
//  AMViewController.h
//  Kamu
//
//  Created by Zhoulei on 2017/11/16.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMViewControllerProtocol.h"

@interface AMViewController : UIViewController <AMViewControllerProtocol>
@property (nonatomic, strong) Device *operatingDevice;
@property (nonatomic, strong) Cam *operatingCam;
@property (nonatomic, strong) MediaEntity *operatingMedia;


@end
