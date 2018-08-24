//
//  ZLPlayerView.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "ZLPlayerView.h"
#import "PCMPlayer.h"


#import "ZLBrightnessView.h"


#import "PlaybackViewController.h"
#import "PlayVideoController.h"



#define PB_CONTROL                 ((PlaybackControl *)self.functionControl)
#define LP_CONTROL                 ((LivePlayControl *)self.functionControl)






#define OP_MEDIA                    (self.vc.navigationController.operatingMedia)


#define OP_DEVICE_STATUS            (self.vc.navigationController.operatingDevice.nvr_status)

#define OP_DEVICE_HANDLE            (self.vc.navigationController.operatingDevice.nvr_h)
#define OP_DEVICE                   (self.vc.navigationController.operatingDevice)

#define OP_CAM_ID                   (self.vc.navigationController.operatingCam.cam_id)
#define OP_CAM                      (self.vc.navigationController.operatingCam)
#define P_SCALE               0.5625



typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};


@interface ZLPlayerView () <UIGestureRecognizerDelegate,UIAlertViewDelegate,PlayerControlDelegate,ASValueTrackingSliderDataSource>

@property (nonatomic, assign) CGFloat                sliderLastValue;

//@property (nonatomic, copy) CLOUD_DEVICE_CALLBACK c;

@property (nonatomic, assign) PanDirection           panDirection;
@property (nonatomic, assign) BOOL                   isLocked;
@property (nonatomic, assign) BOOL                   ajustVolume;
@property (nonatomic, assign) BOOL                   didEnterBackground;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UIPanGestureRecognizer *shrinkPanGesture;
@property (nonatomic, strong) NSDictionary           *resolutionDic;
@property (nonatomic, strong) UIColor                *statusOriginBackgroundColor;
//@property (nonatomic, strong) ZLBrightnessView       *brightnessView;
@property (nonatomic, weak)  UIViewController *vc; ///MARK:  fatal Error :  circular refference , transform 诡异的 bug .Navigationbar 隐藏不了！！！
@property (nonatomic, assign) CGFloat                sumTime;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ZLPlayerView



#pragma mark - ASValueTrackingSliderDataSource
- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value {
    
    self.sliderLastValue  = value;
    NSInteger ts = OP_MEDIA.timelength;
    
    if (ts > 0) {
    NSInteger ds = floorf(ts * slider.value);
        if (slider.value - self.sliderLastValue > 0) {
            PB_CONTROL.fastImageView.image = ZLPlayerImage(@"ZLPlayer_fast_forward");
        } else {
            PB_CONTROL.fastImageView.image = ZLPlayerImage(@"ZLPlayer_fast_backward");
        }
        
        
        NSString *currentTimeString = [NSString stringWithFormat:@"%02lu:%02zd", ds / 60, ds % 60];
        NSString *totalTimeString      = [NSString stringWithFormat:@"%02lu:%02zd", ts / 60, ts % 60];
        NSString *timeString  = [NSString stringWithFormat:@"%@ / %@", currentTimeString, totalTimeString];
        
        ///zhoulei mark
        //    self.videoSlider.popUpView.hidden = !preview;
         PB_CONTROL.fastView.hidden              = NO; ///  = !preview
         PB_CONTROL.fastTimeLabel.text           = timeString;
         PB_CONTROL.bottomProgressView.progress  = value;
         PB_CONTROL.fastProgressView.progress    = value;
         PB_CONTROL.currentTimeLabel.text        = currentTimeString;
        
        return timeString;
    }
    
    else {
        slider.value = 0;
    }
    return nil;
}

//- (void)zl_playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image; {
//    NSInteger proMin = draggedTime / 60;//当前秒
//    NSInteger proSec = draggedTime % 60;//当前分钟
//    NSString *currentTimeStr = [NSString stringWithFormat:@"%02lu:%02zd", (long)proMin, proSec];
//    //    [self.videoSlider setImage:image];
////    self.functionControl.fastView.hidden = YES;
//}


//耳机插入、拔出事件
//- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
//}

#pragma mark - Getter,Setter

- (GLDrawController *)glvc {
    if (!_glvc) {
        _glvc = [[GLDrawController alloc] init];
        [_glvc setPreferredFramesPerSecond:15];
    }
    return _glvc;
}


//设置Model、、2. 在设置model
//- (void)setPlayerModel:(ZLPlayerModel *)playerModel {
//    _playerModel = playerModel;
//    [self.controlView zl_playerModel:playerModel];
//    
//
//    // 分辨率
//    if (playerModel.resolutionDic) {
//        self.resolutionDic = playerModel.resolutionDic;
//    }
////    [self addPlayerToFatherView:playerModel.fatherView];
//    //    self.videoURL = playerModel.videoURL;
//}


//- (void)addPlayerToFatherView:(UIView *)fatherView {
//    // 这里应该添加判断，因为view有可能为空，当view为空时[view addSubview:self]会crash
//    if (fatherView) {
//        //        [self removeFromSuperview];
//        
//        self.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.5];
//        [self addNotifications];
//        [self createGesture];
//        [fatherView setBackgroundColor:[UIColor greenColor]];
//        [fatherView addSubview:self];
//        
//        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(fatherView);
//        }];
//        
//    }
//}

// 明亮度 视图
//- (ZLBrightnessView *)brightnessView {
//
//    if (!_brightnessView) {
//        _brightnessView = [ZLBrightnessView sharedBrightnessView];
//    }
//    return _brightnessView;
//}

//设置系统音量静音
- (void)setSystemVolumeMute {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    // retrieve system volume
    //    float systemVolume = volumeViewSlider.value;
    
    // change system volume, the value is between 0.0f and 1.0f
    [volumeViewSlider setValue:0.0f animated:NO];
    
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 旋转屏幕
//- (void)toOrientation:(UIInterfaceOrientation)needOrientation {
//    ///MARK:有先后顺序 可能  状态栏旋转了  先改变了 window坐标系  即 MainScreen 的宽高！！
//    [self remakeConstraintsForOrientation:needOrientation];
////    [self.functionControl setOrientation:needOrientation];
//}
- (void)toOrientation:(UIInterfaceOrientation )orientation{
    
    UIWindow *window =  [[UIApplication sharedApplication] keyWindow];
    UIInterfaceOrientation statusBarOri = [UIApplication sharedApplication].statusBarOrientation;
    if (statusBarOri == orientation) {
        return;
    }
    
    
    
    
    
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO]; ///TURN-OUT  缝隙和 旋转状态栏有关系！！！！！！！！！！
    if (orientation == UIInterfaceOrientationPortrait) {
        window.bounds = CGRectMake(0, 0, MIN(AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH),MAX(AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH) );
        NSLog(@"portrait %@",NSStringFromCGRect(self.vc.view.bounds));

 
        ///navgationBar 置顶  ，reslove  低版本的bug
//        [self.vc.navigationController.view bringSubviewToFront:self.vc.navigationController.navigationBar];
        /// reslove  低版本的bug
        [self.vc.navigationController setNavigationBarHidden:NO animated:NO];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.vc.view).offset(self.funcBar.isHidden ? 0 : FunctionbarH);
            make.leading.trailing.equalTo(self.vc.view);
            make.height.mas_equalTo( MIN(AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH)  * P_SCALE);
        }];
        
        [UIView animateWithDuration:.3f animations:^{
            [window setTransform:CGAffineTransformIdentity];
        }];
        [self.functionControl setFullScreen:NO];
    }
    
    else {

       
        window.bounds = CGRectMake(0, 0, MAX(AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH),MIN(AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH) );
        NSLog(@"fullscreen %@",NSStringFromCGRect(self.vc.view.bounds));
        

      
        ///navgationBar （横屏 send到底部 ,player view在顶层） ，reslove  低版本的bug
//        [self.vc.navigationController.view sendSubviewToBack:self.vc.navigationController.navigationBar];
        /// reslove  低版本的bug
        [self.vc.navigationController setNavigationBarHidden:YES animated:NO];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
       ///cuz  方案2 适配低版本 ，没有隐藏navigationBar  所以view 还在navgationBar 下面
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
            make.edges.mas_equalTo(self.vc.navigationController.view).insets(UIEdgeInsetsZero);
            
            
        }];
        if (orientation == UIInterfaceOrientationLandscapeRight) {
            [UIView animateWithDuration:.3f animations:^{
                [window setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            }];
        }
        else if (orientation == UIInterfaceOrientationLandscapeLeft) {
            [UIView animateWithDuration:.3f animations:^{
                [window setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            }];
        }
        [self.functionControl setFullScreen:YES];
    }
    
//    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];

}

- (void)onDeviceOrientationChange {
    UIDeviceOrientation  deviceOri = [UIDevice currentDevice].orientation;// 是机器硬件的当前旋转方向   这个你只能取值 不能设置  但是通过kvc 这个可以设置 ,强制旋转
    NSLog(@"设备旋转了--- %ld",(long)deviceOri);
    if (deviceOri == UIDeviceOrientationUnknown || deviceOri == UIInterfaceOrientationPortraitUpsideDown || deviceOri ==  UIDeviceOrientationFaceUp ||deviceOri == UIDeviceOrientationFaceDown ) {
        return;
    }else {
        [self toOrientation:(UIInterfaceOrientation)deviceOri];
    }
    
}

- (void)changeStatusBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}
- (UIColor *)getOriginStatusBackgroundColor {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(backgroundColor)]) {
        return statusBar.backgroundColor;
    }
    return self.backgroundColor;
}

#pragma mark - cam重播,暂停,静音,设备重连
- (void)reconnect {
     cloud_connect_device((void *)OP_DEVICE_HANDLE, "admin", "123");
}
- (void)lp_replay {
    
    [self setChekingFlag:0]; /// must 立即设置 。lv_stop & lv_start 耗时 ,期间 flag 会 不停增加
    [self lv_stop];
    [self lv_start];
}
- (void)checking {
    
    self.chekingFlag += 5;
    NSLog(@"隔5s计时：----⏰%ld",(long)self.chekingFlag);
    if (self.timer.isValid) {  ///  for sync: reloved timer dealay 2s  --- invalid timer 同步 不调用 这里code
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ///正常出图情况 flag = 1 s 内  callback 修改 flag 值
            if (self.chekingFlag == 1) {
                ///cam 播放中...
                //                NSLog(@"VC--%@,NVR---%@ ---- CAM--%@",self.vc.navigationController,self.vc.navigationController.operatingDevice,self.vc.navigationController.operatingCam.cam_id);
                if(self.vc.navigationController && [self.functionControl isKindOfClass:[LivePlayControl class]]) {///保护 player不被释放前！
                    NSLog(@"1s后更新电池电量");
                    cloud_device_cam_get_info((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String]);
                }
            }else {
                if (OP_DEVICE_STATUS == CLOUD_DEVICE_STATE_CONNECTED) {
                  
                    if (self.chekingFlag >= 5 && self.chekingFlag < 20) {///缓冲
                        [self.functionControl setState:ZLPlayerStateBuffering];
                        
                    }
                    else if (self.chekingFlag >= 20) {///超时
                        if([self.functionControl isKindOfClass:[LivePlayControl class]] ) {
                            [self.timer invalidate];
                            [MBProgressHUD showError:[NSString stringWithFormat:@"timeout = 15 , flag =%ld",(long)self.chekingFlag]];
                            [self.functionControl setState:ZLPlayerStateReplay];
                        }
                    }
                }else {
                        [self.timer invalidate];
                        [self.functionControl setState:ZLPlayerStateFailed];
                }
            }
            
        });
    }
    
}


- (void)fireTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(checking) userInfo:nil repeats:YES];
    [_timer fire];

}
- (void)invalidTimer {
    [_timer invalidate];
    _timer = nil;
}


- (void)lv_start {
  
    [self.glvc setPaused:NO];
    cloud_set_event_callback((void *)OP_DEVICE_HANDLE, device_event_callback_camInfo,(__bridge void *)self);
    cloud_set_data_callback((void *)OP_DEVICE_HANDLE, device_data_callback, (__bridge void *)self);

    NSLog(@"%lu,%@",self.vc.navigationController.operatingDevice.nvr_h,self.vc.navigationController.operatingCam.cam_id);
    
//    cloud_device_cam_get_info((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String]);
    cloud_device_play_video((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String]);
    cloud_device_play_audio((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String]);
    [AUTOOL startService:OP_DEVICE_HANDLE cam:OP_CAM_ID];
    
    ///轮询检测设备连接状态 ,timer 立即执行 但换没有播放 ，会等出图 在获取 caminfo
    [self fireTimer];
    
}
- (void)lv_stop {
    if (self.timer.isValid) {
        [self invalidTimer];
    }
    [self.glvc setPaused:YES];
    cloud_device_stop_video((void *)OP_DEVICE_HANDLE, [OP_CAM_ID UTF8String]);
    cloud_device_stop_audio((void *)OP_DEVICE_HANDLE, [OP_CAM_ID UTF8String]);
    [AUTOOL stopService];
    
   
    [PB_CONTROL setState:ZLPlayerStateEnd];

}

- (void)pb_start {
    ///轮询检测设备连接状态
    [self fireTimer];
    cloud_set_data_callback((void *)OP_DEVICE_HANDLE, device_data_callback, (__bridge void *)self);
    [self.glvc setPaused:NO];
    [OP_DEVICE setAvDelegate:self];
    cloud_device_cam_pb_play_file((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String], [OP_MEDIA.fileName UTF8String]);
    [AUTOOL startService:OP_DEVICE_HANDLE cam:OP_CAM_ID];
    [PB_CONTROL setPlayerEnd:NO];
    
   
}



- (void)pb_end {
    if (self.timer.isValid) {
        [self invalidTimer];
    }
    [self.glvc setPaused:YES];
    cloud_device_cam_pb_stop((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String]);
    [AUTOOL stopService];
  
    [PB_CONTROL setState:ZLPlayerStateEnd];
}

- (void)pb_pause {
    if (self.timer.isValid) {
        [self invalidTimer];
    }
    [self.glvc setPaused:YES];
    cloud_device_cam_pb_pause((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String]);
    [PB_CONTROL setState:ZLPlayerStatePause];
}
- (void)pb_resume {
    cloud_device_cam_pb_resume((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String]);
    if (!self.timer.isValid) {
        [self fireTimer];
    }

    [self.functionControl setState:ZLPlayerStateBuffering];

}



#pragma mark - Speaker
- (void)recordStart:(UIButton *)sender {
    
    [AUTOOL.volumeHUD show];
    cloud_device_speaker_enable((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String]);
    [AUTOOL setInput:YES output:NO];
}
- (void)disableRecord {
    [AUTOOL.volumeHUD hide];
    cloud_device_speaker_disable((void *)OP_DEVICE_HANDLE, [OP_CAM_ID UTF8String]);
    [AUTOOL setInput:NO output:YES];
}
- (void)recordCancel:(UIButton *)sender {
    [self disableRecord];
}
- (void)recordEnd:(UIButton *)sender {
    [self disableRecord];
}

#pragma mark - trackSlider Delegate & playback


- (void)zl_controlView:(UIView *)controlView repeatPlayAction:(UIButton *)sender {
    [self pb_start];
}

- (void)zl_controlView:(UIView *)controlView playAction:(UIButton *)sender {
    
    if (sender.isSelected) {
        [self pb_pause];
    }else {
        [self pb_resume];
    }
}


- (void)zl_controlView:(UIView *)controlView progressSliderTap:(CGFloat)value {
    [self seekToTime:floorf(OP_MEDIA.timelength * value) completionHandler:nil];
}

- (void)zl_controlView:(CommonPlayerControl *)controlView progressSliderValueChanged:(UISlider *)slider {
  ///test
    ;
}

- (void)zl_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider {
    [self seekToTime:floorf(OP_MEDIA.timelength * slider.value) completionHandler:nil];
}
- (void)seekToTime:(NSInteger)ds completionHandler:(void (^)(BOOL finished))completionHandler {
    cloud_device_cam_pb_seek_file((void *)OP_DEVICE_HANDLE,[OP_CAM_ID UTF8String], (int)ds);
    [self.functionControl zl_playerDraggedEnd];
//    [self.commonControl  autoFadeOutControlView];
}
- (NSData *)snapshot {
    
    GLKView *v = (GLKView *)self.glvc.view;
//    return  UIImageJPEGRepresentation([(GLKView *)self.glvc.view snapshot], 0.5f);
    return UIImagePNGRepresentation([v snapshot]);
}

#pragma mark - 控制层 代理

///全屏事件
- (void)zl_controlView:(UIView *)controlView fullScreenAction:(UIButton *)sender {
    
    NSLog(@"oreitention = %zd",(long)[UIDevice currentDevice].orientation);
    ////all device oritentions is 1 portrait cuz vc set the support oritention portait only!!
    if (!self.functionControl.fullScreen) {
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    } else {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }
}

///返回
- (void)zl_controlView:(UIView *)controlView backAction:(UIButton *)sender {
    if (self.functionControl.fullScreen) {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }else {
        [self.delegate zl_playerBackAction];
    }
}
- (void)zl_controlView:(CommonPlayerControl *)controlView failAction:(UIButton *)sender {
    
    if(controlView.state == ZLPlayerStateFailed) {
         [self reconnect];///设备掉线 ，重连设备
    }else if(controlView.state == ZLPlayerStateReplay) {
        [self lp_replay];///设备连接    ，网络状况不好 重启 session --- 重新播放
    }
   
}

- (void)zl_controlView:(UIView *)controlView muteAction:(UIButton *)muteButton {
    if (muteButton.isSelected) {
        cloud_device_stop_audio((void *)OP_DEVICE_HANDLE, [OP_CAM_ID UTF8String]);
        [AUTOOL setInput:NO output:NO];
    }else {
        cloud_device_play_audio((void *)OP_DEVICE_HANDLE, [OP_CAM_ID UTF8String]);
        [AUTOOL setInput:NO output:YES];
    }
}

- (void)zl_controlView:(UIView *)controlView lockScreenAction:(UIButton *)lockButton {
    
    ///记录 🔐 状态 data
    lockButton.selected             = !lockButton.isSelected;
    ZLPlayerShared.isLockScreen = lockButton.isSelected;
    
    
    
    ///UI
    if(lockButton.isSelected) {
        [self removeDeviceOrientationNotifications ];
    }else {
       [self addDeviceOrientationNotifications ];
    }
    [self.functionControl showControl];
    
    
    
}

//麦克风对讲
- (void)zl_controlView:(UIView *)controlView speakerAction:(UIButton *)sender {
    ;
}

//截屏按钮
//- (void)zl_controlView:(UIView *)controlView snapAction:(UIButton *)sender {
//    self.snapshot();
//}
//录屏按钮
//- (void)zl_controlView:(UIView *)controlView recordVideoAction:(UIButton *)recordButton {
//    self.recordVideo(recordButton.isSelected);
//}


///MARK: 锁屏按钮
//- (void)lockScreenAction:(UIButton *)sender {
//    sender.selected             = !sender.isSelected;
//    self.isLocked               = sender.isSelected;
//    // 调用AppDelegate单例记录播放状态是否锁屏，在TabBarController设置哪些页面支持旋转
//    ZLPlayerShared.isLockScreen = sender.isSelected;
//}
//- (void)unLockTheScreen {
//    ZLPlayerShared.isLockScreen = NO;
//    [self.controlView zl_playerLockBtnState:NO];
//    self.isLocked = NO;
//    [self interfaceOrientation:UIInterfaceOrientationPortrait];
//}



#pragma mark - Touch事件,Gesture识别， hit-test ,响应者链模型

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint btnPoint_inSelf = [LP_CONTROL.speakerBtn_vertical convertPoint:point fromView:self];
        if (CGRectContainsPoint(LP_CONTROL.speakerBtn_vertical.bounds, btnPoint_inSelf) == true) {
            return LP_CONTROL.speakerBtn_vertical;
        }
    }
    return view;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    /*在view上加了UITapGestureRecognizer之后，这个view上的所有触摸事件都被UITapGestureRecognizer给吸收了，所以要解决这个bug，要给这个手势代理加一些事件过滤，对button事件就不要拦截独吞了*/
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

//playerview --single tap gesture
- (void)createTapGesture {
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1; //fingers
    self.singleTap.numberOfTapsRequired    = 1; //tap
    [self addGestureRecognizer:self.singleTap];
}
//playerview --single Pan gesture
- (void)createPanGesture {
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(oneFingerPan:)];
    panRecognizer.delegate = self;
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setCancelsTouchesInView:YES];
    [self addGestureRecognizer:panRecognizer];
}


//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    if(touch.tapCount == 1) {
//        [self performSelector:@selector(singleTapAction:) withObject:@(NO) ];
//    }

///双击 全屏
//    else if (touch.tapCount == 2) {
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction:) object:nil];
//        [self doubleTapAction:touch.gestureRecognizers.lastObject];
//    }
//}

- (void)oneFingerTap:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.functionControl.playerEnd) {
            return;
        }
        else if (!self.functionControl.isShowing) {
            [self.functionControl showControl];
        }else {
            [self.functionControl hideControl];
        }
    }
}
- (void)doubleTapAction:(UIGestureRecognizer *)gesture {
    return;
}

- (void)oneFingerPan:(UIPanGestureRecognizer *)pan {
    CGPoint locationPoint = [pan locationInView:self];
    CGPoint veloctyPoint =  [pan velocityInView:self];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        CGFloat x = fabs(veloctyPoint.x);
        CGFloat y = fabs(veloctyPoint.y);
        if (x > y) {
            self.panDirection = PanDirectionHorizontalMoved;
            ///记录滑动位置 seconds
            self.sumTime = PB_CONTROL.videoSlider.value * OP_MEDIA.timelength;
        }else if (x < y) {
            self.panDirection = PanDirectionVerticalMoved;
            if (locationPoint.x > self.bounds.size.width / 2) {
                [self setAjustVolume:YES];
            }else {
                [self setAjustVolume:NO];
            }
        }
    }
    
    else if (pan.state == UIGestureRecognizerStateChanged){
        if (self.panDirection == PanDirectionHorizontalMoved) {
            [self horizontalMoved:veloctyPoint.x];
        }else if (PanDirectionVerticalMoved) {
            [self verticalMoved:veloctyPoint.y];
        }
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        
        if (self.panDirection == PanDirectionHorizontalMoved) {
            [self seekToTime:self.sumTime completionHandler:nil];
        }else if (self.panDirection == PanDirectionVerticalMoved) {
             [self setAjustVolume:NO];
        }
    }
}


- (void)verticalMoved:(CGFloat)value {
//    self.ajustVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

- (void)horizontalMoved:(CGFloat)value {
    
    self.sumTime += value / 200;  //pan velocty_value ~> 1500 ~ 2500 points/s
    CGFloat totalMovieDuration = OP_MEDIA.timelength;
    if (self.sumTime > totalMovieDuration) {
        self.sumTime = totalMovieDuration;
    }else if (self.sumTime < 0) {
        self.sumTime = 0;
    }
    ///change slider value
    [PB_CONTROL.videoSlider setValue:self.sumTime / totalMovieDuration];
}

- (void)setFunctionControl:(CommonPlayerControl *)functionControl{
    
    if (functionControl != _functionControl) {
        _functionControl = functionControl;
        _functionControl.delegate = self;
        [self addSubview:self.functionControl];
        [_functionControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
       
        [self createTapGesture];
 
        ///check which control class
        if ([_functionControl isKindOfClass:[PlaybackControl class]]) {
            [PB_CONTROL.videoSlider setDataSource:self];
            [self createPanGesture];
        }else {
            /// make hit-test in superview  cuz no  custom class of bottomImageview ! remakeConstrints excute  must delay  before super view  allocated
            [self addSubview:LP_CONTROL.speakerBtn_vertical];
            [self.vc.view addSubview:self.funcBar];//使用_funcBar，不显示，  cuz 没有走get 方法 self.funcBar!!
            NSLog(@"%d",self.funcBar.isHidden);
        }
        
        
         [_functionControl resetControl]; ///finally reset control

    }
}

#pragma mark - 实例化
- (instancetype)initWithModel: (ZLPlayerModel *)vp_model control:(CommonPlayerControl *)control controller:(AMViewController *)vc {
    
    self = [super init];
    if (self) {
        [self setVc:vc];
        [self setFunctionControl:control];
//        cloud_set_event_callback((void *)OP_DEVICE_HANDLE, device_event_callback_camInfo,(__bridge void *)self);
        self.playerModel = vp_model;
        [self setHasPreviewView:NO];
        [self addAppStateNotifications];
        [self addDeviceOrientationNotifications];
        
        self.delegate = (id)vc;
    
        [vc.view addSubview:self];
        
        [vc addChildViewController:self.glvc];
        [self insertSubview:self.glvc.view atIndex:0];
        [self.glvc.view setFrame:self.bounds];
        [self.glvc didMoveToParentViewController:vc];
   
    }
    return self;
}

int device_event_callback_camInfo(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {
    
    ZLPlayerView *cs = (__bridge ZLPlayerView *)context;
    
    if (type == CLOUD_CB_CAM_INFO) {
        device_camera_info_t *info = (device_camera_info_t *)param;
        
        dispatch_sync(dispatch_get_main_queue(), ^{

            [cs.funcBar setBatteryProgress:info -> batttery];
            [cs.funcBar setWifiProgress:info -> wifi];
            NSLog(@"BATTERY %d --WIFI %d",info -> batttery,info -> wifi);
            
            
            NSString *cam_version = [NSString stringWithUTF8String:info->verison];
            NSString *cam_dbVersion = cs.vc.navigationController.operatingCam.cam_version;
            if (![cam_dbVersion isEqualToString:cam_version]) {
                [RLM transactionWithBlock:^{
                    [cs.vc.navigationController.operatingCam setCam_version:[NSString stringWithUTF8String:info->verison]];
                }];
            }
          
        });
    }
    return 0;
}

int device_data_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {
    
    
  
    ZLPlayerView *cs = (__bridge ZLPlayerView *)context;
    [cs setChekingFlag:1];
    if (type == CLOUD_CB_VIDEO) {
        cb_video_info_t *info = (cb_video_info_t *)param;
        if (info->end_flag) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [cs pb_end];
            });
        } else {
            AVFrame *pFrame_ = info->pFrame;
            int width = pFrame_->width;
            int height = pFrame_->height;
            CGFloat timestamp = (info->timestamp) / 1000;
            [cs.glvc writeY:pFrame_->data[0] U:pFrame_->data[1] V:pFrame_->data[2] width:width height:height];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (cs.functionControl.state != ZLPlayerStatePlaying) {
                    [cs.functionControl setState:ZLPlayerStatePlaying];
                }else if ([cs.functionControl isKindOfClass:[PlaybackControl class]]) {
                    CGFloat totalTime = cs.vc.navigationController.operatingMedia.timelength;
                    CGFloat valuePercent = timestamp / totalTime;
                    [cs.functionControl zl_playerCurrentTime:timestamp totalTime:totalTime sliderValue:valuePercent];
                }
            });
        }
        
    } else if (type == CLOUD_CB_AUDIO) {
        cb_audio_info_t *info = (cb_audio_info_t *)param;
        AVFrame *pFrame_ = info->pFrame;
        [AUTOOL.mIn appendBytes:pFrame_->data[0] length:pFrame_->nb_samples * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)];
    }
    return 0;
}
#pragma mark - 观察者、设备通知

- (void)addDeviceOrientationNotifications {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications]; //陀螺仪计算 ，产生通知 ,这个方法有延迟
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)removeDeviceOrientationNotifications {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications]; //陀螺仪计算 ，产生通知 ,这个方法有延迟
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)addAppStateNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processAppNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processAppNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
   
    // 监听耳机插入和拔掉通知
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(onStatusBarOrientationChange)
//                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
//                                                   object:nil];
}
- (void)processAppNotification:(NSNotification *)notification{
    if (notification.name == UIApplicationWillResignActiveNotification ) {
        [self setDidEnterBackground:YES];
        
    }
    else if (notification.name == UIApplicationDidBecomeActiveNotification) {
        [self setDidEnterBackground:NO];
    }
}
- (void)dealloc {
    //    self.playerModel = nil;
    //    ZLPlayerShared.isLockScreen = NO;
    //    [self.controlView zl_playerCancelAutoFadeOutControlView];
    // 移除通知
     NSLog(@"-------- player 释放 ------------");
   ///self 的域 已经释放 vc 已经释放 ，不能在这里 反注册！
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
}

- (FunctionView *)funcBar {
    if (!_funcBar) {
        _funcBar =  [[FunctionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.vc.view.bounds), FunctionbarH)];
        [_funcBar setBackgroundColor:[UIColor blueColor]];
        _funcBar.tintColor = [UIColor whiteColor];
    }
    return _funcBar;
}


@end
