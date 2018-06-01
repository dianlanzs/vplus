//
//  ProbeDoneViewController.h
//  测试Demo
//
//  Created by Zhoulei on 2018/3/22.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRResultCell.h"

@interface ProbeDoneViewController : UIViewController

@property (nonatomic,strong) Cam *probedCam;

@property (nonatomic, strong) QRResultCell *nvrCell;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
