//
//  NSObject+Notification.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Notification)

- (void)registerNotificationOnMainThread:(NSString *)name;
- (void)registerNotificationOnMainThread:(NSString *)name object:(id)object;

@end
