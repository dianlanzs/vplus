//
//  PlayLandscapeController.m
//  iLnkView
//


#import "PlayLandscapeController.h"
#import "MyGLViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

#import "PPPPManager.h"
#import "ApiManager.h"

#import "DeviceCell.h"


#import "CommonDefine.h"

@interface PlayLandscapeController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,PPPPManagerVideoDataDelegate,PPPPManagerCMDRecVDelegate,PPPPManagerStatusDelegate,PPPPManagerH264DataDelegate> {
   
    
    //---》成员变量
    BOOL speakerBtn; //扬声器开启／关闭按钮
    BOOL voiceBtn; //录音声音开启／关闭按钮
    BOOL leftRightBtn;
    PPPPManager * pppp;
}


//表格展现视图
@property (strong , nonatomic) UITableView *tableView;

//***//视频显示
@property (strong , nonatomic) MyGLViewController *myGLViewController;

//描述文本
@property (strong , nonatomic) UITextView * textView;

//Option  数据源
@property (strong , nonatomic) NSArray *dataSource;

//指令标签文字
@property (strong , nonatomic) NSMutableString * textStr;

@end








@implementation PlayLandscapeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //背景色 白色
    self.view.backgroundColor = [UIColor whiteColor];
    _dataSource = [NSArray array];
    
    //视频 Option
    _dataSource = @[@"流畅",@"标清",@"高清",@"麦克风",@"喇叭",@"左右翻转"];
    _textStr =[NSMutableString stringWithFormat:@"相关指令打印:"];
    
    
    // 默认 关闭，喇叭，麦克风 ，左右翻转 功能
    speakerBtn = NO;
    voiceBtn = NO;
    leftRightBtn = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
//加载UI
    [self loadUI];
    
    //设置 代理 ，状态代理， 指令接收回调代理
    [PPPPManager sharedPPPPManager].statusDelegate = self;
    [PPPPManager sharedPPPPManager].cmdRecvInDelegate = self;
    [self StartStream];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
    
    // 关闭 对应的 Device 流
    [[PPPPManager sharedPPPPManager]closePPPPLivestream:_dataModel.did];
    
    //辞去代理
    [PPPPManager sharedPPPPManager].statusDelegate = nil;
    [PPPPManager sharedPPPPManager].cmdRecvInDelegate = nil;
    
    
    //视图展现 控制器 指针 置为 0x00
    _myGLViewController = nil;
}



// 开始 连接
- (void)startPPPP {
    
    //关闭 device  连接的设备
    [[PPPPManager sharedPPPPManager] closePPPP:_dataModel.did];
    
    //开始 device 设备 连接
    [[PPPPManager sharedPPPPManager] startPPPP:_dataModel.did user:_dataModel.user pwd:_dataModel.pwd];
    
    //设置状态代理
    [PPPPManager sharedPPPPManager].statusDelegate = self;
}


#pragma mark - 核心方法， 开启流
- (void)StartStream {
    
    
    
    //发送
        int sendCodec = MEDIA_CODEC_AUDIO_G711A;
    //接收
        int recvCodec = MEDIA_CODEC_AUDIO_G711A;
    
    
    /// prams:  1. 设备号   2.音频发送code码:  3. 音频接收code码     4,video: 接收code码
        int ret = [[PPPPManager sharedPPPPManager] startPPPPLivestream:_dataModel.did url:@"" audio_send_codec:sendCodec audio_recv_codec:recvCodec video_recv_codec:0];
    
    
    //设置video数据代理
        [PPPPManager sharedPPPPManager].videoDataDelegate = self;
    
}



///=========停止流
- (void)StopStream {
    
    //调用停止 接口 ， 对应的deviceID
    [[PPPPManager sharedPPPPManager] closePPPPLivestream:_dataModel.did];
    
    
    //辞去视频数据 代理
    [PPPPManager sharedPPPPManager].videoDataDelegate = nil;
}



//发送指令后，再回调    ，deviceID：设备号 ,  nCmd:指令类型 ， cmdMsg: 指令信息 ，长度
- (void)ppppCallBackCMDRecV:(NSString *)did nCmd:(int)nCmd cmdMsg:(char *)cmdMsg length:(int)len {

    //十进制指令类型转换十六进制
    NSString * type = [self getHexByDecimal:nCmd];
    [_textStr appendFormat:@"指令回调：did----%@; Cmd----%@\n",did,type];
    dispatch_async(dispatch_get_main_queue(), ^{

       _textView.text = _textStr;
        [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];
    });
    
}


//转换十进制 指令 类型
- (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}



#pragma mark PPPPManagerVideoDataDelegate ---->视频回调
- (void)yuvData:(NSString *)did yuv:(Byte *)yuv nType:(int)nType length:(int)length width:(int)width height:(int)height timestamp:(int)timestamp {
   
    if(yuv==nil||length==0||width==0){
       
        return;
    }
    

//    NSLog(@"----%d----",timestamp);
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [_myGLViewController WriteYUVFrame:yuv Len:length width:width height:height];
        
    });
}



//H.264 data
-(void)VideoH264Data:(NSString *)did H264Data:(Byte *)data len:(int)len{
    
    // 没有data
    if(data==nil||len==0){
        return;
    }
    
    
}



//停止播放
- (void)StopPlay {
   
    //停止播放
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    [self StopStream];
}



- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}




#pragma mark UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    
    cell.deviceId.text = _dataSource[indexPath.row];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row <=2){
        [self updateStreamDefinition:indexPath.row + 1];
    }
    if( indexPath.row == 3 ){
        speakerBtn = !speakerBtn;
        [self updateAudioStatus];
    }
    if( indexPath.row == 4 ){
        voiceBtn = !voiceBtn;
        [self updateAudioStatus];
    }
    if( indexPath.row == 5 ){
        leftRightBtn = !leftRightBtn;
        [self updateCameraRotate];
    }
    [_textStr appendFormat:@"%@",[PPPPManager sharedPPPPManager].textStr];
    _textView.text = _textStr;
    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];
}

//摄像头分辨率
- (void)updateStreamDefinition:(NSInteger)channel {
    
    if (channel==2) {
        channel = PARAM_VALUE_CAMERA_ROVELUTION_SUB1;
    }else if(channel==1){
        channel = PARAM_VALUE_CAMERA_ROVELUTION_MAIN;
    }else{
        channel = PARAM_VALUE_CAMERA_ROVELUTION_SUB2;
    }
    [self executeCameraCtrl:VIDEO_PARAM_TYPE_RESOLUTION value:channel];
}







#pragma mark Device AudioStatus-----发送命令
- (void)updateAudioStatus {
    int status = 0;
    //状态码   如果是喇叭按钮 +2  、 +0
    status += (speakerBtn ? 2 : 0);
    
    //状态码 如果是声音按钮  +1 ，+0
    status += (voiceBtn ? 1 : 0);
    
    
    // 设置 设备号 ， 状态码值
   int result = [[PPPPManager sharedPPPPManager] setAudioStatus:_dataModel.did value:status];
    
    [_textStr appendFormat:@"did----%@;   result----%d\n",_dataModel.did,result];
    _textView.text = _textStr;
    
    //滚动 到 可见范围
    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];
    
}



//摄像头方向调节
- (void)updateCameraRotate {
    
    int status = 0;
    status += (!leftRightBtn ? 1 : 0);
    [self executeCameraCtrl:VIDEO_PARAM_TYPE_ROTATE value:status];
    
}



//摄像头参数设置
- (void)executeCameraCtrl:(int)param value:(NSInteger)value {
    
    NSInteger result = [ApiManager setCameraParam:_dataModel.did param:[NSString stringWithFormat:@"%d",param] value:[NSString stringWithFormat:@"%ld",(long)value]];
    [_textStr appendFormat:@"did----%@;   result----%ld\n",_dataModel.did,(long)result];
    _textView.text = _textStr;
    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];
    
    
}








#pragma mark UI加载
- (void)loadUI {

    //创建
    _myGLViewController = [[MyGLViewController alloc] init];
    
    //设置frame ,(0,0,0,0)
    _myGLViewController.view.frame = CGRectZero;
    
    // 再添加 （0，0，0，0）  ，，系统 childView 自动 inito
    [self.view addSubview:_myGLViewController.view];
    
    /*
     
     >>when embedding ,
     the child view controller’s view  ----> into the current view controller’s content.
     If the new child view controller is already the child of a container view controller, it is removed from that container before being added.

    */
    
    
    
        [self addChildViewController:_myGLViewController];

    
    
    
    
    
    //屏幕高度
//    CGFloat seviewheight = self.view.bounds.size.height;
    
    //屏幕宽度
    CGFloat seviewwidth = self.view.bounds.size.width;
    
    //NOTE :  更改 视频展现 view  的frame 200
    _myGLViewController.view.frame = CGRectMake(0, 64, seviewwidth, 200);
    
    
    
    //最后 添加控制器？？？？
//    [self addChildViewController:_myGLViewController];
    
    //文本视图
    _textView  = [[UITextView alloc]init];
    _textView.frame = CGRectMake(0, 200, seviewwidth, 300);
    
    //设置 文本布局 不连续
    _textView.layoutManager.allowsNonContiguousLayout = NO;
    //赋值
    _textView.text = _textStr;
    
    //添加 文本视图 到 父视图！！
    [self.view addSubview:_textView];
    //添加 tableView视图
    [self.view addSubview:self.tableView];
}


//tableView 设置！
- (UITableView *)tableView {
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/4*3, self.view.bounds.size.width, self.view.bounds.size.height/4) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithRed:240/255.0 green:236/255.0 blue:234/255.0 alpha:1];
        _tableView.bounces = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:nil] forCellReuseIdentifier:@"DeviceCell"];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
