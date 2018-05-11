//
//  NSDictionary+Extension.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

- (id)stringValueForKey:(NSString *)key {
    id string = [self objectForKey:key];
    if ([string isKindOfClass:[NSNull class]]) {
        return @"";
    } else if ([string isKindOfClass:[NSString class]]) {
        if ([string isEqualToString:@"null"] || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"（null）"]) {
            return @"";
        }
    } else if ([string isKindOfClass:[NSNumber class]]) {
        return [string stringValue];
    }
    return string;
}

- (id)numberValueForKey:(NSString *)key {
    id number = [self objectForKey:key];
    if ([number isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithInteger:0];
    } else if ([number isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithDouble:[number doubleValue]];
    }
    return number;
}

- (id)arrayValueForKey:(NSString *)key {
    id array = [self objectForKey:key];
    if ([array isKindOfClass:[NSArray class]]) {
        return array;
    }
    return nil;
}

@end
