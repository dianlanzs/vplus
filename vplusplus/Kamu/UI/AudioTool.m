//
//  AudioTool.m
//  Kamu
//
//  Created by YGTech on 2018/5/2.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//






#import "AudioTool.h"
#import "DeviceManager.h"



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
    if (audioProcessor.input == NO){
        return noErr;
    }
    
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

OSStatus outputRenderTone_xb(
                             void *inRefCon,
                             AudioUnitRenderActionFlags     *ioActionFlags,
                             const AudioTimeStamp         *inTimeStamp,
                             UInt32                         inBusNumber,
                             UInt32                         inNumberFrames,
                             AudioBufferList             *ioData) {
  
    
    AudioTool *audioProcessor = (__bridge AudioTool* )inRefCon;
    if (audioProcessor.output == NO){
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        return noErr;
    }
    
//
//    long len = [audioProcessor.mIn length];
//    len = len > 1024 ? 1024 : len;
//    if (len <= 0){
//        return noErr ;
//    }
//
//    for (int i = 0; i < ioData -> mNumberBuffers; i++){
//        NSData *pcmBlock = [audioProcessor.mIn subdataWithRange: NSMakeRange(0, len)];
//        UInt32 size = (UInt32)MIN(ioData -> mBuffers[i].mDataByteSize, [pcmBlock length]); //340
//
//        memcpy(ioData -> mBuffers[i].mData, [pcmBlock bytes], size);
//        [audioProcessor.mIn replaceBytesInRange: NSMakeRange(0, size) withBytes: NULL length: 0];  //清除播放数据
//        NSLog(@"消耗，%u -- remain %lu",(unsigned int)size,audioProcessor.mIn.length);
//        ioData -> mBuffers[i].mDataByteSize = size;
//    }
    
    
    UInt32 bufferSize = ioData->mBuffers[0].mDataByteSize;
    
        NSLog(@"inBusNumber:%d -- samples:%d -- mBuffers:%d ---channel:%d",inBusNumber,inNumberFrames,ioData->mNumberBuffers,ioData->mBuffers[0].mNumberChannels);
    if ([audioProcessor.mIn length] >= bufferSize){//1920
        memcpy(ioData->mBuffers[0].mData,audioProcessor.mIn.bytes,bufferSize);
        [audioProcessor.mIn  replaceBytesInRange: NSMakeRange(0, bufferSize) withBytes: NULL length: 0];
                NSLog(@"remain %lu",audioProcessor.mIn.length);
        return noErr;
    }else {
                NSLog(@"will run out of audio data ");
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        return noErr;
    }
    
    return noErr;
}





@implementation AudioTool


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
    
    if (self = [super init]) {
 
    }
    return self;
}


///MARK: 开启服务
//- (void)startService:(NSString *)sessionID device:(void *)nvr_h cam:(int)cam_h {
- (void)startService:(void *)nvr_h cam:(int)cam_h{


    self.nvr_h = nvr_h;
    self.cam_h = cam_h;
    self.struc = (MyAUGraphStruct *)malloc(sizeof(MyAUGraphStruct));
    self.mIn = [[NSMutableData alloc] init];
    
    [self setInput:NO output:YES];//default

    [self setupSession];
    [self createAUGraph:self.struc];
    [self setupRemoteIOUnit:self.struc];
    if (self.input == YES || self.output == YES) {
        [self startGraph:self.struc->graph];
    }
//    [self createAUGraph:self.struc];
//    [self setupRemoteIOUnit:self.struc];
//    [self startGraph:self.struc->graph];
//    AudioOutputUnitStart(self.struc->remoteIOUnit);

}

- (void)setInput:(BOOL)input output:(BOOL)output {
    self.input = input;
    self.output = output;
}

- (AudioBufferList *)buffList {
    
    if (!_buffList) {
        _buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
        _buffList->mNumberBuffers = 1;
        _buffList->mBuffers[0].mNumberChannels = 1;
    }
    
    return _buffList;
}



- (void)stopGraph:(AUGraph)graph {
    
    
    Boolean isRunning = false;
    CheckError(AUGraphIsRunning(graph, &isRunning),
               "AUGraphInitialize failed");
    
    if (isRunning) {
        NSLog(@"graph is running");
        CheckError(AUGraphStop(graph), "Failed to stop Audio Graph");
    }else {
        NSLog(@"graph not  running");
    }
}

- (void)startGraph:(AUGraph)graph{

    
    [self stopGraph:graph];
    CheckError(AUGraphInitialize(graph),
               "AUGraphInitialize failed");
    CheckError(AUGraphStart(graph),
               "AUGraphStart failed");
}

- (void)setupRemoteIOUnit:(MyAUGraphStruct *)myStruct {



    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    streamFormat.mSampleRate = 8000;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = 2;
    streamFormat.mBytesPerPacket = 2;
    streamFormat.mBitsPerChannel = 16;
    streamFormat.mChannelsPerFrame = 1;

//    if (self.input == YES && self.output == NO) {
    
        UInt32 recording = 1;
        
        
        // 1. enable input
        CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Input,
                                        1,
                                        &recording,
                                        sizeof(recording)),
                   "Open 录制 of bus 1 failed");
        
        
        //2. stream format
        CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Output,
                                        1,
                                        &streamFormat,
                                        sizeof(streamFormat)),
                   "kAudioUnitProperty_StreamFormat of bus 1 failed");
        
        //3. input callback
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
        
//    }
    
    
    
    
    
    
    
    
    
    
//    else if (self.input == NO && self.output == YES) {
    
        UInt32 playback = 1;

        
        //enable output
        CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Output,
                                        0,
                                        &playback,
                                        sizeof(playback)),
                   "Open 播放 of bus 0 failed");
        //format
        CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &streamFormat,
                                        sizeof(streamFormat)),
                   "kAudioUnitProperty_StreamFormat of bus 0 failed");
        
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
        
        
//    }
    
    
    /*
    else if (self.input == NO && self.output == NO) {
        
        UInt32 playback = 0;
        UInt32 recording = 0;

        //enable output
        CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Output,
                                        0,
                                        &playback,
                                        sizeof(playback)),
                   "Open 播放 of bus 0 failed");
        
        // 1. enable input
        CheckError(AudioUnitSetProperty(myStruct->remoteIOUnit,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Input,
                                        1,
                                        &recording,
                                        sizeof(recording)),
                   "Open 录制 of bus 1 failed");
        
 
    }
    */

    
    

    

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

- (void)setupSession {
    
    NSError *err = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord          error:&err];
    
    /*

    if (self.output == YES && self.input == NO) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient           error:&err];
    }
    else if (self.input == YES && self.output == NO) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord          error:&err];
        //        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker  error:&err];
    }
    else if (self.input == NO && self.output == NO) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAudioProcessing   error:&err];
    }
    
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
     
     */
    
    
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }

}

@end
