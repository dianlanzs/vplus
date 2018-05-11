//
//  NSObject+Notification.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "NSObject+Notification.h"

@implementation NSObject (Notification)

- (void)registerNotificationOnMainThread:(NSString *)name {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:name object:nil];
}

- (void)registerNotificationOnMainThread:(NSString *)name object:(id)object {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:name object:object];
}

- (void)receiveNotification:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(didReceiveNotificationOnMainThread:) withObject:notification waitUntilDone:NO];
}

- (void)didReceiveNotificationOnMainThread:(NSNotification *)notification {
    NSLog(@"Warning: didReceiveNotificationOnMainThread: should be overrided by subclass!!!");
}

@end
