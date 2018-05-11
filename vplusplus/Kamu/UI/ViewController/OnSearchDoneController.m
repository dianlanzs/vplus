//
//  OnSearchDoneController.m
//  ilnkDemo
//
//  Created by YGTech on 2017/11/27.
//  Copyright © 2017年 com.ilnkDemo.cme. All rights reserved.
//

#import "OnSearchDoneController.h"

#import "ReactiveObjC.h"

#import "LanDeviceCell.h"
#import "Device.h"
@interface OnSearchDoneController ()<UITableViewDataSource,UITableViewDelegate,PopupDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end









@implementation OnSearchDoneController





#pragma mark - 生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view  addSubview:self.tableView];
    self.navigationItem.title = @"在线设备";
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







#pragma mark - TableView 数据源，代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _deviceList.count;
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LanDeviceCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"2" forIndexPath:indexPath];
    
    
        /* NOTE:  创建类目的是 设置View的属性 ，方便在VC里赋值  不是 [[LanDeviceCell alloc] init]  ------> cell 还是要通过Nib问卷加载
         
         1. 加载nib LoadNib/UINib 获取cell  不需要indexPath
         2. 注册nib 获取cell ，需要 indexPath 参数
         3. 注册Class 获取Cell ,需要IndexPath 参数
         
         */
//        cell = [[UINib nibWithNibName:@"OnlineDeviceCell" bundle:nil] instantiateWithOwner:nil options:nil].lastObject;


        Device *aDevice = _deviceList[indexPath.row];
//        cell.deviceType.attributedText = [NSAttributedString stringWithText:@"设备类型:IPC" withFont:[UIFont systemFontOfSize:15] color:[UIColor blackColor]
//                                        aligment:NSTextAlignmentLeft hasPrefix:nil];
    
        //设备号
        cell.deviceID.text =  [NSString stringWithFormat:@"设备号:%@",aDevice.did];
        //avatar
        cell.imv.image = [[UIImage imageNamed:@"icon_camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [[cell.addButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
    

            Popup *popup = [[Popup alloc] initWithTitle:@"添加Camera"
                                               subTitle:@"设备密码在设备底部，初始密码默认123"
                                  textFieldPlaceholders:@[@"请输入设备密码"]
                                            cancelTitle:@"取消"
                                           successTitle:@"确认"
                                            cancelBlock:^{
                                                //Custom code after cancel button was pressed
                                            } successBlock:^{
                                                //Custom code after success button was pressed
                                            }];
            [popup setDelegate:self];
            [popup setRoundedCorners:YES];
            
            //背景模糊
            [popup setBackgroundBlurType:PopupBackGroundBlurTypeDark];
            [popup setIncomingTransition:PopupIncomingTransitionTypeBounceFromCenter];
            [popup showPopup];
        
        }];

    return cell;
}










#pragma mark - Requierd

//Table View
- (UITableView *)tableView {
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, AM_SCREEN_WIDTH, AM_SCREEN_HEIGHT) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor lightGrayColor];
        
        _tableView.estimatedRowHeight = 80;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerNib:[UINib nibWithNibName:@"OnlineDeviceCell" bundle:nil] forCellReuseIdentifier:@"2"];
        
        
    }
    return _tableView;
}





@end
