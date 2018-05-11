//
//  PlayVideoController.h
//  Kamu
//
//  Created by YGTech on 2017/12/12.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"


#import "QRResultCell.h"
#import "Cam.h"

@interface PlayVideoController : UIViewController


@property (nonatomic,strong) Cam *cam;
@property (nonatomic, strong) QRResultCell *nvrCell;
@property (nonatomic, strong) NSIndexPath *indexpath;

@end
