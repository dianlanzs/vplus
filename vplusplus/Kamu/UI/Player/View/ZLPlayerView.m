//
//  ZLPlayerView.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "ZLPlayerView.h"
#import "ZLPlayerControlViewDelegate.h"
#import "PCMPlayer.h"


#import "ZLBrightnessView.h"

#define ZLPlayerShared                      [ZLBrightnessView sharedBrightnessView]
#define AUTOOL [PCMPlayer sharedAudioManager]


typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};


@interface ZLPlayerView () <UIGestureRecognizerDelegate,UIAlertViewDelegate,ZLNvrDelegate>

@property (nonatomic, assign) CGFloat                sliderLastValue;



/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection           panDirection;
/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL                   isLocked;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                   isVolume;
/** 进入后台*/
@property (nonatomic, assign) BOOL                   didEnterBackground;
/** 单击 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
/** 双击 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UIPanGestureRecognizer *shrinkPanGesture;
@property (nonatomic, strong) NSDictionary           *resolutionDic;
@property (nonatomic, strong) UIColor                *statusOriginBackgroundColor;


@property (nonatomic, assign) NSInteger per_s;
/** 亮度view */
//@property (nonatomic, strong) ZLBrightnessView       *brightnessView;


@end

@implementation ZLPlayerView

#pragma mark - Device delegate
- (void)device:(Device *)nvr sendAvData:(void *)data dataType:(int)type {
    
    [self setChekingFlag:1];
    if (type == CLOUD_CB_VIDEO) {
        cb_video_info_t *info = (cb_video_info_t *)data;
        AVFrame *pFrame_ = info->pFrame;
        int width = pFrame_->width;
        int height = pFrame_->height;
        [self.glvc writeY:pFrame_->data[0] U:pFrame_->data[1] V:pFrame_->data[2] width:width height:height];
    }else if (type == CLOUD_CB_AUDIO) {
        cb_audio_info_t *info = (cb_audio_info_t *)data;
        AVFrame *pFrame_ = info->pFrame;
        [AUTOOL.mIn appendBytes:pFrame_->data[0] length:pFrame_->nb_samples * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)];
    }
}
- (void)checking {
    
//    CGFloat timelength = self.playerModel.cam_entity.timelength;
//    if (timelength > 0) {
//        _per_s += 5;
//        [self.controlView zl_playerCurrentTime:_per_s  totalTime:timelength sliderValue:_per_s / timelength];
//    }

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
            [self.controlView.failBtn setHidden:NO];
            [self.spinner stopAnimating];
        } else {
            [self.controlView.failBtn setHidden:YES];
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
- (ZLPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ZLPlayerControlView alloc] init];
        //        [_controlView makeConstraints]; //MARK: cuz use superview but self not yet returned
        _controlView.delegate = self;
    }
    return _controlView;
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
- (void)_fullScreenAction {
//    self.statusOriginBackgroundColor = [self getOriginStatusBackgroundColor];
//    if (ZLPlayerShared.isLockScreen) {
//        [self unLockTheScreen];
//        return;
//    }
    
    if (self.isFullScreen) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    } else {
         ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight ? [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft]: [self interfaceOrientation:UIInterfaceOrientationLandscapeRight]);
    }
   
}
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        [self setOrientationLandscapeConstraint:orientation];
    }
    else if (orientation == UIInterfaceOrientationPortrait) {
        [self setOrientationPortraitConstraint];
    }
}
- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation {
    [self toOrientation:orientation];
}
- (void)setOrientationPortraitConstraint {
//    [self addPlayerToFatherView:self.playerModel.fatherView];
    [self toOrientation:UIInterfaceOrientationPortrait];
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    if (isFullScreen) {
        [self.controlView.lockBtn setHidden:NO];
        [self.controlView zl_playerShowControlView];
    }else {
        [self.controlView.lockBtn setHidden:YES];
        [self.controlView zl_playerHideControlView];
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
            [self setOrientationPortraitConstraint];
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


///MARK:3.改变屏幕朝向 、 横屏/竖屏
- (void)toOrientation:(UIInterfaceOrientation)needOrientation {
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    // 判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (statusBarOrientation == needOrientation) { return; }
    if (needOrientation != UIInterfaceOrientationPortrait && statusBarOrientation == UIInterfaceOrientationPortrait) {
        [self setIsFullScreen:YES];
        [self.controlView.topImageView setHidden:NO];
        [self.delegate orientation:needOrientation];//回调设置 navBar 隐藏

    }
  
    else if (needOrientation == UIInterfaceOrientationPortrait && statusBarOrientation != UIInterfaceOrientationPortrait) {
        [self setIsFullScreen:NO];
        [self.controlView.topImageView setHidden:YES];
        [self.delegate orientation:needOrientation];
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:needOrientation animated:NO];
    [self.controlView setOrientation:needOrientation];

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
    [self start];
}
- (void)start {
    cloud_device_play_video((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);
    cloud_device_play_audio((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
    [AUTOOL startService:self.playerModel.nvr_h cam:self.playerModel.cam_id];
    [self.spinner startAnimating];
    [self fireTimer];
}
- (void)fireTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(checking) userInfo:nil repeats:YES];
    [_timer fire];
}
- (void)invalidTimer {
    [_timer invalidate];
    _timer = nil;
}
- (void)stop {
    cloud_device_stop_video((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
    cloud_device_stop_audio((void *)self.playerModel.nvr_h, [self.playerModel.cam_id UTF8String]);
    [AUTOOL stopService];
    [self invalidTimer];
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

#pragma mark - trackSlider Delegate

- (void)zl_controlView:(UIView *)controlView progressSliderTap:(CGFloat)value {
    CGFloat timelength = self.playerModel.cam_entity.timelength;
    NSInteger ds = floorf(timelength * value);
//    [self.controlView zl_playerPlayBtnState:YES];
    [self seekToTime:ds completionHandler:nil];
}

- (void)seekToTime:(NSInteger)ds completionHandler:(void (^)(BOOL finished))completionHandler {
    //        [self.controlView zf_playerActivity:YES];        [self.player pause]; 显示暂停图标
    cloud_device_cam_pb_seek_file((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String], (int)ds);
    [self.controlView zl_playerDraggedEnd];
    
}
- (void)zl_controlView:(ZLPlayerControlView *)controlView progressSliderValueChanged:(UISlider *)slider {
    BOOL forward;
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
        [controlView zl_playerDraggedTime:ds sliderImage:((GLKView *)self.glvc.view).snapshot]; // cache images for every dragged time
    } else {
        slider.value = 0;
    }
}

- (void)zl_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider {
    CGFloat timelength = self.playerModel.cam_entity.timelength;
    NSInteger ds = floorf(timelength * slider.value);
    [self seekToTime:ds completionHandler:nil];
}

- (NSData *)takeSnapshot {
    GLKView *glk_view = (GLKView *)self.glvc.view;
    return  UIImageJPEGRepresentation([glk_view snapshot], 0.5f);
}














#pragma mark - Controlview Delegate

///controlView  是不知道 是否旋转的 ，view 旋转事件是在   player 先接收到的  ❎
//====  controlView是知道要旋转的 ，因为 是控制层 发出的 指令
//但是 ，真正 发生旋转  是 在 vc 里 的 ，有 控制层 ---->  player ,----》 playerController控制器

//- (void)zl_controlViewWillShow:(ZLPlayerControlView *)controlView isFullscreen:(BOOL)fullscreen {
//    fullscreen ? [controlView.topImageView setHidden:NO] : [controlView.topImageView setHidden:YES];
//}

- (void)zl_controlView:(UIView *)controlView failAction:(UIButton *)sender {
    [self reconnect];
}

- (void)zl_controlView:(UIView *)controlView fullScreenAction:(UIButton *)sender {
    [self _fullScreenAction];
}
- (void)zl_controlView:(UIView *)controlView backAction:(UIButton *)sender {
//    [self changeStatusBackgroundColor:self.statusOriginBackgroundColor];
    self.isFullScreen ? [self interfaceOrientation:UIInterfaceOrientationPortrait] :  [self.delegate zl_playerBackAction];
    
}
//分辨率切换按钮
- (void)zl_controlView:(UIView *)controlView resolutionAction:(UIButton *)sender {
}
//锁屏按钮
- (void)zl_controlView:(UIView *)controlView lockScreenAction:(UIButton *)lockButton {
    //    // 调用AppDelegate单例记录播放状态是否锁屏，在TabBarController设置哪些页面支持旋转

//    lockButton.selected             = !lockButton.isSelected;
//    _isLocked = lockButton.isSelected;
//    ZLPlayerShared.isLockScreen = lockButton.isSelected;    // 调用AppDelegate单例记录播放状态是否锁屏
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
    if ([touch.view isKindOfClass:[UIControl class]]) {
        //放过button点击拦截
        return NO;
    }
    return YES;
}
- (void)createGesture {
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1; //手指数
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
    
    if ([gesture isKindOfClass:[NSNumber class]] && ![(id)gesture boolValue]) {
        [self _fullScreenAction];
        return;
    }
    //已经识别了 手势
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self.controlView zl_playerShowOrHideControlView];
    }
}
// 双击播放/暂停
- (void)doubleTapAction:(UIGestureRecognizer *)gesture {
    return;
}










/**
 *  pan 拖动手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */

/*
 
 - (void)panDirection:(UIPanGestureRecognizer *)pan {
 
 //根据在view上Pan的位置，确定是调音量还是亮度
 CGPoint locationPoint = [pan locationInView:self];
 // 我们要响应水平移动和垂直移动
 // 根据上次和本次移动的位置，算出一个速率的point
 CGPoint veloctyPoint = [pan velocityInView:self];
 
 
 // 判断是垂直移动还是水平移动
 switch (pan.state) {
 
 case UIGestureRecognizerStateBegan: { // 开始移动
 // 使用绝对值来判断移动的方向
 CGFloat x = fabs(veloctyPoint.x);
 CGFloat y = fabs(veloctyPoint.y);
 
 
 // 水平移动
 if (x > y) {
 
 // 取消隐藏
 self.panDirection = PanDirectionHorizontalMoved;
 // 给sumTime初值
 CMTime time       = self.player.currentTime;
 self.sumTime      = time.value/time.timescale;
 
 }
 
 // 垂直移动
 else if (x < y) {
 
 self.panDirection = PanDirectionVerticalMoved;
 // 开始滑动的时候,状态改为正在控制音量 ----->，右半边调节音量，  左半边调节亮度
 if (locationPoint.x > self.bounds.size.width / 2) {
 self.isVolume = YES;
 }
 
 else { // 状态改为显示亮度调节
 
 self.isVolume = NO;
 }
 }
 break;
 }
 
 
 
 
 
 case UIGestureRecognizerStateChanged: { // 正在移动
 
 
 switch (self.panDirection) {
 
 
 case PanDirectionHorizontalMoved:{
 [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
 break;
 }
 case PanDirectionVerticalMoved:{
 [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
 break;
 }
 
 default:
 break;
 }
 break;
 }
 
 
 
 
 case UIGestureRecognizerStateEnded: { // 移动停止
 // 移动结束也需要判断垂直或者平移
 // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
 switch (self.panDirection) {
 
 case PanDirectionHorizontalMoved:{
 self.isPauseByUser = NO;
 [self seekToTime:self.sumTime completionHandler:nil];
 // 把sumTime滞空，不然会越加越多
 self.sumTime = 0;
 break;
 }
 case PanDirectionVerticalMoved:{
 // 垂直移动结束后，把状态改为不再控制音量
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
 
 
 //pan 垂直移动
 - (void)verticalMoved:(CGFloat)value {
 self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
 }
 
 //pan 水平移动
 - (void)horizontalMoved:(CGFloat)value {
 // 每次滑动需要叠加时间
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
 
 
 
 
 
 */






//- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//
//    CGPoint csp_self = [self.controlView.speakerBtn_vertical convertPoint:point fromView:self];
//    if (CGRectContainsPoint(self.controlView.speakerBtn_vertical.bounds, csp_self) == true) {
//        return YES;
//    }else {
//        return [super pointInside:point withEvent:event];
//    }
//   
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == nil) {
        //转换 button‘s point  的坐标系
        CGPoint csp_self = [self.controlView.speakerBtn_vertical convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.controlView.speakerBtn_vertical.bounds, csp_self) == true) {
            return self.controlView.speakerBtn_vertical;
        }
    }
    
    return view;
    
}

#pragma mark - 实例化
- (instancetype)initWithModel: (ZLPlayerModel *)vp_model controller:(UIViewController *)vc {
    self = [super init];
    if (self) {
        self.playerModel = vp_model;
        [self addSubview:self.spinner];
        [self addSubview:self.controlView];
        [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        [self.controlView makeConstraints];
        [self setState:ZLPlayerStateUnknwon];
        [self setIsFullScreen:NO];//db
        [self setHasPreviewView:NO];//db
        
        
        [self addNotifications];
        [self createGesture];
        
        
        self.delegate = (id)vc;
        [vc.view addSubview:self];
        self.frame = CGRectMake(0, 40, AM_SCREEN_WIDTH, AM_SCREEN_WIDTH * 0.5625); //16:9
        
        [vc addChildViewController:self.glvc];
        [self insertSubview:self.glvc.view atIndex:0]; //insert glview into bottom
        [self.glvc.view setFrame:self.bounds];
        [self.glvc didMoveToParentViewController:vc];
        //        [self.glvc setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    //    self.playerModel = nil;
    //    ZLPlayerShared.isLockScreen = NO;
    [self.controlView zl_playerCancelAutoFadeOutControlView];
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
