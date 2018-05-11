//
//  RecordingTool.m
//  Kamu
//
//  Created by YGTech on 2018/5/3.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "RecordingTool.h"
static void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}





OSStatus InputCallback(void *inRefCon,
                       AudioUnitRenderActionFlags *ioActionFlags,
                       const AudioTimeStamp *inTimeStamp,
                       UInt32 inBusNumber,
                       UInt32 inNumberFrames,
                       AudioBufferList *ioData){
    
    
    AudioTool *audioProcessor = (__bridge AudioTool* )inRefCon;
    NSLog(@"input");
    audioProcessor.buffList->mBuffers[0].mDataByteSize = inNumberFrames * 2;// sample size
    audioProcessor.buffList->mBuffers[0].mData = malloc( inNumberFrames * 2 );
    
    CheckError(AudioUnitRender(audioProcessor.struc->remoteIOUnit,
                               ioActionFlags,
                               inTimeStamp,
                               1,
                               inNumberFrames,
                               audioProcessor.buffList),
               "AudioUnitRender failed");
    AudioBuffer buffer = audioProcessor.buffList->mBuffers[0];
    
    cloud_device_speaker_data(audioProcessor.nvr_h,audioProcessor.cam_h,(unsigned char*) buffer.mData, (int)  buffer.mDataByteSize);
    [audioProcessor calculateMeters:[NSData dataWithBytes: audioProcessor.buffList ->mBuffers[0].mData length:(unsigned int)audioProcessor.buffList->mBuffers[0].mDataByteSize]];
    
    
    //    NSLog(@"-- send data:%p, bytes:%d ---",(unsigned char*)  bufferList.mBuffers[0].mData,(unsigned int) bufferList.mBuffers[0].mDataByteSize);
    //    cloud_device_speaker_data(audioProcessor.nvr_h, audioProcessor.cam_h,(unsigned char*) bufferList.mBuffers[0].mData, (int) bufferList.mBuffers[0].mDataByteSize);
    
    
    
    return noErr;
}

static AudioTool *instace = nil;







@implementation RecordingTool


@synthesize streamFormat;

+ (instancetype)sharedTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instace) {
            instace = [[AudioTool allocWithZone:NULL] init];
        }
    });
    
    return instace;
    
}

- (instancetype)init {
    //Initialize currentBufferPointer
    
    if (self = [super init]) {
        //        [self setupSession];
        self.struc = (MyAUGraphStruct *)malloc(sizeof(MyAUGraphStruct));
        self.mIn = [[NSMutableData alloc] init];
        
        [self createAUGraph:self.struc];
        [self setupRemoteIOUnit:self.struc];
        
    }
    return self;
}


- (AudioBufferList *)buffList {
    if (!_buffList) {
        _buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
        _buffList -> mNumberBuffers = 1;
        _buffList->mBuffers[0].mNumberChannels = 1;
    }
    
    return _buffList;
}



//- (void)disableOutput:(UInt32)flag {
//
//    CheckError(AudioUnitSetProperty(self.struc->remoteIOUnit,
//                                    kAudioOutputUnitProperty_EnableIO,
//                                    kAudioUnitScope_Output,
//                                    0,
//                                    &flag,
//                                    sizeof(flag)),
//               "Open input of bus 1 failed");
//}

//- (void)enableInput:(UInt32)flag{
//
//
//    UInt32 size = sizeof(flag);
//    CheckError(AudioUnitGetProperty(self.struc->remoteIOUnit,
//                                    kAudioOutputUnitProperty_EnableIO,
//                                    kAudioUnitScope_Input,
//                                    1,
//                                    &flag,
//                                    &size),
//               "kAUVoiceIOProperty_BypassVoiceProcessing failed");
//
//
//
//
//
//
//
//    CheckError(AudioUnitSetProperty(self.struc->remoteIOUnit,
//                                    kAudioOutputUnitProperty_EnableIO,
//                                    kAudioUnitScope_Input,
//                                    1,
//                                    &flag,
//                                    sizeof(flag)),
//               "Open input of bus 1 failed");
//
//    CheckError(AudioUnitSetProperty(self.struc->remoteIOUnit,
//                                    kAUVoiceIOProperty_BypassVoiceProcessing,
//                                    kAudioUnitScope_Global,
//                                    1,
//                                    &flag,
//                                    sizeof(flag)),
//               "AudioUnitSetProperty kAUVoiceIOProperty_BypassVoiceProcessing failed");
//
//
//}
//


- (void)stopGraph:(AUGraph)graph{
    
    CheckError(AUGraphStop(graph),
               "AUGraphStop failed");
}

-(void)startGraph:(AUGraph)graph{
    
    CheckError(AUGraphInitialize(graph),
               "AUGraphInitialize failed");
    
    CheckError(AUGraphStart(graph),
               "AUGraphStart failed");
}

-(void)setupRemoteIOUnit:(MyAUGraphStruct *)myStruct{
    
    UInt32 recording = 0;
    UInt32 playback = 1;
    
    
    CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                    kAudioOutputUnitProperty_EnableIO,
                                    kAudioUnitScope_Input,
                                    1,
                                    &recording,
                                    sizeof(recording)),
               "Open input of bus 1 failed");
    
    CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                    kAudioOutputUnitProperty_EnableIO,
                                    kAudioUnitScope_Output,
                                    0,
                                    &playback,
                                    sizeof(playback)),
               "Open output of bus 0 failed");
    
    
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    streamFormat.mSampleRate = 8000;  //44100 ------zholei  设置这个会 影响 到 分配 的buffer 输入输出 的大小
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = 2;
    streamFormat.mBytesPerPacket = 2;
    streamFormat.mBitsPerChannel = 16;
    streamFormat.mChannelsPerFrame = 1;
    
    CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    0,
                                    &streamFormat,
                                    sizeof(streamFormat)),
               "kAudioUnitProperty_StreamFormat of bus 0 failed");
    
    CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    1,
                                    &streamFormat,
                                    sizeof(streamFormat)),
               "kAudioUnitProperty_StreamFormat of bus 1 failed");
    
    //Set up input callback
    AURenderCallbackStruct input;
    input.inputProc = InputCallback;
    input.inputProcRefCon = (__bridge void * _Nullable)(self);
    CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                    kAudioOutputUnitProperty_SetInputCallback,
                                    kAudioUnitScope_Global,
                                    1,//input mic
                                    &input,
                                    sizeof(input)),
               "kAudioUnitProperty_SetRenderCallback failed");
    
    
    
    
    AURenderCallbackStruct output;
    output.inputProc = outputRenderTone_xb;
    output.inputProcRefCon = (__bridge void *)(self);
    CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Global,
                                    0,  //speaker
                                    &output,
                                    sizeof(output)),
               "kAudioUnitProperty_SetRenderCallback failed");
}

-(void)createAUGraph:(MyAUGraphStruct*)myStruct{
    
    
    //Create graph
    CheckError(NewAUGraph(&myStruct->graph),
               "NewAUGraph failed");
    
    //Create nodes and add to the graph
    //Set up a RemoteIO for synchronously playback
    AudioComponentDescription inputcd = {0};
    inputcd.componentType = kAudioUnitType_Output;
    inputcd.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    inputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AUNode remoteIONode;
    //Add node to the graph
    CheckError(AUGraphAddNode(myStruct->graph,
                              &inputcd,
                              &remoteIONode),
               "AUGraphAddNode failed");
    
    //Open the graph
    CheckError(AUGraphOpen(myStruct->graph),
               "AUGraphOpen failed");
    
    //Get reference to the node
    CheckError(AUGraphNodeInfo(myStruct->graph,
                               remoteIONode,
                               &inputcd,
                               &myStruct->remoteIOUnit),
               "AUGraphNodeInfo failed");
}



#pragma mark - getter
- (LCVoiceHud *)volumeHUD {
    if (!_volumeHUD) {
        _volumeHUD = [[LCVoiceHud alloc] initWithFrame:CGRectZero];
    }
    return _volumeHUD;
}

- (void)calculateMeters:(NSData *)pcmData {
    
    if (pcmData == nil) {
        return ;
    }
    
    long long allLen = 0;
    
    short frames[pcmData.length/2];
    memcpy(frames, pcmData.bytes, pcmData.length);//frame_size * sizeof(short)
    
    // 将 buffer 内容取出，进行平方和运算
    for (int i = 0; i < pcmData.length/2; i++)
    {
        allLen += frames[i] * frames[i];
    }
    // 平方和除以数据总长度，得到音量大小。
    double mean = allLen / (double)pcmData.length;
    double volume = 10 * log10(mean);//volume为分贝数大小
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.volumeHUD setProgress:volume / 120.f];
    });
    
    
}



@end
