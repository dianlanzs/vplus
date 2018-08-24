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
#import "PlaybackControl.h"
#import "LivePlayControl.h"
#import "FunctionView.h"

#define ZLPlayerShared                      [ZLBrightnessView sharedBrightnessView]


#define AUTOOL [PCMPlayer sharedAudioManager]

typedef NS_ENUM(NSInteger, ControlType) {
   CONTROL_PB = 0,
   CONTROL_LP = 1,
};



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







@interface ZLPlayerView : UIView <ZLPlayerDelegate>
@property (nonatomic, strong) FunctionView *funcBar;


@property (nonatomic, assign) NSInteger chekingFlag;
@property (nonatomic, assign) BOOL  hasDownload;
@property (nonatomic, assign) BOOL hasPreviewView;
@property (nonatomic, weak) id<ZLPlayerDelegate> delegate;

@property (strong, nonatomic) GLDrawController *glvc;
//@property (nonatomic, strong) void (^snapshot)();
//@property (nonatomic, strong) void (^recordVideo)(BOOL isRecord);
@property (nonatomic, strong) ZLPlayerModel *playerModel;

//@property (nonatomic, strong) Class controlClass;


@property (nonatomic, strong) CommonPlayerControl *functionControl;  //父类指针指向子类对象



int device_data_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context);
- (NSData *)snapshot;
- (instancetype)initWithModel: (ZLPlayerModel *)vp_model control:(CommonPlayerControl *)control controller:(UIViewController *)vc;
- (void)reconnect;
- (void)lv_stop;
- (void)lv_start;

- (void)pb_end;
- (void)pb_start;
- (void)pb_pause;

- (void)fireTimer;
- (void)invalidTimer;


- (void)createPanGesture;
@end
