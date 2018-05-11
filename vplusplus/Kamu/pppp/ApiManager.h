//
//  ApiManager.h
//  iLnkView
//
//  Created by user on 17/4/12.
//  Copyright © 2017年 edwintech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ApiManager : NSObject

+ (void)getCameraSetInfo:(NSString *)did;
+ (void)getCameraAudio:(NSString *)did;
+ (int)setCameraParam:(NSString *)did param:(NSString *)param value:(NSString *)value;

@end
