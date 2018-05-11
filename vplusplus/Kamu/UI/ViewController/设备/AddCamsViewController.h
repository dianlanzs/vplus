//
//  AddCamsViewController.h
//  Kamu
//
//  Created by YGTech on 2017/12/25.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCScanner.h"
#import "QRResultCell.h"

@interface AddCamsViewController : UIViewController


@property (nonatomic, copy) void(^signal_addBtn)(AddCamsViewController *addCam);

//@property (nonatomic,strong) Cam *cam;
//@property (nonatomic,strong) Device *nvr;
@property (nonatomic, strong) QRResultCell *nvrCell;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
