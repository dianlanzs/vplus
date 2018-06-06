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




#import "PlaybackControl.h"
#import "LivePlayControl.h"


#define ZLPlayerShared                      [ZLBrightnessView sharedBrightnessView]
#define AUTOOL [PCMPlayer sharedAudioManager]


typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};


@interface ZLPlayerView () <UIGestureRecognizerDelegate,UIAlertViewDelegate,ZLNvrDelegate,PlayerControlDelegate>

@property (nonatomic, assign) CGFloat                sliderLastValue;


@property (nonatomic, assign) PanDirection           panDirection;
@property (nonatomic, assign) BOOL                   isLocked;
@property (nonatomic, assign) BOOL                   isVolume;
@property (nonatomic, assign) BOOL                   didEnterBackground;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UIPanGestureRecognizer *shrinkPanGesture;
@property (nonatomic, strong) NSDictionary           *resolutionDic;
@property (nonatomic, strong) UIColor                *statusOriginBackgroundColor;


//@property (nonatomic, strong) CommonPlayerControl *commonControl;
/** 亮度view */
//@property (nonatomic, strong) ZLBrightnessView       *brightnessView;
@property (nonatomic, strong) CommonPlayerControl *functionControl;  //父类指针指向子类对象
@property (nonatomic, strong)  UIViewController *rootVc;


@end

@implementation ZLPlayerView

#pragma mark - Device delegate





- (void)device:(Device *)nvr sendAvData:(void *)data dataType:(int)type {
    
    [self setChekingFlag:1];
    if (type == CLOUD_CB_VIDEO) {
        cb_video_info_t *info = (cb_video_info_t *)data;
        if (info->end_flag) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pb_stop];
            });
        } else {
            AVFrame *pFrame_ = info->pFrame;
            int width = pFrame_->width;
            int height = pFrame_->height;
            CGFloat timestamp = (info->timestamp) / 1000;
            [self.glvc writeY:pFrame_->data[0] U:pFrame_->data[1] V:pFrame_->data[2] width:width height:height];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.state != ZLPlayerStatePlaying) {
                    [self setState:ZLPlayerStatePlaying];
                }
                if ([self.functionControl isKindOfClass:[PlaybackControl class]]) {
                    CGFloat valuePercent = timestamp / self.playerModel.cam_entity.timelength;
                    [self.functionControl zl_playerCurrentTime:timestamp totalTime:self.playerModel.cam_entity.timelength sliderValue:valuePercent];
                }
            });
            
            
        }
        
    }else if (type == CLOUD_CB_AUDIO) {
        cb_audio_info_t *info = (cb_audio_info_t *)data;
        AVFrame *pFrame_ = info->pFrame;
        [AUTOOL.mIn appendBytes:pFrame_->data[0] length:pFrame_->nb_samples * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)];
    }
}
- (void)checking {
    [self setChekingFlag:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.chekingFlag == 0 && self.playerModel.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
            [self setState:ZLPlayerStateBuffering];
        }
        else if (self.chekingFlag == 0 && self.playerModel.nvr_status == CLOUD_DEVICE_STATE_DISCONNECTED) {
            [self setState:ZLPlayerStateFailed];
        }
        else if (self.chekingFlag == 1 && self.playerModel.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
            [self setState:ZLPlayerStatePlaying];
        }
    });
}

//耳机插入、拔出事件
//- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
//}





#pragma mark - Getter,Setter
- (void)setState:(ZLPlayerState)state {
    if (state != _state) {
        _state = state;
        if (state == ZLPlayerStateFailed) {
            [self.functionControl.failBtn setHidden:NO];
            [self.spinner stopAnimating];
        } else {
            [self.functionControl.failBtn setHidden:YES];
            if (state == ZLPlayerStateBuffering) {
                [self.spinner startAnimating];
            } else if (state == ZLPlayerStatePlaying) {
                [self.spinner stopAnimating];
            } else if (state == ZLPlayerStateStopped) {
                [self.spinner stopAnimating];
            }
        }
        
    }
}

- (GLDrawController *)glvc {
    if (!_glvc) {
        _glvc = [[GLDrawController alloc] init];
        [_glvc setPreferredFramesPerSecond:15];
    }
    return _glvc;
}

- (RTSpinKitView *)spinner {
    if (!_spinner) {
        _spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce color:[UIColor whiteColor] spinnerSize:40.f];
        [_spinner hidesWhenStopped];
    }
    
    return _spinner;
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

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
//        [self setOrientationLandscapeConstraint:orientation];
        [self toOrientation:orientation];

    }
    else if (orientation == UIInterfaceOrientationPortrait) {
//        [self setOrientationPortraitConstraint];
        [self toOrientation:UIInterfaceOrientationPortrait];

    }
}
/*
- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation {
    [self toOrientation:orientation];
}
- (void)setOrientationPortraitConstraint {
    [self toOrientation:UIInterfaceOrientationPortrait];
}
*/
- (void)toOrientation:(UIInterfaceOrientation)needOrientation {
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (statusBarOrientation == needOrientation) {
        return;
        
    }
    else if (needOrientation != UIInterfaceOrientationPortrait && statusBarOrientation == UIInterfaceOrientationPortrait) {
        [self orientation:needOrientation];
    }
    else if (needOrientation == UIInterfaceOrientationPortrait && statusBarOrientation != UIInterfaceOrientationPortrait) {

        [self orientation:needOrientation];
    }
    
    //status bar rotate
    [[UIApplication sharedApplication] setStatusBarOrientation:needOrientation animated:NO];
    [self.functionControl setOrientation:needOrientation];
    
}

//key window  rotate
- (void)orientation:(UIInterfaceOrientation )Orientation{
    
    UIWindow *keyW =  [[UIApplication sharedApplication] keyWindow];
    if (Orientation == UIInterfaceOrientationPortrait) {
        
        [self.rootVc.navigationController setNavigationBarHidden:NO animated:NO];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.rootVc.view).offset(FunctionbarH);
            make.leading.trailing.equalTo(self.rootVc.view);
            make.height.mas_equalTo(211);
        }];
        [self.rootVc.navigationController.view bringSubviewToFront:self.rootVc.navigationController.navigationBar];
        [UIView animateWithDuration:0.5 animations:^{
            [keyW setTransform:CGAffineTransformIdentity];
        }];
        
        keyW.bounds = CGRectMake(0, 0, AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH); //cuz  width already changed when transform view
        [self.functionControl setFullScreen:NO];
    }else {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.rootVc.view);
        }];
        [self.rootVc.navigationController.view sendSubviewToBack:self.rootVc.navigationController.navigationBar];
        [UIView animateWithDuration:0.5 animations:^{
            [keyW setTransform:CGAffineTransformMakeRotation( M_PI_2)];
        }];
        keyW.bounds =  CGRectMake(0, 0, AM_SCREEN_HEIGHT, AM_SCREEN_WIDTH);
        [self.rootVc.navigationController setNavigationBarHidden:YES animated:NO];
        [self.functionControl setFullScreen:YES];

    }
}



- (void)onDeviceOrientationChange {
    //UIDeviceOrientation    是机器硬件的当前旋转方向   这个你只能取值 不能设置  但是通过kvc 这个可以设置 ,强制旋转
    //UIInterfaceOrientation 是你程序界面 vc 的当前旋转方向   设置 设备旋转方向，和设备方向值可能不一样
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)deviceOrientation;
    if (ZLPlayerShared.isLockScreen || self.didEnterBackground){//!self.playerModel.fatherView
        return; }
    //设备平放朝上，朝下
    if (deviceOrientation == UIDeviceOrientationFaceUp || deviceOrientation == UIDeviceOrientationFaceDown || deviceOrientation == UIDeviceOrientationUnknown || deviceOrientation == UIDeviceOrientationPortraitUpsideDown) { return; }
    if (interfaceOrientation == UIInterfaceOrientationPortrait  ) {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
        [self toOrientation:UIInterfaceOrientationLandscapeLeft];
    }
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
    
}

- (void)onStatusBarOrientationChange {
    
    if (!self.didEnterBackground) {
        
        // 获取到当前状态条的方向
        UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (statusBarOrientation == UIInterfaceOrientationPortrait) {
//            [self setOrientationPortraitConstraint];
            [self toOrientation:UIInterfaceOrientationPortrait];

            //            [self.brightnessView removeFromSuperview];
            //            [[UIApplication sharedApplication].keyWindow addSubview:self.brightnessView];
            //
            //            [self.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //                make.width.height.mas_equalTo(155);
            //                make.leading.mas_equalTo((AM_SCREEN_WIDTH - 155) * 0.5);
            //                make.top.mas_equalTo((AM_SCREEN_HEIGHT - 155 ) * 0.5);
            //            }];
        }else {
            
            if (statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
            }
            else if (statusBarOrientation == UIDeviceOrientationLandscapeLeft){
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            }
            //            [self.brightnessView removeFromSuperview];
            //            [self addSubview:self.brightnessView];
            //            [self.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //                make.center.mas_equalTo(self);
            //                make.width.height.mas_equalTo(155);
            //            }];
        }
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

#pragma mark - 播放,暂停,静音,重连
- (void)reconnect {
     cloud_connect_device((void *)self.playerModel.nvr_h, "admin", "123");
    [self lv_start];
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
    cloud_device_play_video((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);
    cloud_device_play_audio((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
    [AUTOOL startService:self.playerModel.nvr_h cam:self.playerModel.cam_id];
    [self fireTimer];
}
- (void)lv_stop {
    cloud_device_stop_video((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
    cloud_device_stop_audio((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
    [AUTOOL stopService];
    [self invalidTimer];
    [self setState:ZLPlayerStateStopped];

}

- (void)pb_start {
    cloud_device_cam_pb_play_file((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String], [self.playerModel.cam_entity.fileName UTF8String]);
    [AUTOOL startService:self.playerModel.nvr_h cam:self.playerModel.cam_id];
    [self fireTimer];
    [self.functionControl setPlayerEnd:NO];
    
    [self createPanGesture];
  
}
- (void)createPanGesture {
    // 加载完成后，再添加平移手势
    if (self.state == ZLPlayerStatePlaying) {
        // 添加平移手势，用来控制音量、亮度、快进快退
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        panRecognizer.delegate = self;
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelaysTouchesBegan:YES];
        [panRecognizer setDelaysTouchesEnded:YES];
        [panRecognizer setCancelsTouchesInView:YES];
        [self addGestureRecognizer:panRecognizer];
    }
}
- (void)pb_stop {

    cloud_device_cam_pb_stop((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);
    [AUTOOL stopService];
    [self invalidTimer];
    [self setState:ZLPlayerStateStopped];
    
    
    //UI Change
    [self.functionControl setPlayerEnd:YES];
    [self.functionControl hideControl];


}

- (void)zl_controlView:(UIView *)controlView muteAction:(UIButton *)muteButton {
    if (muteButton.isSelected) {
        cloud_device_stop_audio((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
        [AUTOOL setInput:NO output:NO];
    }else {
        cloud_device_play_audio((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
        [AUTOOL setInput:NO output:YES];
    }
}
#pragma mark - speaker
- (void)recordStart:(UIButton *)sender {
    [AUTOOL.volumeHUD show];
    cloud_device_speaker_enable((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);
    [AUTOOL setInput:YES output:NO];
}
- (void)disableRecord {
    [AUTOOL.volumeHUD hide];
    cloud_device_speaker_disable((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
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
        cloud_device_cam_pb_resume((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);
    }else {
        cloud_device_cam_pb_pause((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);
    }
}

- (void)zl_controlView:(UIView *)controlView progressSliderTap:(CGFloat)value {
    CGFloat timelength = self.playerModel.cam_entity.timelength;
    NSInteger ds = floorf(timelength * value);
    [self seekToTime:ds completionHandler:nil];
}


- (void)zl_controlView:(CommonPlayerControl *)controlView progressSliderValueChanged:(UISlider *)slider {
    cloud_device_cam_pb_pause((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);

    BOOL forward = NO;
    CGFloat value   = slider.value - self.sliderLastValue;
    if (value > 0) {
        forward = YES;
    }else if (value < 0) {
        forward = NO;
    }else{
        return;
    }
    self.sliderLastValue  = slider.value;
    CGFloat timelength = self.playerModel.cam_entity.timelength;
    NSInteger ds = floorf(timelength * slider.value);
    [controlView zl_playerDraggedTime:ds totalTime:timelength isForward:forward hasPreview:YES];//is fullscreen ?
    if (timelength > 0) {
        [controlView zl_playerDraggedTime:ds sliderImage:nil]; // cache images for every dragged time ((GLKView *)self.glvc.view).snapshot
    } else {
        slider.value = 0;
    }
}

- (void)zl_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider {
    CGFloat timelength = self.playerModel.cam_entity.timelength;
    NSInteger ds = floorf(timelength * slider.value);
    [self seekToTime:ds completionHandler:nil];
    cloud_device_cam_pb_resume((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);
}
- (void)seekToTime:(NSInteger)ds completionHandler:(void (^)(BOOL finished))completionHandler {
    cloud_device_cam_pb_seek_file((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String], (int)ds);
    [self.functionControl zl_playerDraggedEnd];
//    [self.commonControl  autoFadeOutControlView];
}
- (NSData *)takeSnapshot {
    GLKView *glk_view = (GLKView *)self.glvc.view;
    return  UIImageJPEGRepresentation([glk_view snapshot], 0.5f);
}

#pragma mark - Controlview Delegate
- (void)zl_controlView:(UIView *)controlView failAction:(UIButton *)sender {
    [self reconnect];
}
- (void)zl_controlView:(UIView *)controlView fullScreenAction:(UIButton *)sender {
    
    if (sender.isSelected) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    } else {
        //get device rotae direction
        [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight ? [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft]: [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}
- (void)zl_controlView:(UIView *)controlView backAction:(UIButton *)sender {
    self.functionControl.fullScreen ? [self interfaceOrientation:UIInterfaceOrientationPortrait] :  [self.delegate zl_playerBackAction];
}

- (void)zl_controlView:(UIView *)controlView lockScreenAction:(UIButton *)lockButton {
    lockButton.selected             = !lockButton.isSelected;
    ZLPlayerShared.isLockScreen = lockButton.isSelected;
}

//麦克风对讲
- (void)zl_controlView:(UIView *)controlView speakerAction:(UIButton *)sender {
    ;
}

//截屏按钮
- (void)zl_controlView:(UIView *)controlView snapAction:(UIButton *)sender {
    self.snapshot();
}
//录屏按钮
- (void)zl_controlView:(UIView *)controlView recordVideoAction:(UIButton *)recordButton {
    self.recordVideo(recordButton.isSelected);
}


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



#pragma mark - 手势识别 & 代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    /*在view上加了UITapGestureRecognizer之后，这个view上的所有触摸事件都被UITapGestureRecognizer给吸收了，所以要解决这个bug，要给这个手势代理加一些事件过滤，对button事件就不要拦截独吞了*/
//    if ([touch.view isKindOfClass:[UIControl class]]) {
//        return NO;
//    }
    return YES;
}
- (void)createGesture {
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1;
    self.singleTap.numberOfTapsRequired    = 1;
    [self addGestureRecognizer:self.singleTap];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if(touch.tapCount == 1) {
        [self performSelector:@selector(singleTapAction:) withObject:@(NO) ];
    }
    else if (touch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction:) object:nil];
        [self doubleTapAction:touch.gestureRecognizers.lastObject];
    }
}

- (void)singleTapAction:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.functionControl.playerEnd) {
            return;
        }
        if (!self.functionControl.isShowing) {
            [self.functionControl showControl];
        }else {
            [self.functionControl hideControl];
        }
    }
}
- (void)doubleTapAction:(UIGestureRecognizer *)gesture {
    return;
}

 
- (void)panDirection:(UIPanGestureRecognizer *)pan {
    
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) {
                self.panDirection = PanDirectionHorizontalMoved;
                // 给sumTime初值
                CMTime time       = self.player.currentTime;
                self.sumTime      = time.value/time.timescale;
            }
            
            else if (x < y) {
                
                self.panDirection = PanDirectionVerticalMoved;
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }
                else {
                    self.isVolume = NO;
                }
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x];
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y];
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
            
            
            
        case UIGestureRecognizerStateEnded: {
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self seekToTime:self.sumTime completionHandler:nil];
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}


- (void)horizontalMoved:(CGFloat)value {
    self.sumTime += value / 200;
    // 需要限定sumTime的范围
    CMTime totalTime           = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    
    BOOL style = false;
    if (value > 0) { style = YES; }
    if (value < 0) { style = NO; }
    if (value == 0) { return; }
    
    self.isDragged = YES;
    [self.controlView zl_playerDraggedTime:self.sumTime totalTime:totalMovieDuration isForward:style hasPreview:NO];
    
}

- (void)setFunctionControl:(CommonPlayerControl *)functionControl{
    if (functionControl != _functionControl) {
        _functionControl = functionControl;
        [self addSubview:self.functionControl];
        [_functionControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        _functionControl.delegate = self;
        [_functionControl resetControl];


    }
}

#pragma mark - 实例化
- (instancetype)initWithModel: (ZLPlayerModel *)vp_model control:(CommonPlayerControl *)control controller:(UIViewController *)vc {
    
    self = [super init];
    if (self) {

        self.playerModel = vp_model;
        [self addSubview:self.spinner];
        [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        [self setState:ZLPlayerStateUnknwon];
        [self setHasPreviewView:NO];
        
        
        [self addNotifications];
        [self createGesture];
        
        
        self.delegate = (id)vc;
        [self setRootVc:vc];
        [vc.view addSubview:self];
        self.frame = CGRectMake(0, 40, AM_SCREEN_WIDTH, AM_SCREEN_WIDTH * 0.5625); //16:9
        
        [vc addChildViewController:self.glvc];
        [self insertSubview:self.glvc.view atIndex:0]; //insert glview into bottom
        [self.glvc.view setFrame:self.bounds];
        [self.glvc didMoveToParentViewController:vc];
        //        [self.glvc setDelegate:self];
        
        [self setFunctionControl:control];

    }
    return self;
}

- (void)dealloc {
    //    self.playerModel = nil;
    //    ZLPlayerShared.isLockScreen = NO;
//    [self.controlView zl_playerCancelAutoFadeOutControlView];
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}




#pragma mark - 观察者、通知
- (void)addNotifications {
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processAppNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processAppNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 监听耳机插入和拔掉通知
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    // ** 监测设备方向 **
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications]; //陀螺仪计算 ，产生通知 ,这个方法有延迟
        
    });
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(onDeviceOrientationChange)
    //                                                 name:UIDeviceOrientationDidChangeNotification
    //                                               object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(onStatusBarOrientationChange)
    //                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
    //                                               object:nil];
    
    
}
- (void)processAppNotification:(NSNotification *)notification{
    if (notification.name == UIApplicationWillResignActiveNotification ) {
        [self setDidEnterBackground:YES];
    }
    else if (notification.name == UIApplicationDidBecomeActiveNotification) {
        [self setDidEnterBackground:NO];
    }
}





@end
