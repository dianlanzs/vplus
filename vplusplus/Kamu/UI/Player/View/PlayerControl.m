//
//  PlayerControl.m
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "PlayerControl.h"
#import "CommonPlayerControl.h"

//
//
//static const CGFloat ZLPlayerAnimationTimeInterval             = 7.0f;
//static const CGFloat ZLPlayerControlBarAutoFadeOutTimeInterval = 0.35f;
//@interface PlayerControl()

//@property (nonatomic, strong) CommonPlayerControl * commonControl;
//
//@property (nonatomic, strong) UIView * bottomControl;
//@property (nonatomic, assign) UIInterfaceOrientation  orientation;

//
//@end
//
//
@implementation PlayerControl






//- (UIImageView *)placeholderImageView {
//    if (!_placeholderImageView) {
//        _placeholderImageView = [[UIImageView alloc] init];
//        _placeholderImageView.userInteractionEnabled = YES;
//    }
//    return _placeholderImageView;
//}

//- transformKvo {
//

/*
 
 full_screen   hide
  else
 
 */


//}



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
////
////
////}
//////布局 view 的时候 检测方向
//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//
//    //获取 '状态栏’ 方向
//    //    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
//    //    if (currentOrientation == UIDeviceOrientationPortrait) {
//    //        [self setOrientationPortraitConstraint];
//    //    }
//    //
//    //    else {
//    //        [self setOrientationLandscapeConstraint];
//    //    }
//}
//
//- (void)appDidEnterBackground {
//    [self zl_playerCancelAutoFadeOutControlView];
//}
////- (void)appDidEnterPlayground {
////    if (!self.isShrink) { [self zl_playerShowControlView]; }
////}
//- (void)hideControlView {
//    //全屏模式中 点击一下 隐藏状态栏！！
////    ZLPlayerView *player = (ZLPlayerView *)self.superview;
////    if (player.isFullScreen ) {
////        [ZLPlayerShared setIsStatusBarHidden:YES];
////    }
//    //    self.showing = NO;
//
//
//    [self zl_playerCancelAutoFadeOutControlView];
//    [self setAlpha:0];

    
    
//    [self.commonControl setShowing:NO];
//
//    [_commonControl setAlpha:0];
//
//
//    [_topControl setAlpha:0];
//    [_bottomControl setAlpha:0];
//}



//
//- (void)showControlView {
//    //没锁定 才show top & bottom   ,开锁是show操作，锁定是
//    ZLPlayerView *player = (ZLPlayerView *)self.superview;
//    if (!self.lockBtn.isSelected ) {
//        player.isFullScreen ? (self.topImageView.alpha = 1.f) : (self.topImageView.alpha = 0.f);
//        self.bottomImageView.alpha = 1.f;
//    }else {
//        self.topImageView.alpha    = 0.f;
//        self.bottomImageView.alpha = 0.f;
//    }
//    self.showing = YES;
//    self.lockBtn.alpha = 1.f;
//    self.alpha = 1.f;
//    ZLPlayerShared.isStatusBarHidden = NO;
//}
//
//- (void)zl_playerShowOrHideControlView {
//
//    self.isShowing ? [self zl_playerHideControlView] : [self zl_playerShowControlView];
//}




/**
 *  监听设备旋转通知
 */
//- (void)listeningOrientation {
//
//    //开始检测 屏幕旋转通知
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//
//    //接收 旋转通知 ‘UIDeviceOrientationDidChangeNotification’
////    [[NSNotificationCenter defaultCenter] addObserver:self
////                                             selector:@selector(onDeviceOrientationChange)
////                                                 name:UIDeviceOrientationDidChangeNotification
////                                               object:nil];
//}
///自动消退 间隔 7s

//- (void)autoFadeOutControlView {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(zl_playerHideControlView) object:nil];
//    [self performSelector:@selector(zl_playerHideControlView) withObject:nil afterDelay:ZLPlayerAnimationTimeInterval];
//}

#pragma mark - setter

//- (void)setShrink:(BOOL)shrink {
//    _shrink = shrink;
//    //关闭 按钮 --> 全屏 隐藏 ,不全屏展示 ，但超出屏幕边界
//    //    self.closeBtn.hidden = !shrink;
//    //全屏 显示
//    //    self.bottomProgressView.hidden = shrink;
//}
//设置全屏
//- (void)setFullScreen:(BOOL)fullScreen {
//
//    _fullScreen = fullScreen;
//    ZLPlayerShared.isLandscape = fullScreen; //也在 playerview 控制
//}

//- (void)setRecordBtn:(UIButton *)recordBtn {
//    recordBtn.selected = !recordBtn.selected;
//}

//- (void)zl_playerCancelAutoFadeOutControlView {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//}
//- (void)zl_playerModel:(ZLPlayerModel *)playerModel {
//    if (playerModel.title) { self.titleLabel.text = playerModel.title; }
//    // 优先设置网络占位图片
//    //    if (playerModel.placeholderImageURLString) {
//    //        [self.placeholderImageView setImageWithURLString:playerModel.placeholderImageURLString placeholder:ZLPlayerImage(@"ZLPlayer_loading_bgView")];
//    //    } else {
//    self.placeholderImageView.image = playerModel.placeholderImage;
//    //    }
//
//
//    //切换分辨率
//    if (playerModel.resolutionDic) {
//        [self zl_playerResolutionArray:[playerModel.resolutionDic allKeys]];
//    }
//
//
//}

//中心按钮点击
//- (void)centerPlayBtnClick:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(zl_controlView:centerPlayAction:)]) {
//        [self.delegate zl_controlView:self centerPlayAction:sender];
//    }
//}
//下载 按钮
//- (void)downloadBtnClick:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(zl_controlView:downloadVideoAction:)]) {
//        [self.delegate zl_controlView:self recordVideoAction:sender];
//    }
//}
// 切换分辨率 按钮
//- (void)resolutionBtnClick:(UIButton *)sender {
//    sender.selected = !sender.selected;
//    // 显示隐藏分辨率View
//    self.resolutionView.hidden = !sender.isSelected;
//}

//- (UIButton *)downLoadBtn {
//    if (!_downLoadBtn) {
//        _downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_downLoadBtn setImage:ZLPlayerImage(@"ZLPlayer_download") forState:UIControlStateNormal];
//        [_downLoadBtn setImage:ZLPlayerImage(@"ZLPlayer_not_download") forState:UIControlStateDisabled];
//        [_downLoadBtn addTarget:self action:@selector(downloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _downLoadBtn;
//}


































///**
// 是否有下载功能
// */
//- (void)zl_playerHasDownloadFunction:(BOOL)sender {
//    self.downLoadBtn.hidden = !sender;
//}
//
///** 锁定屏幕方向按钮状态 */
//- (void)zl_playerLockBtnState:(BOOL)state {
//    self.lockBtn.selected = state;
//}
//
///** 下载按钮状态 */
//- (void)zl_playerDownloadBtnState:(BOOL)state {
//    self.downLoadBtn.enabled = state;
//}

/**
 是否有切换分辨率功能
 */
//- (void)zl_playerResolutionArray:(NSArray *)resolutionArray {
//    self.resolutionBtn.hidden = NO;
//
//    _resolutionArray = resolutionArray;
//    [_resolutionBtn setTitle:resolutionArray.firstObject forState:UIControlStateNormal];
//    // 添加分辨率按钮和分辨率下拉列表
//    self.resolutionView = [[UIView alloc] init];
//    self.resolutionView.hidden = YES;
//    self.resolutionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
//
//    [self addSubview:self.resolutionView];
//
//    [self.resolutionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(40);
//        make.height.mas_equalTo(25*resolutionArray.count);
//        make.leading.equalTo(self.resolutionBtn.mas_leading).offset(0);
//        make.top.equalTo(self.resolutionBtn.mas_bottom).offset(0);
//    }];
//
//    // 分辨率View上边的Btn
//    for (NSInteger i = 0 ; i < resolutionArray.count; i++) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.layer.borderColor = [UIColor whiteColor].CGColor;
//        btn.layer.borderWidth = 0.5;
//        btn.tag = 200+i;
//        btn.frame = CGRectMake(0, 25*i, 40, 25);
//        btn.titleLabel.font = [UIFont systemFontOfSize:12];
//        [btn setTitle:resolutionArray[i] forState:UIControlStateNormal];
//        if (i == 0) {
//            self.resoultionCurrentBtn = btn;
//            btn.selected = YES;
//            btn.backgroundColor = RGBA(86, 143, 232, 1);
//        }
//        [self.resolutionView addSubview:btn];
//        [btn addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
//    }
//}


/** 正在播放（隐藏placeholderImageView） */
//- (void)zl_playerItemPlaying {
//    [UIView animateWithDuration:1.0 animations:^{
//        self.placeholderImageView.alpha = 0;
//    }];
//}

//展示 或者隐藏 控制层
//- (void)zl_playerShowOrHideControlView {
//
//    self.isShowing ? [self zl_playerHideControlView] : [self zl_playerShowControlView];
//}

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


// 点击切换分别率按钮
//- (void)changeResolution:(UIButton *)sender {
//
//    sender.selected = YES;
//    if (sender.isSelected) {
//        sender.backgroundColor = [UIColor colorWithRed:86 green:143 blue:232 alpha:1];
//
//    }else {
//        sender.backgroundColor = [UIColor clearColor];
//    }
//    self.resoultionCurrentBtn.selected = NO;
//    self.resoultionCurrentBtn.backgroundColor = [UIColor clearColor];
//    self.resoultionCurrentBtn = sender;
//    // 隐藏分辨率View
//    self.resolutionView.hidden  = YES;
//    // 分辨率Btn改为normal状态
//    self.resolutionBtn.selected = NO;
//    // topImageView上的按钮的文字
//    [self.resolutionBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
//    if ([self.delegate respondsToSelector:@selector(zl_controlView:resolutionAction:)]) {[self.delegate zl_controlView:self resolutionAction:sender];}
//}


//- (void)makeConstraints {
//
//
//
//    //    //播放按钮
//    //    [self.playerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//    //        make.width.height.mas_equalTo(50);
//    //        make.center.equalTo(self);
//    //    }];
//    //
//
//
//
//
//
//}









/**
 *  UISlider TapAction
 */






//切换分辨率
//- (UIButton *)resolutionBtn {
//    if (!_resolutionBtn) {
//        _resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//        _resolutionBtn.backgroundColor = RGBA(0, 0, 0, 0.7);
//        [_resolutionBtn addTarget:self action:@selector(resolutionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _resolutionBtn;
//}
//player Button
//- (UIButton *)playerBtn {
//    if (!_playerBtn) {
//        _playerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_playerBtn setImage:ZLPlayerImage(@"ZLPlayer_play_btn") forState:UIControlStateNormal];
//        [_playerBtn addTarget:self action:@selector(centerPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _playerBtn;
//}

@end
