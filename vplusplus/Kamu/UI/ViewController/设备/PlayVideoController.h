//
//  PlayVideoController.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/12.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRResultCell.h"
#import "ZLPlayerView.h"
#import "FunctionView.h"


@interface PlayVideoController : AMViewController

@property (strong, nonatomic) ZLPlayerView *vp;
@property (nonatomic, strong) FunctionView *funcBar;

//
//@property (nonatomic,strong)  NSString *cam_id;
//@property (nonatomic,strong)  NSString *device_id;




//@property (nonatomic, strong) QRResultCell *nvrCell;
//@property (nonatomic, strong) NSIndexPath *indexpath;

@end
