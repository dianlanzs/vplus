//
//  MediaEntity.h
//  测试Demo
//
//  Created by Zhoulei on 2018/3/2.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cam.h"
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

//RLMObject
@interface MediaEntity : NSObject

/*给 cam.medias 正向添加一个 media 对象 ---- 就反向将该对象的 media.cams 属性设置为对应的 cam。
 为了解决这个问题，Realm 提供了连接对象属性，从而表示这种双向关系。*/
//@property (readonly) RLMLinkingObjects * _Nullable cams;
/*Media 对象可以拥有一个名为 cams 属性，它包含所有 medias ----> cams 属性有该 Media 对象的 Cam 对象*/


@property (nonatomic, copy)   NSString * _Nonnull fileName;
@property (nonatomic, assign) int  timelength;
@property (nonatomic, assign) int  recordType;
@property (nonatomic, assign) int  createtime;
@property (nonatomic, assign) int  filelength;


//@property (nonatomic, strong) NSDate * _Nullable date;


@end

RLM_ARRAY_TYPE(MediaEntity)
