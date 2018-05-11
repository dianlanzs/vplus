//
//  ZLPlayerView.h
//  Kamu
//
//  Created by YGTech on 2018/1/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ZLPlayerView.h"
#import "UIView+ZLCustomControlView.h"



#import "ZLPlayer.h"
#import "ZLPlayerControlView.h"

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
    
    ZLPlayerStateFailed,     // 播放失败
    ZLPlayerStateBuffering,  // 缓冲中
    ZLPlayerStatePlaying,    // 播放中
    ZLPlayerStateStopped,    // 停止播放
    ZLPlayerStatePause       // 暂停播放
};



@interface ZLPlayerView : UIView <ZLPlayerControlViewDelegate>






/** 是否为全屏 */
@property (nonatomic, assign) BOOL                   isFullScreen;

//
//@property (nonatomic,strong) Device *cam;
//@property (nonatomic,assign) cloud_device_handle * handle;
//@property (nonatomic, strong) GLImageView *drawView;










/** 设置playerLayer的填充模式 */

//@property (nonatomic, assign) ZLPlayerLayerGravity    playerLayerGravity;


///MARK: 控制层 视图和模型
@property (nonatomic, strong) ZLPlayerControlView                 *controlView;
/** 是否有下载功能(默认是关闭) */
@property (nonatomic, assign) BOOL                    hasDownload;
/** 是否开启预览图 */
@property (nonatomic, assign) BOOL                    hasPreviewView;
/** 设置代理 */
@property (nonatomic, weak) id<ZLPlayerDelegate>      delegate;

/** 是否被用户暂停 */
@property (nonatomic, assign, readonly) BOOL          isPauseByUser;
/** 播发器的几种状态 */
@property (nonatomic, assign, readonly) ZLPlayerState state;

/** player在栈上，即此时push或者模态了新控制器 */
//@property (nonatomic, assign) BOOL                    isPushedOrPresented;
@property (nonatomic, assign) BOOL                    iscurrentPage;


/** 静音（默认为NO）*/
//@property (nonatomic, assign) BOOL                    isMuted;
/** 是否强制竖屏播放，默认为NO */
@property (nonatomic, assign) BOOL                    forcePortrait;





@property (nonatomic, strong) void (^stopVideo)();
@property (nonatomic, strong) void (^playVideo)();
@property (nonatomic, strong) void (^stopAudio)();
@property (nonatomic, strong) void (^playAudio)();


//======================= 存储 API =======================
@property (nonatomic, strong) void (^snapshot)();
@property (nonatomic, strong) void (^recordVideo)(BOOL isRecord);





- (void)playerControlView:(UIView *)controlView playerModel:(ZLPlayerModel *)playerModel;

//自动播放
- (void)configZLPlayer;
- (void)stopBuffering;
@end
