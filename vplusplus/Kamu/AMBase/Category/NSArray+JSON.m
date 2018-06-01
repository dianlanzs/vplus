//
//  NSArray+JSON.m
//  IpcTest
//
//  Created by Zhoulei on 2017/11/14.
//  Copyright © 2017年 Zhoulei. All rights reserved.
//

#import "NSArray+JSON.h"

@implementation NSArray (JSON)
- (id)arrayWithJSONData:(NSData *)data {
    
    //1.NSJSONReadingAllowFragments = 如果服务器返回的JSON数据，不是标准的JSON，那么就必须使用这个值，否则无法解析!
    //2.NSJSONReadingMutableContainers = 转换出来的对象是可变数组或者可变字典
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (![object isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return object;
}

@end
