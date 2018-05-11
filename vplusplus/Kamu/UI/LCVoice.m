//
//  LCVoice.m
//  LCVoiceHud
//
//  Created by 郭历成 on 13-6-21.
//  Contact titm@tom.com
//  Copyright (c) 2013年 Wuxiantai Developer Team.(http://www.wuxiantai.com) All rights reserved.
//

#import "LCVoice.h"
#import "LCVoiceHud.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark - <DEFINES>
#define WAVE_UPDATE_FREQUENCY   0.05
#pragma mark - <CLASS> LCVoice

@interface LCVoice () <AVAudioRecorderDelegate>
{
    NSTimer * timer_;
    LCVoiceHud * voiceHud_;    
}

@property(nonatomic,retain) AVAudioRecorder * recorder;

@end

@implementation LCVoice

- (void)dealloc{
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    
    self.recorder = nil;
    self.recordPath = nil;
}

#pragma mark - Publick Function

- (void)startRecordWithPath:(NSString *)path {
    
    
    //change  record session & set active
    NSError * err = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }

    
    //set audio format
    NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey]; //audio format
    [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey]; //sampleRate : is the average number of samples obtained in one second (samples per second)
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey]; //channel
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey]; //16
    [recordSetting setValue:[NSNumber numberWithInt: AVAudioQualityMax]forKey:AVSampleRateConverterAudioQualityKey];
//    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    
    
    
    
    
    
    //if alredy exits  remove it
    self.recordPath = path;
    NSURL * url = [NSURL fileURLWithPath:self.recordPath];
    err = nil;
    NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];

    if(audioData) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&err];
    }

    err = nil;
    if(self.recorder){
        [self.recorder stop];
        self.recorder = nil;

    }
    
    
    
    
    
    
    
    //create recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!_recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }

    
    
    [_recorder setDelegate:self];         //设置代理
    [_recorder prepareToRecord];         // 准备录音
    _recorder.meteringEnabled = YES;    // 开启表盘,绘制分贝数

    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }

    
    
    
    
    
    
    
    //settings :
    //limit of recoringTime 60s
    [_recorder recordForDuration:(NSTimeInterval) 60];
    self.recordTime = 0;
    [self resetTimer];
    //0.05s for upadte meters of progressView
	timer_ = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    [self showVoiceHudOrHide:YES]; //show HUD

}

///MARK: end record
- (void)stopRecordWithCompletionBlock:(void (^)())completion {
    dispatch_async(dispatch_get_main_queue(),completion);
    
    
    [self resetTimer];
    [self showVoiceHudOrHide:NO];
}

#pragma mark - Timer Update

- (void)updateMeters {
    
    self.recordTime += WAVE_UPDATE_FREQUENCY;
    if (voiceHud_) {
        
        /*  发送updateMeters消息来刷新平均和峰值功率。
         *  此计数是以对数刻度计量的，-160表示完全安静，
         *  0表示最大输入值
         */
        
        if (_recorder) {
            [_recorder updateMeters];
        }
    
        float peakPower = [_recorder averagePowerForChannel:0]; //average power
        double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (ALPHA * peakPower)); //10 的 （ 0.05 * 峰值功率） 次方  1 ~ 0.00000 001    Level *120
        [voiceHud_ setProgress:peakPowerForChannel];
    }
}

#pragma mark - Helper Function
- (void)showVoiceHudOrHide:(BOOL)yesOrNo{
    
    if (voiceHud_) {
        [voiceHud_ hide];
        voiceHud_ = nil;
    }
 
    if (yesOrNo) {
        voiceHud_ = [[LCVoiceHud alloc] init];
        [voiceHud_ show];
        
    }else{
        
    }
}







///MARK: cancel Record
- (void)resetTimer {
    if (timer_) {
        [timer_ invalidate];
        timer_ = nil;
    }
}



- (void)cancelRecording {
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    self.recorder = nil;    
}

- (void)cancelled {
    [self showVoiceHudOrHide:NO];
    [self resetTimer];
    [self cancelRecording];
}


#pragma mark - LCVoiceHud Delegate
- (void)LCVoiceHudCancelAction {
    [self cancelled];
}

@end
