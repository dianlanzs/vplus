//
//  Cam.h
//  Kamu
//
//  Created by Zhoulei on 2018/2/27.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaEntity.h"
@class Device;





@interface Cam : RLMObject

@property  NSString * _Nonnull cam_id;
@property  NSString * _Nullable cam_name;
@property  NSData * _Nullable cam_cover;
@property NSString * _Nullable cam_tag;


//@property (nonatomic, strong) NSDate * _Nullable date;

@property RLMArray <MediaEntity>  * _Nullable cam_medias;

@end

