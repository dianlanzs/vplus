//
//  NSArray+JSON.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "NSArray+JSON.h"

@implementation NSArray (JSON)

+ (id)arrayWithJSONData:(NSData *)data {
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (![object isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return object;
}

@end
