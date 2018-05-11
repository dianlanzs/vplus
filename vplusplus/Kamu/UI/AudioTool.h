//
//  AudioTool.h
//  Kamu
//
//  Created by YGTech on 2018/5/2.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


#import <AudioToolbox/AudioToolbox.h>
#import "LCVoiceHud.h"



typedef struct MyAUGraphStruct{
    AUGraph graph;
    AudioUnit remoteIOUnit;
} MyAUGraphStruct;

typedef void (^XBEchoCancellation_outputBlock)(AudioBufferList *bufferList,UInt32 inNumberFrames);
typedef void (^XBEchoCancellation2_outputBlock)(
                                                void *inRefCon,
                                                AudioUnitRenderActionFlags     *ioActionFlags,
                                                const AudioTimeStamp         *inTimeStamp,
                                                UInt32                         inBusNumber,
                                                UInt32                         inNumberFrames,
                                                AudioBufferList             *ioData);


@interface AudioTool : NSObject





@property (nonatomic, copy) void(^bufferCallback)(AudioBuffer buffer);

@property(nonatomic,assign)AudioStreamBasicDescription streamFormat;
@property (nonatomic, assign) AudioBufferList *buffList;

@property (nonatomic,assign) void *  nvr_h;
@property (nonatomic, assign) MyAUGraphStruct *struc;
@property  int cam_h;




@property (nonatomic, strong) NSMutableData *mIn;


@property (nonatomic, strong) LCVoiceHud *volumeHUD;

@property (nonatomic, assign) UInt32 flag;









///播放的回调，回调的参数 buffer 为要向播放设备（扬声器、耳机、听筒等）传的数据，在回调里把数据传给 buffer
@property (nonatomic,copy) XBEchoCancellation_outputBlock bl_output;
@property (nonatomic,copy) XBEchoCancellation2_outputBlock bl2_output;


@property (nonatomic, assign) BOOL input;
@property (nonatomic, assign) BOOL output;









+ (instancetype)sharedTool;


-(void)startGraph:(AUGraph)graph;
-(void)stopGraph:(AUGraph)graph;

- (void)calculateMeters:(NSData *)pcmData;
- (void)startService:(void *)nvr_h cam:(int)cam_h;
//- (void)enableInput:(UInt32)flag;
//- (void)disableOutput:(UInt32)flag;


- (void)setInput:(BOOL)input output:(BOOL)output;

@end
