//
//  ApiManager.m
//  iLnkView
//
//  Created by user on 17/4/12.
//  Copyright © 2017年 edwintech. All rights reserved.
//

#import "ApiManager.h"
#import "PPPPManager.h"
#import "AVIOCTRLDEFs.h"

@implementation ApiManager

#pragma mark 获取音频
+ (void)getCameraAudio:(NSString *)did {
    [[PPPPManager sharedPPPPManager] sendCmdExcute:did cmdType:CMD_AUDIO_PARAM_GET cmdParam:NULL];
}

#pragma mark 获取摄像头参数
+ (void)getCameraSetInfo:(NSString *)did{
    [[PPPPManager sharedPPPPManager] sendCmdExcute:did cmdType:CMD_CAMPARAM_GET cmdParam:NULL];
}

#pragma mark 设置摄像头参数
+ (int)setCameraParam:(NSString *)did param:(NSString *)param value:(NSString *)value {
    camCtrl_t_EX ptzReq;
    memset(&ptzReq, 0, sizeof(camCtrl_t_EX));
    
    ptzReq.paramType = param.intValue;
    ptzReq.paramValue = value.intValue;
    return [[PPPPManager sharedPPPPManager] sendCmdExcute:did cmdType:CMD_CAMPARAM_SET cmdParam:(char *)&ptzReq];
}
@end
