//
//  MediaEntity.h
//  测试Demo
//
//  Created by YGTech on 2018/3/2.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 char filename[64];
 unsigned int createtime;
 unsigned int timelength;
 unsigned int filelength;
 RECORD_TYPE recordtype;
 */
 
typedef enum {
    
   snapshot = 0,
   videoRecod = 1,
    
}mdeiaType;

@interface MediaEntity : RLMObject



//@property (nonatomic,strong) NSData * _Nullable snapshot;





@property (nonatomic, copy) NSString * _Nonnull fileName;
@property (nonatomic, assign) int  timelength;
@property (nonatomic, assign) int  recordType;
@property (nonatomic, assign) int  createtime;
@property (nonatomic, assign) int  filelength;



@end

RLM_ARRAY_TYPE(MediaEntity)
