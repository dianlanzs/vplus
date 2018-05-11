//
//  NSData+Encode.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encode)

@property (nonatomic, readonly) NSString *md5Hash;
@property (nonatomic, readonly) unsigned char *md5Hash16;
@property (nonatomic, readonly) NSString *sha1Hash;

- (NSString *)md5Hash;
- (NSString *)sha1Hash;
- (unsigned char *)md5Hash16;

- (NSString *)base64Encode;
- (NSString *)base64Decode;

@end
