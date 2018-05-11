//
//  DeviceListController.m
//  ilnkDemo
//
//  Created by YGTech on 2017/11/28.
//  Copyright © 2017年 com.ilnkDemo.cme. All rights reserved.
//

#import "DeviceListController.h"
#import "DeviceListCell.h"

#import "AddDeviceViewController.h"
@interface DeviceListController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic) BOOL allowRefresh;



@property (strong, nonatomic) UITableView *listView;
@property (strong, nonatomic) UIView *subviews;

@end

@implementation DeviceListController



#pragma mark - 生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.listView];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






#pragma mark -  TableView 数据源 & 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.listView) {
        //有可能是file'sOwnner 类型 问题 ，放到 cell 里拖控件！！
        DeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"1" ];
         return cell;

    }
    return nil;
}




#pragma mark - Required
//设置 表格视图
- (UITableView *)listView {
    
    if (!_listView) {
        
        _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, AM_SCREEN_WIDTH, AM_SCREEN_HEIGHT ) style:UITableViewStylePlain];
        
        //设置tableView代理
        _listView.delegate = self;
        _listView.dataSource = self;
        
       
        //设置'row'行高为一半屏幕高度
        [_listView setRowHeight: ( AM_SCREEN_HEIGHT - kTopbarHeight - kTabBarHeight ) / 2];
        [_listView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        
        /*
         使用注册机制
         xib文件上不需要再去加上重用标示
         */
        UINib *deviceNib = [UINib nibWithNibName:@"DeviceListCell" bundle:nil];
        [_listView  registerNib:deviceNib forCellReuseIdentifier:@"1"];
        
    }
    return _listView;
    
}


@end
