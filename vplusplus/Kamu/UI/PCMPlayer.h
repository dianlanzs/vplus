//
//  PCMPlayer.h
//  Kamu
//
//  Created by YGTech on 2018/2/13.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>




#import "LCVoiceHud.h"


@interface PCMPlayer : NSObject


@property (readonly) AudioComponentInstance audioUnit;



//输入
@property (nonatomic, assign) BOOL input;
@property (nonatomic, strong) LCVoiceHud *volumeHUD;
@property (nonatomic, assign) AudioBufferList *buffList;
@property (nonatomic,assign) long nvr_h;
@property  int cam_h;

//输出
@property (nonatomic, assign) BOOL output;
@property (strong, readwrite) NSMutableData *mIn;


+ (PCMPlayer *)sharedAudioManager;

- (void)setInput:(BOOL)input output:(BOOL)output;
- (void)startService:(long)nvr_h cam:(int)cam_h;
- (void)stopService;



- (void)calculateMeters:(NSData *)pcmData;
- (void)hasError:(int)statusCode file:(char*)file line:(int)line;

@end
