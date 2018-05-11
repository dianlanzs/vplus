//
//  PPPPManager.h
//  VDP
//
//  Created by Liuqs on 16/12/13.
//  Copyright © 2016年 Liuqs. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PPPPManagerSearchDelegate <NSObject>
//搜索设备时回调
- (void) searchCameraResult:(NSString *)mac Name:(NSString *)name  Port:(NSString *)port DID:(NSString*)did deviceType:(int)type;

@end

@protocol PPPPManagerStatusDelegate <NSObject>

//设备状态回调
- (void)ppppStatus:(NSString *)strDID statusType:(NSInteger)statusType status:(NSInteger)status;
@end

@protocol PPPPManagerVideoDataDelegate <NSObject>
- (void)yuvData:(NSString *)did yuv:(Byte *)yuv nType:(int)nType length:(int)length width:(int)width height:(int)height timestamp:(int)timestamp;



@end

@protocol PPPPManagerH264DataDelegate <NSObject>

- (void)VideoH264Data:(NSString*)did H264Data:(Byte *)data len:(int)len;

@end

@protocol PPPPManagerAlarmInDelegate <NSObject>
- (void)ppppAlarmNotify:(NSString *)did sid:(NSString *)sid sztype:(NSString *)sztype sztime:(NSString *)sztime;
@end


@protocol PPPPManagerCommandDelegate <NSObject>
- (void)ppppCallBackCommand:(NSString *)did nCmd:(int)nCmd cmdMsg:(NSString *)cmdMsg;
@end

@protocol PPPPManagerCMDRecVDelegate <NSObject>
- (void)ppppCallBackCMDRecV:(NSString *)did nCmd:(int)nCmd cmdMsg:(char *)cmdMsg length:(int)len;
@end


@interface PPPPManager : NSObject

+ (instancetype)sharedPPPPManager;

- (void)startP2P;

//重新启动p2p
- (void)restartP2P:(BOOL)isStart;

- (id)init;
- (void)DeInit;

- (BOOL)isP2pLibStartOK;

- (void)setP2pLibStartOK;

//new 搜索设备
- (NSArray*)NodeSearchCameraResult;

//isStart 开启／关闭搜索设备
- (void)searchDevice:(BOOL)isStart ssid:(NSString *)ssid pwd:(NSString *)pwd;

//开始设备连接
- (int)startPPPP:(NSString *)did user:(NSString *)user pwd:(NSString *)pwd;

//关闭设备连接
- (int)closePPPP:(NSString *)did;

//开启视频流
- (int)startPPPPLivestream:(NSString *)did url:(NSString *)url audio_send_codec:(int)audio_send_codec  audio_recv_codec:(int)audio_recv_codec video_recv_codec:(int)video_recv_codec;

- (int)startPPPPLivestreamBell:(NSString *)did uesr:(NSString*)user pwd:(NSString*)pwd server:(NSString*)server;

//关闭视频流
- (int)closePPPPLivestream:(NSString *)did;

//开启视频录制，filePath：本地视频路径
- (int)startRecorder:(NSString *)did filePath:(NSString *)filePath;

//关闭视频录制
- (int)closeRecorder:(NSString *)did;

//发指令
- (int)sendSCtrlCommand:(NSString *)did cmd:(int)cmd msg:(NSString *)msg;

//发指令--新的
- (int)sendCmdExcute:(NSString *)did cmdType:(int)cmdType cmdParam:(char *)cmdParam;

- (int)setAudioStatus:(NSString *)did value:(int)value;

- (int)AudioStatus:(NSString *)did;


//Delegate
@property (nonatomic, weak) id<PPPPManagerSearchDelegate> searchDelegate;
@property (nonatomic, weak) id<PPPPManagerStatusDelegate> statusDelegate;
@property (nonatomic, weak) id<PPPPManagerVideoDataDelegate> videoDataDelegate;
@property (nonatomic, weak) id<PPPPManagerH264DataDelegate> h264DataDelegate;
@property (nonatomic, weak) id<PPPPManagerAlarmInDelegate> alarmInDelegate;
@property (nonatomic, weak) id<PPPPManagerCommandDelegate> commandInDelegate;
@property (nonatomic, weak) id<PPPPManagerCMDRecVDelegate> cmdRecvInDelegate;


@property (nonatomic) BOOL p2pLibStartOK;

@property (nonatomic,strong)NSString * textStr;

@end
