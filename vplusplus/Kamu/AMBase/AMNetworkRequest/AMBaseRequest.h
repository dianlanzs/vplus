//
//  AMBaseRequest.h
//  IpcTest
//
//  Created by YGTech on 2017/11/14.
//  Copyright © 2017年 YGTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AMResponse.h"
//#import "A"


typedef void (^AMRequestSuccess)(AMResponse *respose); //请求成功block
typedef void (^AMRequestFailure)(NSError *error); //请求失败












@interface AMBaseRequest : NSObject

@end
