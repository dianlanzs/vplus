//
//  NSString+Check.m
//  MrBear
//
//  Created by XiaXianBing on 2016-7-31.
//  Copyright © 2016年 MrBear. All rights reserved.
//

#import "NSString+Check.h"

@implementation NSString (Check)

- (BOOL)emailCheck {
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)phoneCheck {
    NSString *regex = @"1[3|4|5|7|8][0-9]{9}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)idCardNumCheck {
    if (self.length != 18) {
        return NO;
    }
    
    NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
    NSString *leapMmdd = @"0229";
    NSString *year = @"(19|20)[0-9]{2}";
    NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
    NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
    NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
    NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
    NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}";
    NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![regexTest evaluateWithObject:self]) {
        return NO;
    }
    
    int summary = ([self substringWithRange:NSMakeRange(0,1)].intValue +
                   [self substringWithRange:NSMakeRange(10,1)].intValue) * 7
                + ([self substringWithRange:NSMakeRange(1,1)].intValue +
                   [self substringWithRange:NSMakeRange(11,1)].intValue) * 9
                + ([self substringWithRange:NSMakeRange(2,1)].intValue +
                   [self substringWithRange:NSMakeRange(12,1)].intValue) * 10
                + ([self substringWithRange:NSMakeRange(3,1)].intValue +
                   [self substringWithRange:NSMakeRange(13,1)].intValue) * 5
                + ([self substringWithRange:NSMakeRange(4,1)].intValue +
                   [self substringWithRange:NSMakeRange(14,1)].intValue) * 8
                + ([self substringWithRange:NSMakeRange(5,1)].intValue +
                   [self substringWithRange:NSMakeRange(15,1)].intValue) * 4
                + ([self substringWithRange:NSMakeRange(6,1)].intValue +
                   [self substringWithRange:NSMakeRange(16,1)].intValue) * 2
                + [self substringWithRange:NSMakeRange(7,1)].intValue * 1
                + [self substringWithRange:NSMakeRange(8,1)].intValue * 6
                + [self substringWithRange:NSMakeRange(9,1)].intValue * 3;
    NSInteger remainder = summary % 11;
    NSString *checkBit = @"";
    NSString *checkString = @"10X98765432";
    checkBit = [checkString substringWithRange:NSMakeRange(remainder, 1)]; //判断校验位
    return [checkBit isEqualToString:[[self substringWithRange:NSMakeRange(17,1)] uppercaseString]];
}

@end
