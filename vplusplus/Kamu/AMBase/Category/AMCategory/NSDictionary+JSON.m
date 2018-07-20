//
//  NSDictionary+JSON.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

+ (id)dictionaryWithJSONData:(NSData *)data {
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"-------/n%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if (![object isKindOfClass:[NSDictionary class]]) {
        if ([object isKindOfClass:[NSArray class]]) {
            return [object objectAtIndex:0];
        }
        return nil;
    }
    return object;
}

+ (id)dictionaryWithJSONString:(NSString *)str {
    id object = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if (![object isKindOfClass:[NSDictionary class]]) {
        if ([object isKindOfClass:[NSArray class]]) {
            return [object objectAtIndex:0];
        }
        return nil;
    }
    return object;
}

@end
