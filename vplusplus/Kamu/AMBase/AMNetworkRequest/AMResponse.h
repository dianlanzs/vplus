//
//  AMResponse.h
//  IpcTest
//
//  Created by Zhoulei on 2017/11/14.
//  Copyright © 2017年 Zhoulei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMResponse : NSObject

@property (nonatomic ,assign) BOOL isSuccess;
@property (nonatomic ,copy) NSArray *data;
@property (nonatomic ,assign)NSInteger errorCode;


@end
