//
//  PCMPlayer.m
//  Kamu
//
//  Created by YGTech on 2018/2/13.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "PCMPlayer.h"

//static bool mIsStarted; // audio unit start
//static bool mSendServerStart; // send server continue loop
//static bool mRecServerStart; // rec server continue loop
//static bool mIsTele; // telephone call


static PCMPlayer *sharedAudioManager;


static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    PCMPlayer *audioProcessor = (__bridge PCMPlayer* )inRefCon;
    if (audioProcessor.input == NO){
        return noErr;
    }
    
    audioProcessor.buffList->mBuffers[0].mDataByteSize = inNumberFrames * 2;// sample size
    audioProcessor.buffList->mBuffers[0].mData = malloc( inNumberFrames * 2 );

    [audioProcessor hasError:AudioUnitRender(audioProcessor.audioUnit,
                                             ioActionFlags,
                                             inTimeStamp,
                                             1,
                                             inNumberFrames,
                                             audioProcessor.buffList) file:__FILE__ line:__LINE__];

   [audioProcessor calculateMeters:[NSData dataWithBytes: audioProcessor.buffList ->mBuffers[0].mData length:(unsigned int)audioProcessor.buffList->mBuffers[0].mDataByteSize]];
    
    cloud_device_speaker_data((void *)audioProcessor.nvr_h,audioProcessor.cam_h,(unsigned char*) audioProcessor.buffList->mBuffers[0].mData, (int)  audioProcessor.buffList->mBuffers[0].mDataByteSize);
  

    free(audioProcessor.buffList->mBuffers[0].mData);
  
    return noErr;

}

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,//0
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    
   PCMPlayer *audioProcessor = (__bridge PCMPlayer* )inRefCon;
    if (audioProcessor.output == NO){
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        return noErr;
    }
    
    
    UInt32 bufferSize = ioData->mBuffers[0].mDataByteSize;
    if ([audioProcessor.mIn length] >= bufferSize){
        memcpy(ioData->mBuffers[0].mData,audioProcessor.mIn.bytes,bufferSize);
        [audioProcessor.mIn  replaceBytesInRange: NSMakeRange(0, bufferSize) withBytes: NULL length: 0];
        return noErr;
    }else {
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        return noErr;
    }

}



@implementation PCMPlayer
+ (PCMPlayer *)sharedAudioManager{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedAudioManager) {
            sharedAudioManager = [[PCMPlayer alloc] init];
        }
    });
     return sharedAudioManager;
}
- (PCMPlayer *)init {
    if ([super init]) {
        [self configAU];
        self.mIn = [NSMutableData new];
    }
    return self;
}

///MARK: 初始化配置 将数字信号作你所想要的处理，完了再送到输出端去进行播放。回调函数是一个C语言的静态方法
- (void)configAU {
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    audioDesc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    [self hasError:AudioComponentInstanceNew(inputComponent, &_audioUnit) file:__FILE__ line:__LINE__];

    UInt32 enable = 1;
    [self hasError:AudioUnitSetProperty(_audioUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Input,
                                        1,
                                        &enable,
                                        sizeof(enable)) file:__FILE__ line:__LINE__];


    
    
    
 
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = 8000;
    audioFormat.mFormatID   = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerPacket = 2;  // (bits/1Channel * channels/1Frame * frames/1Packet) / 8
    audioFormat.mBytesPerFrame  = 2;
    [self hasError:AudioUnitSetProperty(_audioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        1,
                                        &audioFormat,
                                        sizeof(audioFormat)) file:__FILE__ line:__LINE__];

    [self hasError:AudioUnitSetProperty(_audioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &audioFormat,
                                        sizeof(audioFormat)) file:__FILE__ line:__LINE__];

    
    
    
    
    //buffer callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    [self hasError:AudioUnitSetProperty(_audioUnit,kAudioOutputUnitProperty_SetInputCallback,
                                        kAudioUnitScope_Global,
                                        1,
                                        &callbackStruct,
                                        sizeof(callbackStruct)) file:__FILE__ line:__LINE__];

    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    [self hasError:AudioUnitSetProperty(_audioUnit,
                                        kAudioUnitProperty_SetRenderCallback,
                                        kAudioUnitScope_Global,
                                        0,
                                        &callbackStruct,
                                        sizeof(callbackStruct)) file:__FILE__ line:__LINE__];
    
    /*
    enable = 0;
    status = AudioUnitSetProperty(audioUnit,kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &enable,
                                  sizeof(enable));

    // Initialize the Audio Unit and cross fingers =)

   */
    [self hasError:AudioUnitInitialize(_audioUnit) file:__FILE__ line:__LINE__];

    
}



- (void)startService:(long)nvr_h cam:(int)cam_h{
    NSLog( @"-- start --");
    self.nvr_h = nvr_h;
    self.cam_h = cam_h;
    [self setInput:0 output:1];
    [self.mIn replaceBytesInRange: NSMakeRange(0, [self.mIn length]) withBytes: NULL length: 0];
    ///MARK:  只能用 耳机模式 ，和 Play & record Session ,苹果真的好坑爹！！
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self hasError:AudioOutputUnitStart(_audioUnit) file:__FILE__ line:__LINE__];
}

- (void)stopService {
    NSLog( @"-- stop --");
    [self hasError:AudioOutputUnitStop(_audioUnit) file:__FILE__ line:__LINE__];
    [self.mIn replaceBytesInRange: NSMakeRange(0, [self.mIn length]) withBytes: NULL length: 0];
}

- (void)setInput:(BOOL)input output:(BOOL)output {
    self.input = input;
    self.output = output;
}

- (void)calculateMeters:(NSData *)pcmData {
    if (pcmData == nil) {
        return ;
    }
    long long allLen = 0;
    short frames[pcmData.length/2];
    memcpy(frames, pcmData.bytes, pcmData.length);//frame_size * sizeof(short)
    
    // 将 buffer 内容取出，进行平方和运算
    for (int i = 0; i < pcmData.length/2; i++) {
        allLen += frames[i] * frames[i];
    }
    // 平方和除以数据总长度，得到音量大小。
    double mean = allLen / (double)pcmData.length;
    double volume = 10 * log10(mean);//volume为分贝数大小
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.volumeHUD setProgress:volume / 120.f];
    });
}


#pragma mark - getter
- (LCVoiceHud *)volumeHUD {
    if (!_volumeHUD) {
        _volumeHUD = [[LCVoiceHud alloc] initWithFrame:CGRectZero];
    }
    return _volumeHUD;
}

- (AudioBufferList *)buffList {
    
    if (!_buffList) {
        _buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
        _buffList->mNumberBuffers = 1;
        _buffList->mBuffers[0].mNumberChannels = 1;
    }
    
    return _buffList;
}


#pragma mark Error handling
- (void)hasError:(int)statusCode file:(char*)file line:(int)line {
    if (statusCode) {
        NSLog(@"Error Code responded %d in file %s on line %d", statusCode, file, line);
        exit(-1);
    }
}

@end












