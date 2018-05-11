//
//  NSDictionary+JSON.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

+ (id)dictionaryWithJSONData:(NSData *)data;
+ (id)dictionaryWithJSONString:(NSString *)str;

@end
