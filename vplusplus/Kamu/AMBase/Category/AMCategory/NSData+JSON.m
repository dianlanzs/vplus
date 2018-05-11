//
//  NSData+JSON.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "NSData+JSON.h"

@implementation NSData (JSON)

+ (NSData *)JSONDataWithObject:(id)object {
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    if (data) {
        return data;
    }
    return nil;
}

@end
