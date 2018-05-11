//
//  NSString+Encode.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "NSString+Encode.h"
#import "NSData+Encode.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Encode)

- (BOOL)isUrl {
    return [self hasPrefix: @"http://"] || [self hasPrefix: @"https://"];
}

- (NSString *)notNuLL {
    if ((NSNull *)self == [NSNull null]) {
        return @"";
    }
    if (self == nil) {
        return @"";
    }
    if ([self isEqualToString:@"<null>"]) {
        return @"";
    }
    if ([self isEqualToString:@"(null)"]) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@", self];
}

- (NSString *)urlEncode {
    NSString *encodedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    return encodedString;
}

- (NSString *)urlDecode {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)md5Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}

- (NSString *)sha1Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion: YES] sha1Hash];
}

- (NSString *)base64Encode {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64Encode];
}

- (NSString *)base64Decode {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [data base64Decode];
}

@end
