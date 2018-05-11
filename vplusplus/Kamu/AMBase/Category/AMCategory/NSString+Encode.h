//
//  NSString+Encode.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encode)

- (BOOL)isUrl;

- (NSString *)notNuLL;

- (NSString *)urlEncode;
- (NSString *)urlDecode;

- (NSString *)md5Hash;
- (NSString *)sha1Hash;
- (NSString *)base64Encode;
- (NSString *)base64Decode;

@end
