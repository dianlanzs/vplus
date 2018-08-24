//
//  RLMObject+ThreadReslove.m
//  Kamu
//
//  Created by YGTech on 2018/8/10.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "RLMObject+ThreadReslove.h"

@implementation RLMObject (ThreadReslove)
- (void)asyncThreadReslove:(func)op {
    
    RLMThreadSafeReference *objRef = [RLMThreadSafeReference  referenceWithThreadConfined:self];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            RLMRealm *realm = [RLMRealm realmWithConfiguration:RLM.configuration error:nil];
            RLMObject *reslovedObj = [realm resolveThreadSafeReference:objRef];
            if (reslovedObj) { ///user 处理好了 ，通知 user 来用
                op(reslovedObj);
            }
        }
    });
}
@end
