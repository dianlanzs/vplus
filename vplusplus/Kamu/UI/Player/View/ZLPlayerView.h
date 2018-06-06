//
//  ZLPlayerView.h
//  Kamu
//
//  Created by Zhoulei on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GLDrawController.h"


#import "CommonPlayerControl.h"
@class ZLPlayerModel;


@protocol ZLPlayerDelegate <NSObject>



///协议回调
@optional
/** 返回按钮事件 */
- (void)zl_playerBackAction;
/** 下载视频 */
- (void)zl_playerDownload:(NSString *)url;

//ZL Delegate
- (void)orientation:(UIInterfaceOrientation )Orientation;
//播放
- (void)zl_startVideo:(id)playerView;
//- (void)zl_startAudio:(id)playerView;

//暂停
- (void)zl_stopVideo:(id)playerView;
- (void)zl_stopAudio:(id)playerView;
- (void)zl_muteAudio:(BOOL)isMuted;

//录制
- (void)zl_startRecord:(id)playerView;
- (void)zl_cancelRecord:(id)playerView;
- (void)zl_endRecord:(id)playerView;



@end




// 播放器的几种状态
typedef NS_ENUM(NSInteger, ZLPlayerState) {
    ZLPlayerStateUnknwon,
    ZLPlayerStateFailed,     // 播放失败
    ZLPlayerStateBuffering,  // 缓冲中
    ZLPlayerStatePlaying,    // 播放中
    ZLPlayerStateStopped,    // 停止播放
    ZLPlayerStatePause       // 暂停播放
};



@interface ZLPlayerView : UIView <ZLPlayerDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger chekingFlag;
@property (nonatomic, assign) BOOL  hasDownload;
@property (nonatomic, assign) BOOL hasPreviewView;
@property (nonatomic, weak) id<ZLPlayerDelegate> delegate;
@property (nonatomic, assign) ZLPlayerState          state;
@property (nonatomic, strong) RTSpinKitView *spinner;
@property (strong, nonatomic) GLDrawController *glvc;
@property (nonatomic, strong) void (^snapshot)();
@property (nonatomic, strong) void (^recordVideo)(BOOL isRecord);
@property (nonatomic, strong) ZLPlayerModel *playerModel;

- (NSData *)takeSnapshot;
- (instancetype)initWithModel: (ZLPlayerModel *)vp_model control:(CommonPlayerControl *)control controller:(UIViewController *)vc;

- (void)lv_stop;
- (void)lv_start;

- (void)pb_stop;
- (void)pb_start;

- (void)fireTimer;
- (void)invalidTimer;
@end
