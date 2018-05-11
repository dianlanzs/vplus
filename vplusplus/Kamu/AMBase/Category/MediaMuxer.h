//
//  MediaMuxer.h
//  测试Demo
//
//  Created by YGTech on 2018/3/12.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaMuxer : NSObject

//合成MP4
int muxer_main(const char *inputH264FileName, const char *inputPcmFileName, const char *outMP4FileName,const char* angle);


//PCM 编码 AAC
int pcmToAacEncoding(const char *input_pcmFilePath, const char *output_aacFilePath);

//- (int)pcmToAacEncoding:(const char *)input_pcmFilePath aacFile:(const char *)output_aacFilePath;






@end
