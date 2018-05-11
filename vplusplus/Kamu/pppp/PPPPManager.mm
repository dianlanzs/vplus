//
//  PPPPManager.m
//  VDP
//
//  Created by Liuqs on 16/12/13.
//  Copyright © 2016年 Liuqs. All rights reserved.
//

#import "PPPPManager.h"
#import "object_jni.h"
#import "NSString+StringUtil.h"
#import "AVIOCTRLDEFs.h"

@implementation PPPPManager

static PPPPManager *ppppManager = nil;
+ (instancetype)sharedPPPPManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ppppManager = [[self alloc] init];
    });
    return ppppManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.p2pLibStartOK = false;
    }
    return self;
}


//开始P2P
- (void)startP2P {
    self.p2pLibStartOK = false;
   
      int ret=Init(&iOSEnv, NULL,"EKPNHXIDAUAOEHLOTBSQEJSWPAARTAPKLXPGENLKLUPLHUATSVEESTPFHWIHPDIEHYAOLVEISQLNEGLPPALQHXERELIALKEHEOHZHUEKIFEEEPEJ-$$",0,3,16,128);

    if (ret>=0){
        self.p2pLibStartOK = true;
        PPPPSetCallbackContext(&iOSEnv, (__bridge void*)self, (__bridge void*)self);
    }
}

// 重启 P2P
- (void)restartP2P:(BOOL)isStart {
    if (!self.p2pLibStartOK || isStart) {
        [self startP2P];
    }
}

-(void)DeInit{

     DeInit(&iOSEnv, NULL);
}

- (BOOL)isP2pLibStartOK {
    return self.p2pLibStartOK;
}

- (void)setP2pLibStartOK {
    self.p2pLibStartOK = false;
}

- (NSArray *)NodeSearchCameraResult{

    NSMutableArray * MuArray = [NSMutableArray array];
    int ret=0,nmb=16;
    st_lanSearchExtRet results[16];
    memset(results,0,16*sizeof(st_lanSearchExtRet));
    
    ret = NodeSearch(&iOSEnv, NULL,nmb,3,(char *)&results[0]);
    
    if (ret > 0){
        
        for(int i=0;i<ret;i++){
            
            NSString * name = [NSString stringWithUTF8String:results[i].mName];
            
            if(name.length<1){
            
                name = [NSString stringWithUTF8String:results[i].mDID];
            }
        
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[[[NSString stringWithUTF8String:results[i].mDID] stringByReplacingOccurrencesOfString:@"-" withString:@""] uppercaseString],@"DID",name,@"NAME",[NSString stringWithUTF8String:results[i].mIP],@"IP",
                                  [NSString stringWithUTF8String:results[i].mDID],@"ID",nil];
            
            
            [MuArray addObject:dic];
        }
        
    }
    
    return MuArray;
}

- (void)searchDevice:(BOOL)isStart ssid:(NSString *)ssid pwd:(NSString *)pwd {
    if (isStart) {
       
        int ret=0,nmb=16;
        st_lanSearchExtRet results[16];
        memset(results,0,16*sizeof(st_lanSearchExtRet));
        
        ret = NodeSearch(&iOSEnv, NULL,nmb,3,(char *)&results[0]);

        
        if(ret>0){
            int i=0;
            for(;i<ret;i++){
                st_lanSearchExtRet * st = (st_lanSearchExtRet*)ret;
           
            }
            
        }
        
    }
}




- (int)startPPPP:(NSString *)did user:(NSString *)user pwd:(NSString *)pwd {
    char didchar[128] = {0};
    char userchar[128]= {0};
    strcpy(didchar, did.UTF8String);
    strcpy(userchar, pwd.UTF8String);
    
    NSLog(@"startPPPP->did:%@",did);
    return StartPPPP(&iOSEnv, NULL, [did charFromString], [user charFromString], [pwd charFromString], [@"" charFromString]);
}

- (int)closePPPP:(NSString *)did {
    return ClosePPPP(&iOSEnv, NULL, [did charFromString]);
}

- (int)startPPPPLivestream:(NSString *)did url:(NSString *)url audio_send_codec:(int)audio_send_codec  audio_recv_codec:(int)audio_recv_codec  video_recv_codec:(int)video_recv_codec {
    return  StartPPPPLivestream(&iOSEnv, NULL, [did charFromString], [url charFromString], audio_recv_codec, audio_send_codec, video_recv_codec);
}

- (int)startPPPPLivestreamBell:(NSString *)did uesr:(NSString*)user pwd:(NSString*)pwd server:(NSString*)server {
    return  RspBell(&iOSEnv, NULL, [did charFromString], [@"ada" charFromString], [user charFromString], [pwd charFromString], [@"EKPNHXIDAUAOEHLOTBSQEJSWPAARTAPKLXPGENLKLUPLHUATSVEESTPFHWIHPDIEHYAOLVEISQLNEGLPPALQHXERELIALKEHEOHZHUEKIFEEEPEJ-$$" charFromString]);
}


- (int)closePPPPLivestream:(NSString *)did {
    return ClosePPPPLivestream(&iOSEnv, NULL, [did charFromString]);
}

- (int)startRecorder:(NSString *)did filePath:(NSString *)filePath {
    return StartRecorder(&iOSEnv, NULL, [did charFromString], [filePath charFromString]);
}

- (int)closeRecorder:(NSString *)did {
    return CloseRecorder(&iOSEnv, NULL, [did charFromString]);
}

- (int)sendSCtrlCommand:(NSString *)did cmd:(int)cmd msg:(NSString *)msg {
    strlen(msg.UTF8String);
    return 0;
//    SendCtrlCommand(&iOSEnv, NULL, [did charFromString],cmd, [msg charFromString], (int)msg.length);
}

- (int)sendCmdExcute:(NSString *)did cmdType:(int)cmdType cmdParam:(char *)cmdParam {
    self.textStr = [NSString stringWithFormat:@"did----%@;   cmdType----%d\n",did,cmdType];
    return SendCtrlCommand_EX(&iOSEnv, NULL, [did charFromString], 0xff, cmdType, cmdParam);
}


- (int)setAudioStatus:(NSString *)did value:(int)value {
   return SetAudioStatus(&iOSEnv, NULL, [did charFromString], value);
}

- (int)AudioStatus:(NSString *)did {
    return GetAudioStatus(&iOSEnv, NULL, [did charFromString]);
}

#pragma mark ---------------- self callback
- (void) ppppSearchResults:(const char *)szMac szName:(const char *)szName szDID:(const char * )szDID szIP:(const char *) szIP nPort:(int)nPort nType:(int) nType {
//    NSLog(@"------------------ppppSearchResults-----------------");
    if (szDID==nil) {
        NSLog(@"********szDID 为nil");
        return;
    }
    
    if(szName == NULL){
        szName = szDID;
    }
    
    if (_searchDelegate && [_searchDelegate respondsToSelector:@selector(searchCameraResult:Name:Port:DID:deviceType:)])
    {
        
        [_searchDelegate searchCameraResult:@"" Name:[NSString stringWithUTF8String:szName] Port:[NSString stringWithFormat:@"%d",nPort] DID:[NSString stringWithUTF8String:szDID] deviceType:nType];
    }
}

- (void) ppppUILayerNotify:(const char *) szDID  nCmd:(int)nCmd szJson:(const char *) szJson {
//    NSLog(@"---------------------ppppUILayerNotify------------------");
    if (szDID == nil) {
        NSLog(@"********szDID 为nil");
        return;
    }
    if (szJson==nil) {
        szJson = [@"" UTF8String];
    }
    if (_commandInDelegate && [_commandInDelegate respondsToSelector:@selector(ppppCallBackCommand:nCmd:cmdMsg:)]) {
        [_commandInDelegate ppppCallBackCommand:[NSString stringWithUTF8String:szDID] nCmd:nCmd cmdMsg:[NSString stringWithUTF8String:szJson]];
    }
}

- (void)ppppVideoDataProcess:(const char *)szDID lpImage:(char *) lpImage nType:(int)nTypenLens nLens:(int)nLens nW:(int)nW nH:(int)nH nTimestamp:(int)nTimestamp {
//    NSLog(@"-----------------ppppVideoDataProcess------------------");
    if (szDID == nil) {
        NSLog(@"********szDID 为nil");
        return;
    }
    if (_videoDataDelegate && [_videoDataDelegate respondsToSelector:@selector(yuvData:yuv:nType:length:width:height:timestamp:)]) {
        [_videoDataDelegate yuvData:[NSString stringWithUTF8String:szDID] yuv:(Byte *)lpImage nType:nTypenLens length:nLens width:nW height:nH timestamp:nTimestamp];
    }
}

- (void)ppppVideoH264Data:(NSString *)szDID H264data:(Byte *)data len:(int)len{

    if(szDID == nil){
        return;
    };
    if (_h264DataDelegate && [_h264DataDelegate respondsToSelector:@selector(VideoH264Data:H264Data:len:)]){
        [_h264DataDelegate VideoH264Data:szDID H264Data:data len:len];
    }
}


- (void)ppppConnectionNotify:(NSString*)szDID nType:(int)nType nParam:(int)nParam {
//    NSLog(@"------------------ppppConnectionNotify-------------------");
    if (szDID==nil) {
        NSLog(@"********szDID 为nil");
        return;
    }
        if (_statusDelegate && [_statusDelegate respondsToSelector:@selector(ppppStatus:statusType:status:)]) {
            [_statusDelegate ppppStatus:szDID statusType:nType status:nParam];
        }
    
    
}

- (void)ppppAlarmNotifyByDeviceDid:(const char *)szDID szSID:(const char *)szSID szType:(const char *)szType szTime:(const char *) szTime {
//    NSLog(@"----------------ppppAlarmNotifyByDeviceDid--------------");
    if (szDID==nil) {
        NSLog(@"********szDID 为nil");
        return;
    }
    if (_alarmInDelegate && [_alarmInDelegate respondsToSelector:@selector(ppppAlarmNotify:sid:sztype:sztime:)]) {
        [_alarmInDelegate ppppAlarmNotify:[NSString stringWithUTF8String:szDID] sid:[NSString stringWithUTF8String:szSID!=nil ? szSID : ""] sztype:[NSString stringWithUTF8String:szType !=nil ? szType : ""] sztime:[NSString stringWithUTF8String:szTime!=nil ? szTime : ""]];
    }
}


- (void)ppppCmdRecv:(const char *) szDID sessionID:(int)sessionID nCmd:(int)nCmd cmdContent:(char *)cmdContent len:(int)len {
//    NSLog(@"---------------ppppCmdRecv（指令回调）--------------------");
    if (szDID == nil) {
        NSLog(@"********szDID 为nil");
        return;
    }
    
    if (_cmdRecvInDelegate && [_cmdRecvInDelegate respondsToSelector:@selector(ppppCallBackCMDRecV:nCmd:cmdMsg:length:)]) {
        [_cmdRecvInDelegate ppppCallBackCMDRecV:[NSString stringWithUTF8String:szDID] nCmd:nCmd cmdMsg:cmdContent length:len];
    }
}


#pragma mark ---------------- callback method
//搜索设备回调
void CBSearchResults(int nTrue,const char * szMac,const char * szName,const char * szDID,const char * szIP,int nPort,int nType) {
//    NSLog(@"-----------------CBSearchResults（搜索回调）--------------");
//    NSLog(@"nType:%d nPort:%d",nType ,nPort);
    [[PPPPManager sharedPPPPManager] ppppSearchResults:szMac szName:szName szDID:szDID szIP:szIP nPort:nPort nType:nType];
}

//获取设置回调 get/set
void CBUILayerNotify(const char * szDID,int nCmd,const char * szJson) {
//    NSLog(@"-----------------CBUILayerNotify-----------------");
    if (szDID == NULL) {
//        NSLog(@"********szDID 为nil");
        return;
    }
    [[PPPPManager sharedPPPPManager] ppppUILayerNotify:szDID nCmd:nCmd szJson:szJson];
}

//视频流回调
void CBVideoDataProcess(const char * szDID,char * lpImage,int nType,int nLens,int nW,int nH,int nTimestamp){
//    NSLog(@"---------------CBVideoDataProcess-------------------");
    if (szDID == NULL) {
//        NSLog(@"********szDID 为nil");
        return;
    }
    
    [[PPPPManager sharedPPPPManager] ppppVideoDataProcess:szDID lpImage:lpImage nType:nType nLens:nLens nW:nW nH:nH nTimestamp:nTimestamp];
}
//h264 验证
void FhFishChk(const char * szDID,char * buf,int len){

    if(szDID == nil){
        return;
    }

    Byte * data = (Byte *)malloc(len);
    memcpy(data, buf, len);
    
    [[PPPPManager sharedPPPPManager] ppppVideoH264Data:[NSString stringWithUTF8String:szDID] H264data:data len:len];

    
}

//连接状态回调
void CBConnectionNotify(const char * szDID,int nType,int nParam){
    
//        NSLog(@"--------CBConnectionNotify-----nType:%d  nParam:%d",nType,nParam);
        if (szDID == NULL) {
//            NSLog(@"********szDID 为nil");
            return;
        }
   
    NSString * str = [NSString stringWithUTF8String:szDID];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //NOTE: 底层会调用这个方法 把 ‘nType’ 和 ‘nPram’ 传过来！
        [[PPPPManager sharedPPPPManager] ppppConnectionNotify:str nType:nType nParam:nParam];
    });
    
    
}


//报警回调
void CBAlarmNotifyByDevice(const char * szDID,const char * szSID,const char * szType,const char * szTime){
    NSLog(@"-----------------CBAlarmNotifyByDevice------------------");
    if (szDID == NULL) {
//        NSLog(@"********szDID 为nil");
        return;
    }
    
    [[PPPPManager sharedPPPPManager] ppppAlarmNotifyByDeviceDid:szDID szSID:szSID szType:szType szTime:szTime];
}

// 连接成功后回调
void CBCmdRecv(const char * szDID,int sessionID,int nCmd,char * buf,int len) {
//    NSLog(@"--------------------CBCmdRecv-----------------------");
    if(buf != NULL){
//        NSLog(@"Check buff len %d",len);
    }

    if (szDID == NULL) {
//        NSLog(@"********szDID 为nil");
        return;
    }
    [[PPPPManager sharedPPPPManager] ppppCmdRecv:szDID sessionID:sessionID nCmd:nCmd cmdContent:buf len:len];
}



@end
