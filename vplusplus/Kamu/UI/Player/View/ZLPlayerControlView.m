//
//  ZLPlayerControlView.m
//  Kamu
//
//  Created by YGTech on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//




#import "ZLPlayerControlView.h"
#import "ZLPlayerModel.h"
#import "UIView+ZLCustomControlView.h"
#import "UIView+EqualMargin.h"

#import "ReactiveObjC.h"

#import "LCVoice.h"

static const CGFloat ZLPlayerAnimationTimeInterval             = 7.0f;
static const CGFloat ZLPlayerControlBarAutoFadeOutTimeInterval = 0.35f;

@interface ZLPlayerControlView () <UIGestureRecognizerDelegate>
@property(nonatomic,strong) LCVoice * voice;

/** 标题 */
@property (nonatomic, strong) UILabel                 *titleLabel;

/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *startBtn;

/** 录屏按钮 */
@property (nonatomic, strong) UIButton                *recordBtn;

/** 截图按钮 */
@property (nonatomic, strong) UIButton                *captureBtn;

///** speaker */
//@property (nonatomic, strong) UIButton                *muteBtn;

/** 播放按钮 */
@property (nonatomic, strong) UIButton                *playerBtn;











/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *fullScreenBtn;


/** 系统菊花 */
//@property (nonatomic, strong) MMMaterialDesignSpinner *activity;


/** 返回按钮*/
@property (nonatomic, strong) UIButton                *backBtn;



/** bottomView*/
@property (nonatomic, strong) UIImageView             *bottomImageView;





/** 缓存按钮 */
@property (nonatomic, strong) UIButton                *downLoadBtn;
/** 切换分辨率按钮 */
@property (nonatomic, strong) UIButton                *resolutionBtn;
/** 当前选中的分辨率btn按钮 */
@property (nonatomic, weak  ) UIButton                *resoultionCurrentBtn;
/** 分辨率的View */
@property (nonatomic, strong) UIView                  *resolutionView;
/** 分辨率的名称 */
@property (nonatomic, strong) NSArray                 *resolutionArray;



/** 是否全屏播放 */
//@property (nonatomic, assign,getter=isFullScreen)BOOL fullScreen;
/** 小屏播放 */
@property (nonatomic, assign, getter=isShrink ) BOOL  shrink;



/** 显示控制层 */
@property (nonatomic, assign, getter=isShowing) BOOL  showing;
/** 占位图 */
@property (nonatomic, strong) UIImageView             *placeholderImageView;



/** 加载失败按钮 */
//@property (nonatomic, strong) UIButton                *failBtn;


@end














@implementation ZLPlayerControlView


#pragma mark - 实例化方法
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        
        
        
        [self addSubview:self.placeholderImageView];
        [self addSubview:self.topImageView];
        [self addSubview:self.bottomImageView];

        
        
        //底部栏 buttons
        [self.bottomImageView addSubview:self.captureBtn];
        [self.bottomImageView addSubview:self.speakerBtn_horizental];

        [self.bottomImageView addSubview:self.muteBtn];
        [self.bottomImageView addSubview:self.recordBtn];
        [self.bottomImageView addSubview:self.fullScreenBtn];
        
        
        [self addSubview:self.lockBtn];
        [self addSubview:self.playerBtn];
        [self addSubview:self.failBtn];
        
        
        
        //顶部栏 buttons
        //        [self.topImageView addSubview:self.downLoadBtn];
        [self.topImageView addSubview:self.backBtn];
        //        [self.topImageView addSubview:self.resolutionBtn];
        [self.topImageView addSubview:self.titleLabel];
   
        
        
        self.downLoadBtn.hidden     = YES;
        self.resolutionBtn.hidden   = YES;
        
        
        // 初始化时重置controlView
        [self zl_playerResetControlView];
        // 监听 app退到后台makeConstraints
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
//        // 监听 app进入前台
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
//        //监听 设备朝向 通知！
//        [self listeningOrientation];
        
        
        
        
        
        // Init LCVoice
        self.voice = [[LCVoice alloc] init];
        
        
    }
    
    
    return self;
}
//注销通知 和 移除监听者
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}
/** 重置ControlView */
- (void)zl_playerResetControlView {
    //    [self.activity stopAnimating];
    //    self.videoSlider.value           = 0;
    //    self.bottomProgressView.progress = 0;
    //    self.progressView.progress       = 0;
    //    self.currentTimeLabel.text       = @"00:00";
    //    self.totalTimeLabel.text         = @"00:00";
    //    self.fastView.hidden             = YES;
    //    self.repeatBtn.hidden            = YES;
    
    
    
    self.resolutionView.hidden       = YES;
    //    self.failBtn.hidden              = YES;
    self.backgroundColor             = [UIColor clearColor];
    self.downLoadBtn.enabled         = YES;
    //    self.shrink                      = NO;
    self.showing                     = NO;
    //    self.playeEnd                    = NO;
    
#warning LockBtn 设置
    //    /MARK:LockBtn 设置
//    self.lockBtn.hidden              = !self.isFullScreen;  //在playView 控制，竖屏隐藏lock button
    
    self.lockBtn.hidden   = YES;
    self.playerBtn.hidden             = YES;
    NSLog(@"配置控制层参数:%@",self);
    //    self.failBtn.hidden              = YES;
    self.placeholderImageView.alpha  = 1;
    [self showControlView];
}






////布局 view 的时候 检测方向
- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    //获取 '状态栏’ 方向
//    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (currentOrientation == UIDeviceOrientationPortrait) {
//        [self setOrientationPortraitConstraint];
//    }
//    
//    else {
//        [self setOrientationLandscapeConstraint];
//    }
}

- (void)appDidEnterBackground {
    [self zl_playerCancelAutoFadeOutControlView];
}
- (void)appDidEnterPlayground {
    if (!self.isShrink) { [self zl_playerShowControlView]; }
}



#pragma mark - 屏幕方向变化=========================
//- (void)onDeviceOrientationChange {
//    if (ZLPlayerShared.isLockScreen) { return; }
//    ///全屏 锁定按钮 出现 ， 全屏按钮 更改图标！！
//    self.lockBtn.hidden         = !self.isFullScreen;
//    self.fullScreenBtn.selected = self.isFullScreen;
//
//    //过滤掉其他 旋转！！
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationPortraitUpsideDown) { return; }
//    //
//    //    if (!self.isShrink && !self.isPlayEnd && !self.showing) {
//    //        // 显示、隐藏控制层
//    //        [self zl_playerShowOrHideControlView];
//    //    }
//
//    ///控制层隐藏，就显示
//    if (!self.showing) {
//        [self zl_playerShowOrHideControlView];
//    }
//
//}

///MARK: 控制层 控件的约束
//- (void)setOrientationLandscapeConstraint {
//
//    //    if (self.isCellVideo) {self.shrink = NO;}
//    self.fullScreen             = YES;
//    self.lockBtn.hidden         = !self.isFullScreen;
//    self.fullScreenBtn.selected = self.isFullScreen;
//    [self.backBtn setImage:ZLPlayerImage(@"ZLPlayer_back_full") forState:UIControlStateNormal];
//    [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.topImageView.mas_top).offset(23);
//        make.leading.equalTo(self.topImageView.mas_leading).offset(10);
//        make.width.height.mas_equalTo(40);
//    }];
//}

//- (void)setOrientationPortraitConstraint {
//
//    self.fullScreen             = NO;
//    self.lockBtn.hidden         = !self.isFullScreen;
//    self.fullScreenBtn.selected = self.isFullScreen;
//    [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.topImageView.mas_top).offset(3);
//        make.leading.equalTo(self.topImageView.mas_leading).offset(10);
//        make.width.height.mas_equalTo(40);
//    }];
//
//    //    if (self.isCellVideo) {
//    //        [self.backBtn setImage:ZLPlayerImage(@"ZLPlayer_close") forState:UIControlStateNormal];
//    //    }
//
//
//
//}






#pragma mark - Private Method ,,




/**
 *  监听设备旋转通知
 */
- (void)listeningOrientation {
    
    //开始检测 屏幕旋转通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    //接收 旋转通知 ‘UIDeviceOrientationDidChangeNotification’
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}


///自动消退 间隔 7s

- (void)autoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(zl_playerHideControlView) object:nil];
    [self performSelector:@selector(zl_playerHideControlView) withObject:nil afterDelay:ZLPlayerAnimationTimeInterval];
}

#pragma mark - setter

- (void)setShrink:(BOOL)shrink {
    _shrink = shrink;
    //关闭 按钮 --> 全屏 隐藏 ,不全屏展示 ，但超出屏幕边界
    //    self.closeBtn.hidden = !shrink;
    //全屏 显示
    //    self.bottomProgressView.hidden = shrink;
}
//设置全屏
//- (void)setFullScreen:(BOOL)fullScreen {
//
//    _fullScreen = fullScreen;
//    ZLPlayerShared.isLandscape = fullScreen; //也在 playerview 控制
//}

//- (void)setRecordBtn:(UIButton *)recordBtn {
//    recordBtn.selected = !recordBtn.selected;
//}

#pragma mark - 手势识别代理

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
#pragma mark - Public method ,对外方法

//播放按钮点击
- (void)playBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(zl_controlView:playAction:)]) {
        [self.delegate zl_controlView:self playAction:sender];
    }
}
/**
 *  取消延时隐藏controlView的方法
 */
- (void)zl_playerCancelAutoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/** 设置播放模型 */
- (void)zl_playerModel:(ZLPlayerModel *)playerModel {
    if (playerModel.title) { self.titleLabel.text = playerModel.title; }
    // 优先设置网络占位图片
    //    if (playerModel.placeholderImageURLString) {
    //        [self.placeholderImageView setImageWithURLString:playerModel.placeholderImageURLString placeholder:ZLPlayerImage(@"ZLPlayer_loading_bgView")];
    //    } else {
    self.placeholderImageView.image = playerModel.placeholderImage;
    //    }
    
    
    //切换分辨率
    if (playerModel.resolutionDic) {
        [self zl_playerResolutionArray:[playerModel.resolutionDic allKeys]];
    }
    
    
}

///MARK: 控制层 状态回调
//返回按钮点击
- (void)backBtnClick:(UIButton *)sender {
    /*
     // 在cell上并且是竖屏时候响应关闭事件
     UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
     if (self.isCellVideo && orientation == UIInterfaceOrientationPortrait) {
     if ([self.delegate respondsToSelector:@selector(zl_controlView:closeAction:)]) {
     [self.delegate zl_controlView:self closeAction:sender];
     }
     }  else { }
     */
    if ([self.delegate respondsToSelector:@selector(zl_controlView:backAction:)]) {[self.delegate zl_controlView:self backAction:sender];}
}
//中心按钮点击
- (void)centerPlayBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(zl_controlView:centerPlayAction:)]) {
        [self.delegate zl_controlView:self centerPlayAction:sender];
    }
}

- (void)zl_playerHideControlView {
    
    [self zl_playerCancelAutoFadeOutControlView];
    [self hideControlView];
}

- (void)hideControlView {
    
    //全屏模式中 点击一下 隐藏状态栏！！
    ZLPlayerView *player = (ZLPlayerView *)self.superview;
    if (player.isFullScreen ) {
        [ZLPlayerShared setIsStatusBarHidden:YES];
    }
    
    self.showing = NO;
    self.lockBtn.alpha = 0.f;
    self.alpha = 0.f;
    self.topImageView.alpha = 0.f;
    self.bottomImageView.alpha = 0.f;
    // 隐藏resolutionView
    self.resolutionBtn.selected = YES;
    [self resolutionBtnClick:self.resolutionBtn];
}

- (void)zl_playerShowControlView {

     [self zl_playerCancelAutoFadeOutControlView]; //cuz 要显示 ，先取消 上一次的自动隐藏 功能
     [self showControlView];
     [self autoFadeOutControlView]; //再过7秒 最终还是隐藏
    
}
- (void)showControlView {
    
        //没锁定 才show top & bottom   ,开锁是show操作，锁定是
    ZLPlayerView *player = (ZLPlayerView *)self.superview;
    if (!self.lockBtn.isSelected ) {
        player.isFullScreen ? (self.topImageView.alpha = 1.f) : (self.topImageView.alpha = 0.f);
        self.bottomImageView.alpha = 1.f;
    }else {
        self.topImageView.alpha    = 0.f;
        self.bottomImageView.alpha = 0.f;
    }
    
    
    self.showing = YES;
    self.lockBtn.alpha = 1.f;
    self.alpha = 1.f;
    ZLPlayerShared.isStatusBarHidden = NO;
}



/**
 是否有下载功能
 */
- (void)zl_playerHasDownloadFunction:(BOOL)sender {
    self.downLoadBtn.hidden = !sender;
}

/** 锁定屏幕方向按钮状态 */
- (void)zl_playerLockBtnState:(BOOL)state {
    self.lockBtn.selected = state;
}

/** 下载按钮状态 */
- (void)zl_playerDownloadBtnState:(BOOL)state {
    self.downLoadBtn.enabled = state;
}

/**
 是否有切换分辨率功能
 */
- (void)zl_playerResolutionArray:(NSArray *)resolutionArray {
    self.resolutionBtn.hidden = NO;
    
    _resolutionArray = resolutionArray;
    [_resolutionBtn setTitle:resolutionArray.firstObject forState:UIControlStateNormal];
    // 添加分辨率按钮和分辨率下拉列表
    self.resolutionView = [[UIView alloc] init];
    self.resolutionView.hidden = YES;
    self.resolutionView.backgroundColor = RGBA(0, 0, 0, 0.7);
    [self addSubview:self.resolutionView];
    
    [self.resolutionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(25*resolutionArray.count);
        make.leading.equalTo(self.resolutionBtn.mas_leading).offset(0);
        make.top.equalTo(self.resolutionBtn.mas_bottom).offset(0);
    }];
    
    // 分辨率View上边的Btn
    for (NSInteger i = 0 ; i < resolutionArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.layer.borderWidth = 0.5;
        btn.tag = 200+i;
        btn.frame = CGRectMake(0, 25*i, 40, 25);
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitle:resolutionArray[i] forState:UIControlStateNormal];
        if (i == 0) {
            self.resoultionCurrentBtn = btn;
            btn.selected = YES;
            btn.backgroundColor = RGBA(86, 143, 232, 1);
        }
        [self.resolutionView addSubview:btn];
        [btn addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
    }
}


/** 正在播放（隐藏placeholderImageView） */
- (void)zl_playerItemPlaying {
    [UIView animateWithDuration:1.0 animations:^{
        self.placeholderImageView.alpha = 0;
    }];
}

//展示 或者隐藏 控制层
- (void)zl_playerShowOrHideControlView {
    
    self.isShowing ? [self zl_playerHideControlView] : [self zl_playerShowControlView];
}

//
///** 加载的菊花 */
//- (void)zl_playerActivity:(BOOL)animated {
//
//    if (animated) {
//        [self.activity startAnimating];
//        self.fastView.hidden = YES;
//    } else {
//        [self.activity stopAnimating];
//    }
//}





#pragma mark - Action

- (void)failBtnClick:(UIButton *)sender {
    self.failBtn.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(zl_controlView:failAction:)]) {
        [self.delegate zl_controlView:self failAction:sender];
    }
}
// 点击切换分别率按钮
- (void)changeResolution:(UIButton *)sender {
    
    sender.selected = YES;
    if (sender.isSelected) {
        sender.backgroundColor = RGBA(86, 143, 232, 1);
    }else {
        sender.backgroundColor = [UIColor clearColor];
    }
    self.resoultionCurrentBtn.selected = NO;
    self.resoultionCurrentBtn.backgroundColor = [UIColor clearColor];
    self.resoultionCurrentBtn = sender;
    // 隐藏分辨率View
    self.resolutionView.hidden  = YES;
    // 分辨率Btn改为normal状态
    self.resolutionBtn.selected = NO;
    // topImageView上的按钮的文字
    [self.resolutionBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(zl_controlView:resolutionAction:)]) {[self.delegate zl_controlView:self resolutionAction:sender];}
}







- (void)captureBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(zl_controlView:snapAction:)]) {[self.delegate zl_controlView:self snapAction:sender];}
}

- (void)recordBtnClick:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    if ([self.delegate respondsToSelector:@selector(zl_controlView:recordVideoAction:)]) {
        [self.delegate zl_controlView:self recordVideoAction:sender];
    }
}

- (void)muteBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.delegate zl_controlView:self muteAction:sender];
}





- (void)recordStart:(UIButton *)sender{
    
    [self.delegate recordStart:sender];
//     [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.pcm", NSHomeDirectory()]];
//    [self.voice startRecordWithPath:@"/dev/null"]; // this path can not show hud for DB
}

- (void)recordEnd:(UIButton *)sender {
    //timer invalidate & hide HUD
//    [self.voice stopRecordWithCompletionBlock:^{
//        if (self.voice.recordTime > 0.0f) {
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"\nrecord finish ! \npath:%@ \nduration:%f",self.voice.recordPath,self.voice.recordTime] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//    }];

    
    //callback  event
    [self.delegate recordEnd:sender];
}

- (void)recordCancel:(UIButton *)sender {
    //time invalidate & hide HUD  & recoder == nil
//    [self.voice cancelled];
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"取消了" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//    [alert show];
    [self.delegate recordCancel:sender];

    
}






///锁屏按钮
- (void)lockScrrenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self zl_playerShowControlView];//show contorlView 时候要判断一下 ，锁定按钮状态
}
//全屏按钮
- (void)fullScreenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.delegate zl_controlView:self fullScreenAction:sender];
}

//下载 按钮
//- (void)downloadBtnClick:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(zl_controlView:downloadVideoAction:)]) {
//        [self.delegate zl_controlView:self recordVideoAction:sender];
//    }
//}
// 切换分辨率 按钮
- (void)resolutionBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    // 显示隐藏分辨率View
    self.resolutionView.hidden = !sender.isSelected;
}





#pragma mark - getter
- (UIButton *)failBtn {
    if (!_failBtn) {
        _failBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_failBtn setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failBtn.backgroundColor = RGBA(0, 0, 0, 0.7);
        [_failBtn addTarget:self action:@selector(failBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failBtn;
}
//视频名称
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"测试标题";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:ZLPlayerImage(@"ZLPlayer_play") forState:UIControlStateNormal];
        [_startBtn setImage:ZLPlayerImage(@"ZLPlayer_pause") forState:UIControlStateSelected];
        [_startBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}
- (UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordBtn setImage:ZLPlayerImage(@"button_recordScreen") forState:UIControlStateNormal];
        [_recordBtn setImage:ZLPlayerImage(@"button_recording") forState:UIControlStateSelected];
        
        [_recordBtn addTarget:self action:@selector(recordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}

- (UIButton *)captureBtn {
    if (!_captureBtn) {
        _captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captureBtn setImage:ZLPlayerImage(@"button_capture") forState:UIControlStateNormal];
        [_captureBtn addTarget:self action:@selector(captureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _captureBtn;
    
}
- (UIButton *)muteBtn {
    if (!_muteBtn) {
      
        _muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteBtn setImage:ZLPlayerImage(@"btn_speaker") forState:UIControlStateNormal];
        [_muteBtn setImage:ZLPlayerImage(@"btn_mute") forState:UIControlStateSelected];
        
        [_muteBtn addTarget:self action:@selector(muteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_muteBtn setSelected:YES];//zhoulei
    }
    return _muteBtn;
}

- (UIButton *)speakerBtn_horizental {
    if (!_speakerBtn_horizental) {
        _speakerBtn_horizental = [UIButton buttonWithType:UIButtonTypeCustom];
        [_speakerBtn_horizental setImage:ZLPlayerImage(@"speaker") forState:UIControlStateNormal];
        [self setActionForSpeaker:(UIButton *)_speakerBtn_horizental];
    }
    
    return _speakerBtn_horizental;
}

- (MRoundedButton *)speakerBtn_vertical {
    
    if (!_speakerBtn_vertical) {
//        _speakerBtn_vertical = [[MRoundedButton alloc] initWithFrame:CGRectMake( (AM_SCREEN_WIDTH - 70) * 0.5, (AM_SCREEN_HEIGHT + kVideoH + kFuncBarH + 20) * 0.5 , 60.f, 60.f) buttonStyle:MRoundedButtonCentralImage];
        _speakerBtn_vertical = [[MRoundedButton alloc] initWithFrame:CGRectZero buttonStyle:MRoundedButtonCentralImage];
        [_speakerBtn_vertical setSelected:NO];
        [_speakerBtn_vertical setBorderColor:[UIColor lightGrayColor]];
        [_speakerBtn_vertical setCornerRadius:FLT_MAX];
        [_speakerBtn_vertical setForegroundColor:[UIColor lightGrayColor]];
        [_speakerBtn_vertical setContentColor:[UIColor whiteColor]];
        [_speakerBtn_vertical setForegroundAnimateToColor:[UIColor blueColor]];
        [_speakerBtn_vertical.imageView setImage:[UIImage imageNamed:@"button_micophone_normal"]];
        
//        _speakerBtn_vertical = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeGray];
//        [_speakerBtn_vertical.layer setCornerRadius:30.f]; //只能设置 30
//        [_speakerBtn_vertical.layer setMasksToBounds:YES];
        [self setActionForSpeaker:(UIButton *)_speakerBtn_vertical];
    }
    return _speakerBtn_vertical;
}
- (void)setActionForSpeaker:(UIButton *)sender {
    [sender addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
    [sender addTarget:self action:@selector(recordEnd:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(recordCancel:) forControlEvents:UIControlEventTouchUpOutside];
}
//返回按钮
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:ZLPlayerImage(@"ZLPlayer_back_full") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}


//顶部遮罩图
- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView                        = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        //修改1
        _topImageView.alpha                  = 1;
        _topImageView.image                  = ZLPlayerImage(@"ZLPlayer_top_shadow");
        
    }
    return _topImageView;
}
//底部遮罩图
- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        //修改3
        _bottomImageView.alpha                  = 1;
        _bottomImageView.image                  = ZLPlayerImage(@"ZLPlayer_bottom_shadow");//ZLPlayer_bottom_shadow
    }
    return _bottomImageView;
}
//锁定，解锁 按钮
- (UIButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:ZLPlayerImage(@"ZLPlayer_unlock-nor") forState:UIControlStateNormal];
        [_lockBtn setImage:ZLPlayerImage(@"ZLPlayer_lock-nor") forState:UIControlStateSelected];
        [_lockBtn addTarget:self action:@selector(lockScrrenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _lockBtn;
}
//全屏
- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:ZLPlayerImage(@"ZLPlayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn setImage:ZLPlayerImage(@"ZLPlayer_shrinkscreen") forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}
//录屏按钮
//- (UIButton *)downLoadBtn {
//    if (!_downLoadBtn) {
//        _downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_downLoadBtn setImage:ZLPlayerImage(@"ZLPlayer_download") forState:UIControlStateNormal];
//        [_downLoadBtn setImage:ZLPlayerImage(@"ZLPlayer_not_download") forState:UIControlStateDisabled];
//        [_downLoadBtn addTarget:self action:@selector(downloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _downLoadBtn;
//}


//切换分辨率
- (UIButton *)resolutionBtn {
    if (!_resolutionBtn) {
        _resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _resolutionBtn.backgroundColor = RGBA(0, 0, 0, 0.7);
        [_resolutionBtn addTarget:self action:@selector(resolutionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resolutionBtn;
}
//player Button
- (UIButton *)playerBtn {
    if (!_playerBtn) {
        _playerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playerBtn setImage:ZLPlayerImage(@"ZLPlayer_play_btn") forState:UIControlStateNormal];
        [_playerBtn addTarget:self action:@selector(centerPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playerBtn;
}
//占位图
- (UIImageView *)placeholderImageView {
    if (!_placeholderImageView) {
        _placeholderImageView = [[UIImageView alloc] init];
        _placeholderImageView.userInteractionEnabled = YES;
    }
    return _placeholderImageView;
}


#pragma mark - 约束控件_外部 player调用（ player already initialized here）
- (void)makeConstraints {
    
    [self.superview addSubview:self.speakerBtn_vertical];

    
    [self.placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
   
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_top).offset(0);
        make.height.mas_equalTo(60);
    }];
    
    //返回按钮 约束 高度15
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topImageView.mas_leading).offset(10);
        make.top.equalTo(self.topImageView.mas_top).offset(20);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.downLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.topImageView.mas_trailing).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    
    [self.failBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(150, 40));
    }];
    
    //    [self.resolutionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.mas_equalTo(40);
    //        make.height.mas_equalTo(25);
    //        make.trailing.equalTo(self.downLoadBtn.mas_leading).offset(-10);
    //        make.centerY.equalTo(self.backBtn.mas_centerY);
    //    }];
    //
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.backBtn.mas_trailing).offset(5);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    

    
    
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];

    //锁定按钮
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(iPhoneX ? 35:15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(32);
    }];
    //播放按钮
    [self.playerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.center.equalTo(self);
    }];
 
    
    
    [RACObserve(self, orientation) subscribeNext:^(NSNumber  *x) {
        if (x.integerValue == UIInterfaceOrientationPortrait || x.integerValue == UIInterfaceOrientationUnknown) {
            
            
            [self.speakerBtn_horizental setHidden:YES];
            [self.speakerBtn_vertical setHidden:NO];
            //录制按钮
            [self.recordBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY);
                make.centerX.equalTo(self.bottomImageView).offset(AM_SCREEN_WIDTH * -0.3);
                make.width.height.mas_equalTo(30);
            }];

            //截图按钮
            [self.captureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY);
                make.centerX.equalTo(self.bottomImageView).offset(AM_SCREEN_WIDTH * -0.1);
                make.width.height.mas_equalTo(30);
            }];
            
            
            //垂直方向 的对讲按钮
            [self.speakerBtn_vertical mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.superview);
                make.centerY.equalTo(self.superview).offset(260);
                make.height.width.mas_equalTo(60);
            }];
            

            //声音按钮
            [self.muteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY);
                make.centerX.equalTo(self.bottomImageView).offset(AM_SCREEN_WIDTH * 0.1);
                make.width.height.mas_equalTo(30);
            }];

            //全屏按钮
            [self.fullScreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY);
                make.centerX.equalTo(self.bottomImageView).offset(AM_SCREEN_WIDTH * 0.3);
                make.width.height.mas_equalTo(30);
            }];
            
        }else {
    
            [self.speakerBtn_horizental setHidden:NO];
            [self.speakerBtn_vertical setHidden:YES];
            //录制按钮
            [self.recordBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY);
                make.centerX.equalTo(self.bottomImageView).offset(AM_SCREEN_WIDTH * -0.1667 * 2);
                make.width.height.mas_equalTo(30);
            }];

            //截图按钮
            [self.captureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY);
                make.centerX.equalTo(self.bottomImageView).offset(AM_SCREEN_WIDTH * -0.1667);
                make.width.height.mas_equalTo(30);
            }];
            
            //水平方向 的对讲按钮
            [self.speakerBtn_horizental mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY).offset(0);
                make.centerX.equalTo(self.bottomImageView);
                make.width.height.mas_equalTo(40);
            }];

            //声音按钮
            [self.muteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY);
                make.centerX.equalTo(self.bottomImageView).offset(AM_SCREEN_WIDTH * 0.1667);
                make.width.height.mas_equalTo(30);
            }];

            //全屏按钮
            [self.fullScreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.bottomImageView.mas_centerY);
                make.centerX.equalTo(self.bottomImageView).offset(AM_SCREEN_WIDTH * 0.1667 * 2);
                make.width.height.mas_equalTo(30);
            }];



        }
    }];
    
    

}



@end
