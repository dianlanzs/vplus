//
//  MainViewController.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/4.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MainViewController : AMViewController
@property (nonatomic, strong) UIRefreshControl *pullRefresh;

- (void)deleteNvr:(NSIndexPath *)path;

@end
