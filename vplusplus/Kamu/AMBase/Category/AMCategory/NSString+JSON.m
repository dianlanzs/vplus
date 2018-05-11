//
//  NSString+JSON.m
//  MrBear
//
//  Created by XiaXianBing on 2016-8-4.
//  Copyright © 2016年 MrBear. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

+ (NSString *)JSONStrWithObject:(id)object {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonstr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonstr;
}

@end
