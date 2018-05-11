//
//  NSDictionary+Extension.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)

- (id)stringValueForKey:(NSString *)key;
- (id)numberValueForKey:(NSString *)key;
- (id)arrayValueForKey:(NSString *)key;

@end
