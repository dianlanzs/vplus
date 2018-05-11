//
//  PlayVideoController.m
//  Kamu
//
//  Created by YGTech on 2017/12/12.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//



//定义‘DISPLAY’关闭
//#define SDL_DISPLAY

#ifdef SDL_DISPLAY
#import "SDL/SDL.h"
static SDL_Surface* screen = NULL;
static SDL_Rect rect;
#endif // SDL_DISPLAY


#import "AMNavigationController.h"

#import "MediaMuxer.h"


#import "PlayVideoController.h"
#import "GLDrawController.h"
#import "Waver.h"
#import "ZLPlayer.h"
#import "ZLPlayerModel.h"
#import "ZLPlayerView.h"

#import "CamSettingsController.h"
#import "FunctionView.h"


#import "DataBuilder.h"

#import "UIBarButtonItem+Item.h"


#import "samplefmt.h"
#import "LCVoiceHud.h"

#import "PCMPlayer.h"
/*
 定义cams 数组
 */
//struct CGPoint {
//
//    CGFloat handle;
//    NSString * camID;
//};

//static device_cam_info_t g_cam_info[4];
//static int g_cam_num = 0;

#define AUTOOL [PCMPlayer sharedAudioManager]

static CGFloat const kVideoH = 300.f;
static CGFloat const kFuncBarH = 40.f;
typedef int (^mydevice_data_callback)(int type, void *param, void *context);
mydevice_data_callback callBack;


@interface PlayVideoController () <ZLPlayerDelegate,ZLNvrDelegate> {
    
    //扬声器
    BOOL isSpeaker;
    //录音
    BOOL isRecord;
    BOOL LR_btn;
    
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) GLDrawController *glDrawVc;



//@property (nonatomic, strong)Waver *waver;



@property (nonatomic, strong) ZLPlayerControlView *controlView;
@property (strong, nonatomic) ZLPlayerView *playerView;
@property (nonatomic, strong) ZLPlayerModel *playerModel;







@property (nonatomic, strong) FunctionView *funcBar;
//@property (nonatomic, strong)UINavigationBar *navBar;





@end



@implementation PlayVideoController







#pragma mark - 生命周期方法
- (void)device:(Device *)nvr sendData:(void *)data dataType:(int)type {
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playerView.state == ZLPlayerStateBuffering) {
            [self.playerView stopBuffering];
        }
    });
    
    
    
    if (type == CLOUD_CB_VIDEO) {
        cb_video_info_t *info = (cb_video_info_t *)data;
//        if (info->cam_id == self.cam.cam_h) {
            AVFrame *pFrame_ = info->pFrame;
            int width = pFrame_->width;
            int height = pFrame_->height;
            [self.glDrawVc writeY:pFrame_->data[0] U:pFrame_->data[1] V:pFrame_->data[2] width:width height:height];
//        }
    }else if (type == CLOUD_CB_AUDIO) {
        cb_audio_info_t *info = (cb_audio_info_t *)data;
//        if (info->cam_id == self.cam.cam_h) {
            AVFrame *pFrame_ = info->pFrame;
            [AUTOOL.mIn appendBytes:pFrame_->data[0] length:pFrame_->nb_samples * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)];
//        }
        
    }
    
    
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];//消除Animated的残影
    [self setNavgation];
    [self setupView];
    self.nvrCell.nvrModel.delegate = self;
}






- (void)setNavgation {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(setting:)];
}
- (void)back:(id)sender {
    [self zl_playerBackAction];
}
- (void)setting:(id)sender {
    
    
//    [self.playerView setIscurrentPage:NO];//重要


    QRootElement *camRoot = [[DataBuilder new] createForCamSettings:(VideoCell *)[self.nvrCell.QRcv cellForItemAtIndexPath:self.indexpath] nvrCell:self.nvrCell];
    CamSettingsController *camSettingsVc = [[CamSettingsController alloc] initWithRoot:camRoot];
    [self.navigationController pushViewController:camSettingsVc animated:YES];
    
    
    camSettingsVc.deleteCam = ^{
        [self.glDrawVc setDelegate:nil];
        cloud_device_del_cam((void *)self.nvrCell.nvrModel.nvr_h, self.cam.cam_h);
        [RLM transactionWithBlock:^{
            [self.nvrCell.nvrModel.nvr_cams removeObjectAtIndex:self.indexpath.item];
        }];
        [self.nvrCell.QRcv reloadItemsAtIndexPaths:@[self.indexpath]];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [MBProgressHUD showSuccess:@"cam 已经删除"];
    };
    //        [weakObj.playerView setIsDisappeared:YES]; //push和present 时候 会不会走 viewWillDisapeard
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MBProgressHUD showPromptWithText:@"starting video & audio ..."];
    [self.playerView configZLPlayer];  ///MARK:可以设置成 单例 VETOOL
    [self zl_startAuido];
    self.navigationItem.title = self.cam.cam_name? [self.cam.cam_name uppercaseString] : [self.cam.cam_id uppercaseString];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self zl_stopAudio:nil]; //present  会不会走 disappear？？？？   EXP:证明PUSH会走  disappear!
    [self zl_stopVideo:nil];
    [MBProgressHUD showSuccess:@"closed succeed"];
}

- (void)viewDidDisappear:(BOOL)animated {
    //self 已经释放
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    ;
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
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *cover = [self takeSnapshot];
//        [self zl_stopAudio:nil];
//        [self zl_stopVideo:nil];
        
        VideoCell * c = (VideoCell *)[self.nvrCell.QRcv cellForItemAtIndexPath:self.indexpath];
        [c.playableView setImage:[UIImage imageWithData:cover]];
        [RLM transactionWithBlock:^{
            [self.cam setCam_cover:cover];//database
        }];
//    });
    
    [MBProgressHUD showSpinningWithMessage:@"in closing..." ];

   
}


#pragma mark - PlayerView 的代理
- (void)orientation:(UIInterfaceOrientation )Orientation{
    
    UIWindow *keyW =  [[UIApplication sharedApplication] keyWindow];
    if (Orientation == UIInterfaceOrientationPortrait) {

        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.funcBar.mas_bottom);
            make.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(211);
        }];
        [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
        
        [UIView animateWithDuration:0.5 animations:^{
            [keyW setTransform:CGAffineTransformIdentity];
        }];
        
        keyW.bounds = CGRectMake(0, 0, 375, 667);
        
    }else {
            [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view); //fill the container
        }];
        [self.navigationController.view sendSubviewToBack:self.navigationController.navigationBar];
        [UIView animateWithDuration:0.5 animations:^{
            [keyW setTransform:CGAffineTransformMakeRotation( M_PI_2)];
        }];
        keyW.bounds =  CGRectMake(0, 0, 667, 375);
       
    }
}





- (void)zl_startVideo:(ZLPlayerView *)playerView {
    if (self.cam.cam_h >= 0) {
        cloud_device_play_video((void *)self.nvrCell.nvrModel.nvr_h,self.cam.cam_h);
        [self.glDrawVc setPaused:NO];
    }
}

- (void)zl_stopVideo:(id)playerView {
    [self.glDrawVc setPaused:YES];
//    RLMThreadSafeReference *deviceRef = [RLMThreadSafeReference referenceWithThreadConfined:self.nvrCell.nvrModel];
//    @autoreleasepool {
//        RLMRealm *realm = [RLMRealm realmWithConfiguration:RLM.configuration error:nil];
//        Device *device = [realm resolveThreadSafeReference:deviceRef];
//        if (device) {
            cloud_device_stop_video((void *)self.nvrCell.nvrModel.nvr_h, self.cam.cam_h);
//    }

}





- (void)zl_muteAudio:(BOOL)isMuted {
    
    if (isMuted) {
        cloud_device_stop_audio((void *)self.nvrCell.nvrModel.nvr_h, self.cam.cam_h);
        [AUTOOL setInput:NO output:NO];
    }else {
        cloud_device_play_audio((void *)self.nvrCell.nvrModel.nvr_h, self.cam.cam_h);
        [AUTOOL setInput:NO output:YES];
        
    }
    
}

- (void)zl_startAuido {
    cloud_device_play_audio((void *)self.nvrCell.nvrModel.nvr_h, self.cam.cam_h);
    [AUTOOL startService:self.nvrCell.nvrModel.nvr_h cam:self.cam.cam_h];
}
- (void)zl_stopAudio:(id)playerView {
//    RLMThreadSafeReference *deviceRef = [RLMThreadSafeReference referenceWithThreadConfined:self.nvrCell.nvrModel];
//        @autoreleasepool {
//            RLMRealm *realm = [RLMRealm realmWithConfiguration:RLM.configuration error:nil];
//            Device *device = [realm resolveThreadSafeReference:deviceRef];
//            if (device) {
                cloud_device_stop_audio((void *)self.nvrCell.nvrModel.nvr_h, self.cam.cam_h);
//            }
//        }
    [AUTOOL stopService];
}

//开启录制
- (void)zl_startRecord:(id)playerView{
    [AUTOOL.volumeHUD show];
    cloud_device_speaker_enable((void *)self.nvrCell.nvrModel.nvr_h,self.cam.cam_h);
    [AUTOOL setInput:YES output:NO];
 
    

}

- (void)zl_cancelRecord:(id)playerView{
     [self disableRecord];
    
}
- (void)zl_endRecord:(id)playerView{
     [self disableRecord];
}
- (void)disableRecord {
    
    [AUTOOL.volumeHUD hide];
    cloud_device_speaker_disable((void *)self.nvrCell.nvrModel.nvr_h, self.cam.cam_h);
    [AUTOOL setInput:NO output:YES];
}


//获取当前时间戳
- (NSString *)getDate{
    NSDate* date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//@"yyyy-MM-dd HH:mm:ss Z"
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

- (NSData *)takeSnapshot {
    
    GLKView *glkView = (GLKView *)self.glDrawVc.view;
    UIImage *snapshot = [glkView snapshot];
    NSLog(@"已经截图！----》图片SIZE:%lu",[ UIImageJPEGRepresentation(snapshot, 0.5f) length]);
    return  UIImageJPEGRepresentation(snapshot, 0.5f);
    
}




#pragma mark - getter

- (UITableView *)tableView {
    
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 264, self.view.bounds.size.width, self.view.bounds.size.height - 264 - 49) style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor redColor];
    }
    
    return _tableView;
}



- (ZLPlayerModel *)playerModel {
    if (!_playerModel) {
        _playerModel                  = [[ZLPlayerModel alloc] init];
        _playerModel.title            = self.cam.cam_name? [self.cam.cam_name uppercaseString] : [self.cam.cam_id uppercaseString];
        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        //        _playerModel.resolutionDic = @{@"高清" : self.videoURL.absoluteString,
        //                                       @"标清" : self.videoURL.absoluteString};
    }
    return _playerModel;
}

- (ZLPlayerView *)playerView {
    
    if (!_playerView) {
        
        _playerView = [ZLPlayerView new];
        [self addChildViewController:self.glDrawVc];  //add child controller
        [_playerView addSubview:self.glDrawVc.view];
        [self.glDrawVc.view setFrame:_playerView.bounds];
        [self.glDrawVc didMoveToParentViewController:self];

        _playerView.hasPreviewView = YES; //可以设置缓冲数据 UI
        _playerView.delegate = self;

       
    }
    return _playerView;
}

- (GLDrawController *)glDrawVc {
    
    if (!_glDrawVc) {
        _glDrawVc = [GLDrawController new];
        [_glDrawVc setPreferredFramesPerSecond:30];
    }
    return _glDrawVc;
}


- (FunctionView *)funcBar {
    if (!_funcBar) {
        _funcBar =  [[FunctionView alloc] initWithFrame:CGRectZero];
        [_funcBar setBackgroundColor:[UIColor blueColor]];
        _funcBar.tintColor = [UIColor whiteColor];
    }
    return _funcBar;
}

#pragma mark - UI
- (void)setupView {
    
    [self.view addSubview:self.funcBar];//使用_funcBar，不显示，  cuz 没有走get 方法 self.funcBar!!
    [self.view addSubview:self.playerView];
    
    
    //translucent:    + 64
    self.playerView.frame = CGRectMake(0, kBtnH + 64, AM_SCREEN_WIDTH, AM_SCREEN_WIDTH * 0.5625); //16:9
    [self.playerView playerControlView:nil playerModel:self.playerModel];
    
    [self.funcBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.leading.trailing. equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(64);
        make.height.mas_equalTo(kBtnH);
    }];
    
    [self.navigationController.navigationBar setTranslucent:YES];//设置模糊，保持View 的尺寸全屏！！
}
@end


