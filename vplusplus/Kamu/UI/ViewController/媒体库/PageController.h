//
//  PageController.h
//  测试Demo
//
//  Created by Zhoulei on 2018/3/2.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefreshHeader.h"
#import "MJRefreshNormalHeader.h"
#import "MJRefreshAutoNormalFooter.h"

@interface PageController : UITableViewController



//URL  端口
//@property(nonatomic,copy) NSString *urlString;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *tempCams;

@property (nonatomic, assign) int zero_seconds;



@end
