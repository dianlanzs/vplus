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

#import "ZLPlayerModel.h"



#import "LivePlayControl.h"

#import "CamSettingsController.h"


#import "DataBuilder.h"

#import "UIBarButtonItem+Item.h"


#import "samplefmt.h"
#import "LCVoiceHud.h"

#import "PCMPlayer.h"
#import "ReactiveObjC.h"


#import "ZLBrightnessView.h"
// player的单例
#define ZLPlayerShared                      [ZLBrightnessView sharedBrightnessView]


typedef int (^mydevice_data_callback)(int type, void *param, void *context);
mydevice_data_callback callBack;


@interface PlayVideoController () <ZLPlayerDelegate>
//@property (nonatomic, strong) ZLPlayerControlView *controlView;

@property (nonatomic, strong) ZLPlayerModel *playerModel;

//
//@property (nonatomic,strong)  Cam *cam;
//@property (nonatomic, strong) Device *device;
@end



@implementation PlayVideoController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavgation];
    [self.view setBackgroundColor:[UIColor whiteColor]];//消除Animated的残影
    [self.view addSubview:self.funcBar];//使用_funcBar，不显示，  cuz 没有走get 方法 self.funcBar!!
}

- (void)setNavgation {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(camSetting:)];
}
- (void)back:(id)sender {
    [self zl_playerBackAction];
}
- (void)zl_playerBackAction {
    [RLM transactionWithBlock:^{
        [self.operatingCam setCam_cover:[self.vp takeSnapshot]];//database
    }];
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)camSetting:(id)sender {
    QRootElement *camRoot = [[DataBuilder new] createForCamSettings:self.operatingCam device:self.operatingDevice];
    CamSettingsController *camSettingsVc = [[CamSettingsController alloc] initWithRoot:camRoot];
    [self.navigationController pushViewController:camSettingsVc animated:YES];
    
//    [((AMNavigationController *)self.navigationController) pushViewController:camSettingsVc deviceModel:self.operatingDevice camModel:self.operatingCam];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    
    [self vp];//config vp
    
    if (self.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
        [self.vp lv_start];
    }

    self.navigationItem.title = self.operatingCam.cam_name? [self.operatingCam.cam_name uppercaseString] : [self.operatingCam.cam_id uppercaseString];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
        [self.vp lv_stop];
    }
//    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
 

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

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden {
    return ZLPlayerShared.isStatusBarHidden;
}




#pragma mark - PlayerView 的代理

/*
- (NSString *)getDate{
    NSDate* date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//@"yyyy-MM-dd HH:mm:ss Z"
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}
*/

#pragma mark - getter
- (ZLPlayerView *)vp {
    if (!_vp) {
        _vp = [[ZLPlayerView alloc] initWithModel:self.playerModel control:[LivePlayControl new]  controller:self];
    }
    return _vp;
}
- (ZLPlayerModel *)playerModel {
    
    if (!_playerModel) {
        _playerModel                  = [[ZLPlayerModel alloc] init];
        _playerModel.title            = self.operatingCam.cam_name? [self.operatingCam.cam_name uppercaseString] : [self.operatingCam.cam_id uppercaseString];
        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        // _playerModel.resolutionDic = @{@"高清" : self.videoURL.absoluteString, @"标清" : self.videoURL.absoluteString};
//        [_playerModel setCam_id:((AMNavigationController *)self.navigationController).operatingCam.cam_id];
//        [_playerModel setNvr_h:((AMNavigationController *)self.navigationController).operatingDevice.nvr_h];
    }
    
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


