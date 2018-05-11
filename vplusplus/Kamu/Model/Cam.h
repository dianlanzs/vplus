//
//  Cam.h
//  Kamu
//
//  Created by YGTech on 2018/2/27.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaEntity.h"
@class Device;
@interface Cam : RLMObject

@property  int cam_h;
@property  NSString * _Nonnull cam_id;
@property  NSString * _Nullable cam_name;
@property  NSData * _Nullable cam_cover;
@property NSString * _Nullable cam_tag;


@property RLMArray <MediaEntity>  * _Nullable cam_entities;

@end
RLM_ARRAY_TYPE(Cam)// 定义 RLMArray<Cam> 类型
