//
//  HomeViewController.m
//  ilnkDemo
//
//  Created by tom on 2017/11/10.
//  Copyright © 2017年 com.ilnkDemo.cme. All rights reserved.
//

#import "HomeViewController.h"
#import "PPPPManager.h"
#import "ApiManager.h"
#import "Device.h"
#import "DeviceCell.h"
#import "PlayLandscapeController.h"




//======= Reactive Cocoa=========
#import "RACSignal.h"
#import "UIControl+RACSignalSupport.h" //controlEvents
#import "NSObject+RACSelectorSignal.h"//行为 信号

#import "CommonDefine.h"


#import "AddDeviceViewController.h"
#import "UIBarButtonItem+Item.h"
@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,PPPPManagerStatusDelegate,UITextFieldDelegate>
@property (strong , nonatomic) UITableView *tableView;
@property (strong , nonatomic) NSMutableArray *dataSource;


//设备ID ，用户名，密码
@property (nonatomic ,strong) UITextField *deviceIdField;
@property (nonatomic ,strong) UITextField *userNameField;
@property (nonatomic ,strong) UITextField *passwordField;


//功能按钮
@property (nonatomic ,strong) UILabel * textLabel;
@property (nonatomic ,strong) UIButton *connectBtn;
@property (nonatomic ,strong) UIButton *pushBtn;
@property (nonatomic ,strong) UIButton *searchBtn;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
   
    //数据源
    _dataSource = [NSMutableArray array];
    self.navigationItem.title = @"摄像机";


    //设置右侧 item按钮
    UIImage *buttonItemimage =  [UIImage imageNamed:@"navigation_add"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:buttonItemimage style:UIBarButtonItemStylePlain target:self action:@selector(addButtonDidPressed:)];
    
    
    
    //加载UI界面
    [self loadUI];
    
}

- (void)viewWillAppear:(BOOL)animated{
    ///设置代理
    [PPPPManager sharedPPPPManager].statusDelegate = self;
    

    
}









- (void)StartPPPPThread {
    
    [[PPPPManager sharedPPPPManager] closePPPP:_deviceIdField.text];
    
    //手机和设备 都已经连了 云端 P2P P2P
    [[PPPPManager sharedPPPPManager] startPPPP:_deviceIdField.text user:_userNameField.text pwd:_passwordField.text];
    
}

#pragma - mark 搜索局域网 ipc 功能
- (void)startSearch {

    [_dataSource removeAllObjects]; //删除源

    //主队列 异步执行
    dispatch_async(dispatch_get_main_queue(), ^{
        //搜索的结果 数组
        NSArray * arr = [[PPPPManager sharedPPPPManager] NodeSearchCameraResult];
        
        if(arr.count>0){
            
            for (int i=0; i<arr.count; i++) {
                
                Device *device = [[Device alloc] init];
                device.did = [arr[i] valueForKey:@"DID"];
    //添加设备对象
                [_dataSource addObject:device];
                
            }

            //回主队列刷新表格视图数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                _textLabel.text = @"搜索完成";
            });
        }
        
    });
}

#pragma mark PPPPManager CallBack

/**

 @param strDID 设备ID
 @param statusType
 @param status 连接状态 请参照commonDefine.h  DeviceStatus
 */
- (void)ppppStatus:(NSString *)strDID statusType:(NSInteger)statusType status:(NSInteger)status {
    
    //MSG_NOTIFY_TYPE_PPPP_STATUS = 0
    if (statusType == MSG_NOTIFY_TYPE_PPPP_STATUS) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
       
        _textLabel.text = [NSString stringWithFormat:@"连接设备:%@ \n当前状态:%ld",strDID,(long)status];
        });
    }
}


#pragma mark UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    // 不需要 indexPath?????
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    Device *model = [_dataSource objectAtIndex:indexPath.row];
    cell.deviceId.text = model.did;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DeviceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    _deviceIdField.text = cell.deviceId.text;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}



- (void)buttonClick:(UIButton*)btn{
    
    
    //开始P2P 内网穿透！连接设备 ，手动输入
    if(btn.tag == 10){
        [self StartPPPPThread];
    }
    
    
    //进入视频  连接完成
    if(btn.tag == 20){
        //输入 设备 user，pwd
        Device * dev = [[Device alloc]init];
        dev.did = _deviceIdField.text;
        dev.user = _userNameField.text;
        dev.pwd = _passwordField.text;
        
        PlayLandscapeController * Vc = [[PlayLandscapeController alloc]init];
        Vc.dataModel = dev;
        [self.navigationController pushViewController:Vc animated:YES];
    }
    
    
    
    //搜索附近设备
    if(btn.tag == 30){
        _textLabel.text = @"正在搜索....";
        [self startSearch];
    }
    
}


#pragma mark --------------UI
- (void)loadUI {
    CGFloat viewheight = 50+10;
    CGFloat seviewwidth = self.view.bounds.size.width;
    
    _deviceIdField = [[UITextField alloc]initWithFrame:CGRectMake(0, 64, seviewwidth, 50)];
    _deviceIdField.backgroundColor = [UIColor lightGrayColor];
    _deviceIdField.returnKeyType = UIKeyboardTypeASCIICapable;
    _deviceIdField.textAlignment = NSTextAlignmentCenter;
    _deviceIdField.delegate = self;
    _deviceIdField.placeholder = @"deviceID";
    
    _userNameField = [[UITextField alloc]initWithFrame:CGRectMake(0, viewheight+64, seviewwidth, 50)];
    _userNameField.backgroundColor = [UIColor lightGrayColor];
    _userNameField.returnKeyType = UIKeyboardTypeASCIICapable;
    _userNameField.textAlignment = NSTextAlignmentCenter;
    _userNameField.delegate = self;
    _userNameField.placeholder = @"user";
    
    _passwordField = [[UITextField alloc]initWithFrame:CGRectMake(0, viewheight*2+64, seviewwidth, 50)];
    _passwordField.backgroundColor = [UIColor lightGrayColor];
    _passwordField.returnKeyType = UIKeyboardTypeASCIICapable;
    _passwordField.textAlignment = NSTextAlignmentCenter;
    _passwordField.delegate = self;
    _passwordField.placeholder = @"password";
    
    
    
    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, viewheight*3+64, seviewwidth, 80)];
    _textLabel.text = @"连接设备：------  \n当前状态：----";
    _textLabel.numberOfLines = 0;
    
    _connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _connectBtn.frame = CGRectMake(10, viewheight*3+64+80, 100, 44);
    [_connectBtn setTintColor:[UIColor whiteColor]];
    _connectBtn.backgroundColor = [UIColor redColor];
    [_connectBtn setTitle:@"连接设备" forState:UIControlStateNormal];
    
    //连接设备
    [[self.connectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [self buttonClick:_connectBtn];
        self.connectBtn.tag = 10;
    }];
    
    
    
    _pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _pushBtn.frame = CGRectMake(self.view.bounds.size.width-110, viewheight*3+64+80, 100, 44);
    [_pushBtn setTintColor:[UIColor whiteColor]];
    _pushBtn.backgroundColor = [UIColor redColor];
    [_pushBtn setTitle:@"进入视频" forState:UIControlStateNormal];
    
    //进入视频
    [[self.pushBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [self buttonClick:_pushBtn];
        self.pushBtn.tag = 20;
    }];

    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.frame = CGRectMake(10, viewheight*3+64+80+54, 200, 44);
    [_searchBtn setTintColor:[UIColor whiteColor]];
    _searchBtn.backgroundColor = [UIColor redColor];
    [_searchBtn setTitle:@"搜索附近设备" forState:UIControlStateNormal];

    
    //搜索信号
    
    
    [_searchBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    _searchBtn.tag = 30;
    
    //rac方法
//    [[_searchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//        [self buttonClick:_searchBtn];
//        _searchBtn.tag = 30;
//
//    }];
    
    [self.view addSubview:_deviceIdField];
    [self.view addSubview:_userNameField];
    [self.view addSubview:_passwordField];
    [self.view addSubview:_textLabel];
    [self.view addSubview:_connectBtn];
    [self.view addSubview:_pushBtn];
    [self.view addSubview:_searchBtn];
    
    ///***  添加到了self
    [self.view addSubview:self.tableView];
    
}

#pragma mark - data required
//设置视图属性
- (UITableView *)tableView {
    if (_tableView == nil) {
        
//        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopbarHeight, AM_SCREEN_WIDTH, 400) style:UITableViewStyleGrouped];

        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/3*2, self.view.bounds.size.width, self.view.bounds.size.height/3) style:UITableViewStyleGrouped];
        
        //设置代理
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.bounces = YES;
        
        //*** XIB 中 没有 注册 重用标志符  ，indexPath  不需要 判断为空了！！！！！
      [_tableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:nil] forCellReuseIdentifier:@"DeviceCell"];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - push vc 操作
- (void)addButtonDidPressed:(id)sender {
    
    //PlayLandscapeController * Vc = [[PlayLandscapeController alloc]init];
    //Vc.dataModel = dev;
    
    AddDeviceViewController * addDeviceVc = [[AddDeviceViewController alloc] init];
    
    [self.navigationController pushViewController:addDeviceVc animated:YES];

  
}



/*
- (void)initNavigationBarItem {
 
    UIImage *buttonImage = [UIImage imageNamed:@"navigation_add@2x"];
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (44 - buttonImage.size.height)/2, buttonImage.size.width, buttonImage.size.height)];
    
    //[addButton setImage:[UIImage imageNamed:@"navi_back_h"] forState: UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:buttonImage forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
}
*/
@end
