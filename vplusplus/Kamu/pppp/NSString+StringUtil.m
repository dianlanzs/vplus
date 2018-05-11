//
//  NSString+StringUtil.m
//  linphone
//
//  Created by Liuqs on 16/4/22.
//
//

#import "NSString+StringUtil.h"

@implementation NSString (StringUtil)



- (char *)charFromString {
    return (char *)self.UTF8String;
}


@end
