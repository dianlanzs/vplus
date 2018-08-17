
//  MainViewController.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/4.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "MainViewController.h"
#import "SpecViewController.h"
#import "PlayVideoController.h"


#import "AddCamsViewController.h"

#import "UIBarButtonItem+Item.h"

#import "NSAttributedString+Attributes.h"

#import "QRResultCell.h"
#import "DeviceListCell.h"


#import "AppDelegate.h"

#import "MGSwipeButton.h"
#import "ReactiveObjC.h"
#import "KMReqest.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

@interface MainViewController() <UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate>

@property (nonatomic, strong) UIView *emptyView;

//@property (nonatomic, strong) RLMResults<Device *> *results;


@end




@implementation MainViewController



#pragma mark - 生命周期方法
- (void)emptyInterface {
    [self.tableView setTableHeaderView:self.emptyView];
    self.navigationItem.rightBarButtonItem = nil;
    self.tableView.scrollEnabled = NO;
}

- (void)deviceInterface {
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, AM_SCREEN_WIDTH, CGFLOAT_MIN)]];//set header  nil
    self.tableView.scrollEnabled = YES;
    if (!self.navigationItem.rightBarButtonItem) {
        [self setRightBarButtonItem];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (USER.user_devices.count == 0) {
        [self emptyInterface];
    }else {
        [self deviceInterface];
    }
    self.navigationItem.title = LS(@"设备") ;
    [self setLeftBarButtonItem];
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.view addSubview:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNew:) name:@"addNew" object:nil];
}
///添加  设备  ///添加device 表 会有2个 的bug
- (void)addNew:(NSNotification *)notification {
    
    
    
//    [RLM transactionWithBlock:^{
//        [USER.user_devices addObjects:[Device allObjects]];
//    }];
    
    if (USER.user_devices.count > 0) {
        [self deviceInterface];
    }
    
    ///remote sevice 退出登录 ，你并没有删除 所以 数据库里 device 还在！！！
    NSLog(@"------------------------------插入%zd section",USER.user_devices.count);
    NSLog(@"插入一条 section 设备"); ///增删Section 需要处理好numberOfSectionsInTableView返回的结果
  
    
    
    [MBProgressHUD showSuccess:[NSString stringWithFormat:@"添加了第%zd个设备",USER.user_devices.count]];
    NSLog(@"🎟 USER表  ADD DEVICE %@",USER.user_devices);
    
    for (Device *p_device in [Device allObjects]) {
        NSLog(@"🎟 DEVICE 表 ADD DEVICE %p",p_device);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:USER.user_devices.count - 1] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    });
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//    });
//
}
///删除  设备
- (void)deleteNvr:(NSIndexPath *)path {
    
  
    Device *deleteDevice = [USER.user_devices objectAtIndex:path.section];
    NSString * deletePath = [NSString stringWithFormat:@"drop/%@",deleteDevice.nvr_id];
    NSLog(@"------------删除设备%@------------",deleteDevice.nvr_id);
    
    
    
    
   [[[NetWorkTools alloc] init] request:GET urlString:KM_API_URL(deletePath) parameters:nil finished:^(id responseObject, NSError *error) {//删除server
       NSDictionary *dict = [NSDictionary dictionaryWithJSONData:responseObject];
       NSString *success_s = [NSString stringWithFormat:@"%@",[[dict arrayValueForKey:@"success"] lastObject]];
       NSString *fail_s = [NSString stringWithFormat:@"%@",[[dict arrayValueForKey:@"error"] lastObject]];


       if (![dict valueForKey:@"success"]) {
           if([fail_s isEqualToString:@"(null)"]) {
               [MBProgressHUD showError:@"sessionID 过期"];
           }else {
               [MBProgressHUD showError:fail_s];
           }
       }else {
         
           cloud_set_status_callback((void *)deleteDevice.nvr_h,nil,nil); /// state callback set nil!!
           cloud_forget_device((void *)deleteDevice.nvr_h);
           cloud_close_device( (void *)deleteDevice.nvr_h);
           [RLM transactionWithBlock:^{
               for (Cam *del_c in deleteDevice.nvr_cams) {
                   Device *cam_gw = del_c.nvrs[0];
                   if([cam_gw.nvr_id isEqualToString:deleteDevice.nvr_id] ) {
                       [RLM deleteObject:del_c];
                   }
               }
                [RLM deleteObject:deleteDevice];
           }];
           
           
           
           NSLog(@"🤪 USER 表 ：DELETE DEVICE %@",USER.user_devices);
           NSLog(@"🤪 DEVICE 表 ：DELETE DEVICE %@",[Device allObjects]);
           NSLog(@"🤪 CAM 表 ：DELETE DEVICE %@",[Cam allObjects]);

           [MBProgressHUD showSuccess:success_s];
           [self.navigationController popViewControllerAnimated:YES];
           [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:path.section] withRowAnimation:UITableViewRowAnimationTop];
           if (USER.user_devices.count == 0) {
               [self emptyInterface];
           }
       }
    }];
}
    
- (void)setRightBarButtonItem {
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithimage:[UIImage imageNamed:@"nav_add"]  highImage:nil target:self action:@selector(addNvr:) title:LS(@"添加新设备")];
}
- (void)setLeftBarButtonItem {
    //个人中心 按钮侧滑
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
}
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"Main VC  释放了");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
- (BOOL)shouldAutorotate {
    return YES;  ///只是不支持 再次 旋转 ，如果是横屏 出现不会旋转成竖屏 .
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; ///只有 shouldAutorotate YES ,才会有作用 ，否则 跟随设备方向 设置初始界面方向
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
*/


#pragma mark - Table view 数据源回调方法
//swipe  删除会调用 numberOfSection  ，和 numberOfRows 方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"SECTIONS :--%zd--",USER.user_devices.count);
    return USER.user_devices.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"ROWS:--1--");
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"-- CELL FOR ROW --");
    Device *db_device = USER.user_devices[indexPath.section];
    if (db_device.nvr_type == CLOUD_DEVICE_TYPE_GW) {
        QRResultCell *nvrCell = [[QRResultCell alloc] init];
        [nvrCell setNvrModel:db_device];
        [nvrCell setPath:indexPath];
        return nvrCell;
    }

//    if (nonCams_device.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
//        QRResultCell *nvrCell = [[QRResultCell alloc] init];
//        [nvrCell setNvrModel:nonCams_device];
//        [nvrCell setPath:indexPath];
//        return nvrCell;
//    }
    /*
    else if (nonCams_device.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
        tableView.rowHeight = 200;
        DeviceListCell *ipcCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceListCell class]) forIndexPath:indexPath];
        ipcCell.ipcModel = nonCams_device;
        ipcCell.delegate = self;
        return ipcCell;
    }
    */
    return nil;
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 39;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}
//在iOS 11.12  deviceLb 不显示 中 implemetion this method
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc]init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}
#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        
        ///cuz view Frame 在下面
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 0, CGRectGetHeight(self.view.bounds) - 64) style:UITableViewStyleGrouped];
        _tableView.tableFooterView = [UIView new]; //去除分隔线
        [_tableView setShowsVerticalScrollIndicator:NO];
        [_tableView setRowHeight:COLLECTION_VIEW_H + FOOTER_H];
        
        //
        //        [_tableView setEstimatedRowHeight:200.f];
        //        [_tableView setRowHeight:UITableViewAutomaticDimension];
        
        
       
        WS(self);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            NSInteger idx = 0;
            for (Device *state_device in USER.user_devices) {
                
                QRResultCell * state_cell = [ws.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx]];
                if (state_device.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
                    [state_cell upadteCams];
                }else {
                    
                    
                    if (state_device.nvr_status == CLOUD_DEVICE_STATE_UNKNOWN) {
                        [MBProgressHUD showPromptWithText:LS(@"正在连接请耐心等设备状态返回...")];
                    }
                    
                    else if(state_device.nvr_status == CLOUD_DEVICE_STATE_DISCONNECTED) {
                        [MBProgressHUD showPromptWithText:[NSString stringWithFormat:@"连接设备 %zd",state_device.nvr_h]];
                        cloud_connect_device((void *)state_device.nvr_h, "admin", "123");
                        [RLM transactionWithBlock:^{
                            [state_device setNvr_status:CLOUD_DEVICE_STATE_UNKNOWN];
                        }];
                    }
                    
//                    else if (state_device.nvr_status == CLOUD_DEVICE_STATE_UNINITILIZED) {
//                        return ;
//                    }
                    
                    
                    
                }
                
                idx++;
            }
            
            [ws.tableView.mj_header endRefreshing];
            //disconnected 刷新 的情况  ，cuz设置了标志 ，第一次endRefreshing 了 ，，所以第二次 endRereshing 不起作用！
        }];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[DeviceListCell class] forCellReuseIdentifier:NSStringFromClass([DeviceListCell class])];
    }
    
    return _tableView;
    
}


//- (void) handleRefresh:(UIRefreshControl *)sender{
//
//
//}

//无数据展现视图
- (UIView *)emptyView {
    
    
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        _emptyView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        //添加按钮
        MRoundedButton *addButton = [[MRoundedButton alloc] initWithFrame:CGRectZero buttonStyle:MRoundedButtonCentralImage appearanceIdentifier:@"11"];
        addButton.imageView.image = [[UIImage imageNamed:@"add2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [addButton addTarget:self action:@selector(addNvr:) forControlEvents:UIControlEventTouchUpInside];
        //富文本
        UILabel *titleLabel = [UILabel labelWithText:LS(@"欢迎进入Kamu新界面！") withFont:[UIFont boldSystemFontOfSize:25.0f] color:[UIColor darkGrayColor] aligment:NSTextAlignmentCenter];
        UILabel *describeLabel = [UILabel labelWithText:LS(@"点击此处'➕'按钮，扫描设备底部二维码，添加一个摄像机设备") withFont:[UIFont systemFontOfSize:18.0f] color:[UIColor lightGrayColor] aligment:NSTextAlignmentCenter];
        
        //添加控件
        [_emptyView addSubview:addButton];
        [_emptyView addSubview:titleLabel];
        [_emptyView addSubview:describeLabel];
        
        //设置约束
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_emptyView);
            make.size.mas_equalTo(CGSizeMake(100 , 100));
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_emptyView).offset(15);
            make.trailing.equalTo(_emptyView).offset(15);
            make.bottom.equalTo(describeLabel.mas_top).offset(- 20);
        }];
        [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_emptyView).offset(15);
            make.trailing.equalTo(_emptyView).offset(- 15);
            make.bottom.equalTo(addButton.mas_top).offset(- 40);
        }];
    }
    
    return _emptyView;
}

- (void)addNvr:(id)sender {
    [self.navigationController pushViewController:[SpecViewController new] animated:YES];
}




#pragma mark - MGSwipeCell delegate
- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    
    //fromExpansion : 是否来自（设置了）扩展 == NO ，不扩展
    if (direction == MGSwipeDirectionRightToLeft && index == 0 && fromExpansion == NO) {
        //会刷新 tableView ，---> QRcv 也会刷新
        //        QRResultCell * nvrCell = (QRResultCell * )cell ;
        //        [nvrCell.tempCams removeAllObjects];
        
        
        
        Popup *p = [[Popup alloc] initWithTitle:@"提示" subTitle:@"请确认是否需要删除该设备？" cancelTitle:@"取消" successTitle:@"确认" cancelBlock:nil successBlock:^{
            [self deleteNvr:[self.tableView indexPathForCell:cell]];
        }];
        [p setBackgroundBlurType:PopupBackGroundBlurTypeDark];
        [p setIncomingTransition:PopupIncomingTransitionTypeEaseFromCenter];
        [p showPopup];
        
        
        return YES; //不隐藏，展现扩展button 动画
    }
    return YES;// @return YES隐藏当前的 buttons
}

//返回 button 数组 和样式
- (NSArray *)swipeTableCell:(MGSwipeTableCell *) cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    swipeSettings.transition = MGSwipeTransitionStatic;
    /*
     if (direction == MGSwipeDirectionRightToLeft) {
     //扩展动画设置
     expansionSettings.buttonIndex = 0;
     expansionSettings.fillOnTrigger = NO;
     return [self createRightButtons:1];
     }
     */
    
    if (direction == MGSwipeDirectionRightToLeft) {
        return [self createRightButtons:1];
    }
    
    return nil;
}


//创建右侧按钮
- (NSArray *)createRightButtons: (int) number {
    
    NSMutableArray *result = [NSMutableArray array];
    //    NSString *titles[1] = {@"删除"};
    UIColor  *colors[1] = {[UIColor redColor]};
    UIImage *image = [[UIImage imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    for (int i = 0; i < number; ++i) {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:image backgroundColor:colors[i] padding:10.0f callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = ( i != 0 );
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        
        button.tintColor = [UIColor whiteColor];
        [result addObject:button];
    }
    
    return result;
}





@end
