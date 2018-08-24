//
//  MainViewController.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/4.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefreshNormalHeader.h"


@interface MainViewController : AMViewController
//@property (nonatomic, strong) UIRefreshControl *pullRefresh;
@property (nonatomic, strong) UITableView *tableView;

- (void)deleteNvr:(Device *)deleteDevice;
- (void)updateDevices ;
@end
