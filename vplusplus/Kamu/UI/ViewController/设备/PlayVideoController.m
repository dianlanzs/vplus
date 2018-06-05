//
//  PlayVideoController.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/12.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//



#import "AMNavigationController.h"

#import "MediaMuxer.h"


#import "PlayVideoController.h"
#import "GLDrawController.h"
#import "Waver.h"
#import "ZLPlayer.h"
#import "ZLPlayerModel.h"



#import "LivePlayControl.h"

#import "CamSettingsController.h"
#import "FunctionView.h"


#import "DataBuilder.h"

#import "UIBarButtonItem+Item.h"


#import "samplefmt.h"
#import "LCVoiceHud.h"

#import "PCMPlayer.h"
#import "ReactiveObjC.h"


#import "ZLBrightnessView.h"
// player的单例
#define ZLPlayerShared                      [ZLBrightnessView sharedBrightnessView]

static CGFloat FunctionbarH = 40;

typedef int (^mydevice_data_callback)(int type, void *param, void *context);
mydevice_data_callback callBack;


@interface PlayVideoController () <ZLPlayerDelegate>
//@property (nonatomic, strong) ZLPlayerControlView *controlView;
@property (strong, nonatomic) ZLPlayerView *vp;
@property (nonatomic, strong) ZLPlayerModel *playerModel;
@property (nonatomic, strong) FunctionView *funcBar;






@end



@implementation PlayVideoController

#pragma mark - 生命周期方法


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];//消除Animated的残影
    [self setNavgation];
    
    [self.view addSubview:self.funcBar];//使用_funcBar，不显示，  cuz 没有走get 方法 self.funcBar!!
    self.nvrCell.nvrModel.avDelegate = self.vp;    //translucent:    + 64
}

- (void)setNavgation {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(camSetting:)];
}
- (void)back:(id)sender {
    [self zl_playerBackAction];
}
- (void)camSetting:(id)sender {
    QRootElement *camRoot = [[DataBuilder new] createForCamSettings:(VideoCell *)[self.nvrCell.QRcv cellForItemAtIndexPath:self.indexpath] nvrCell:self.nvrCell];
    CamSettingsController *camSettingsVc = [[CamSettingsController alloc] initWithRoot:camRoot];
    [self.navigationController pushViewController:camSettingsVc animated:YES];
    
    camSettingsVc.deleteCam = ^{
        cloud_device_del_cam((void *)self.nvrCell.nvrModel.nvr_h, [self.cam.cam_id UTF8String]);
        [RLM transactionWithBlock:^{
            [self.nvrCell.nvrModel.nvr_cams removeObjectAtIndex:self.indexpath.item];
        }];
        [self.nvrCell.QRcv reloadItemsAtIndexPaths:@[self.indexpath]];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [MBProgressHUD showSuccess:@"cam 已经删除"];
    };
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.funcBar setBatteryProgress:cloud_device_cam_get_battery((void *)self.nvrCell.nvrModel.nvr_h ,[self.cam.cam_id UTF8String])];
    [self.funcBar setWifiProgress:cloud_device_cam_get_signal((void *)self.nvrCell.nvrModel.nvr_h,[self.cam.cam_id UTF8String])];
    [self.vp lv_start];
    self.navigationItem.title = self.cam.cam_name? [self.cam.cam_name uppercaseString] : [self.cam.cam_id uppercaseString];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.vp lv_stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [self.vp setState:ZLPlayerStateStopped];//maybe 2s dealay
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    NSLog(@"PlayerViewController relese!");
}


#pragma mark - 操作方法 //MARK: 注册回调操作,、、形参，Self不提示 没有self变量？？？
//- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
//
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//        SEL selector = NSSelectorFromString(@"setOrientation:");
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//        [invocation setSelector:selector];
//        [invocation setTarget:[UIDevice currentDevice]];
//        int val = orientation;
//        [invocation setArgument:&val atIndex:2];
//        [invocation invoke];
//    }
//}

//更新状态
//- (void)updateAudioStatus {
//
//}
//摄像头分辨率
//- (void)updateStreamDefinition:(NSInteger)channel {
//}
//摄像头方向调节
//- (void)updateCameraRotate {
//}
//摄像头参数设置
//- (void)executeCameraCtrl:(int)param value:(NSInteger)value{
//}




















#pragma mark - Player View ， 系统方法
//是否支持旋转
- (BOOL)shouldAutorotate {
    return NO;
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden {
    return ZLPlayerShared.isStatusBarHidden;
}

- (void)zl_playerBackAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    NSData *cover = [self.vp takeSnapshot];
    VideoCell * c = (VideoCell *)[self.nvrCell.QRcv cellForItemAtIndexPath:self.indexpath]; //cam cell
    [c.playableView setImage:[UIImage imageWithData:cover]];
    [RLM transactionWithBlock:^{
        [self.cam setCam_cover:cover];//database
    }];
}


#pragma mark - PlayerView 的代理
- (void)orientation:(UIInterfaceOrientation )Orientation{
    
    UIWindow *keyW =  [[UIApplication sharedApplication] keyWindow];
    if (Orientation == UIInterfaceOrientationPortrait) {

        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.vp mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.funcBar.mas_bottom);
            make.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(211);
        }];
        [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
        
        [UIView animateWithDuration:0.5 animations:^{
            [keyW setTransform:CGAffineTransformIdentity];
        }];
        
        keyW.bounds = CGRectMake(0, 0, AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH); //cuz  width already changed when transform view
    }else {
            [self.vp mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view); //fill the container
        }];
        [self.navigationController.view sendSubviewToBack:self.navigationController.navigationBar];
        [UIView animateWithDuration:0.5 animations:^{
            [keyW setTransform:CGAffineTransformMakeRotation( M_PI_2)];
        }];
        keyW.bounds =  CGRectMake(0, 0, AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH);
        
        [self.navigationController setNavigationBarHidden:YES animated:NO];

    }
}

- (NSString *)getDate{
    NSDate* date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//@"yyyy-MM-dd HH:mm:ss Z"
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}


#pragma mark - getter
- (ZLPlayerView *)vp {
    if (!_vp) {
        CommonPlayerControl *commonControl = [[CommonPlayerControl alloc] initWithFunction:[LivePlayControl new]];
        _vp = [[ZLPlayerView alloc] initWithModel:self.playerModel control:commonControl  controller:self];
    }
    return _vp;
}


- (ZLPlayerModel *)playerModel {
    
    if (!_playerModel) {
        _playerModel                  = [[ZLPlayerModel alloc] init];
        _playerModel.title            = self.cam.cam_name? [self.cam.cam_name uppercaseString] : [self.cam.cam_id uppercaseString];
        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        // _playerModel.resolutionDic = @{@"高清" : self.videoURL.absoluteString, @"标清" : self.videoURL.absoluteString};
        [_playerModel setCam_id:self.cam.cam_id];
        [_playerModel setNvr_h:self.nvrCell.nvrModel.nvr_h];
    }
    
    [_playerModel setNvr_status:self.nvrCell.nvrModel.nvr_status]; //每次访问 获取最新的 设备状态！
    
    return _playerModel;
}

- (FunctionView *)funcBar {
    if (!_funcBar) {
        _funcBar =  [[FunctionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), FunctionbarH)];
        [_funcBar setBackgroundColor:[UIColor blueColor]];
        _funcBar.tintColor = [UIColor whiteColor];
    }
    return _funcBar;
}



@end


