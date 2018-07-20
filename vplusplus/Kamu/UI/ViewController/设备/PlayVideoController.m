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


//
//typedef int (^mydevice_data_callback)(int type, void *param, void *context);
//mydevice_data_callback callBack;


@interface PlayVideoController () <ZLPlayerDelegate>
@property (nonatomic, strong) ZLPlayerModel *playerModel;

@end



@implementation PlayVideoController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavgation];
    [self.view setBackgroundColor:[UIColor redColor]];
    
}
//- (void)dealloc {
////    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CLOUD_DEVICE_STATE" object:nil];
//}
- (void)setNavgation {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(camSetting:)];
}
- (void)back:(id)sender {
    [self zl_playerBackAction];
}
- (void)zl_playerBackAction {
    [RLM transactionWithBlock:^{
        [self.navigationController.operatingCam setCam_cover:[self.vp takeSnapshot]];//database
    }];
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)camSetting:(id)sender {
    QRootElement *camRoot = [[DataBuilder new] createForCamSettings:self.navigationController.operatingCam];
    CamSettingsController *camSettingsVc = [[CamSettingsController alloc] initWithRoot:camRoot];
    [self.navigationController pushViewController:camSettingsVc deviceModel:self.navigationController.operatingDevice camModel:self.navigationController.operatingCam];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self vp]; //config vp UI
    if (self.navigationController.operatingDevice.nvr_status  == CLOUD_DEVICE_STATE_CONNECTED) {
        [self.vp lv_start];
    }
    
    self.navigationItem.title = self.navigationController.operatingCam .cam_name? [self.navigationController.operatingCam.cam_name uppercaseString] : [self.navigationController.operatingCam.cam_id uppercaseString];
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
        [self.vp lv_stop];
        cloud_set_data_callback((void *)self.navigationController.operatingDevice.nvr_h, nil, nil);
    }
}


/// "viewDidDisappear" for  check nav  if exists!!
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    if (self.navigationController.operatingDevice.nvr_status  == CLOUD_DEVICE_STATE_CONNECTED) {
        /*
        if (self.navigationController && self.vp.functionControl.state != ZLPlayerStateEnd) {
            [self.vp.glvc setPaused:YES];
        } else if (!self.navigationController) {
            [self.vp lv_stop];
        }
         */
        [self.vp lv_stop];
    }
    ///must recover oringnal windows size!!
//    [UIApplication sharedApplication].keyWindow.bounds = CGRectMake(0, 0, MIN(AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH), MAX(AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH));

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    return NO; ///设置statusBar旋转 会 调用
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    ///可能 默认是 开启 陀螺仪的 ，每次旋转设备 会调用
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
    ////TURN OUT : 在 infoPlist 或者  在 app gennral deployment  设置 Landscape & portrait   和 maskAll 的交集
//    return UIInterfaceOrientationMaskPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden {
    return ZLPlayerShared.isStatusBarHidden;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return 0;
//}



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
        _playerModel.title            = self.navigationController.operatingCam.cam_name? [self.navigationController.operatingCam.cam_name uppercaseString] : [self.navigationController.operatingCam.cam_id uppercaseString];
        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        // _playerModel.resolutionDic = @{@"高清" : self.videoURL.absoluteString, @"标清" : self.videoURL.absoluteString};
//        [_playerModel setCam_id:((AMNavigationController *)self.navigationController).operatingCam.cam_id];
//        [_playerModel setNvr_h:((AMNavigationController *)self.navigationController).operatingDevice.nvr_h];
    }
    
    return _playerModel;
}





@end


