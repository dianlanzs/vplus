//
//  NSString+Check.h
//  MrBear
//
//  Created by XiaXianBing on 2016-7-31.
//  Copyright © 2016年 MrBear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Check)

- (BOOL)emailCheck;
- (BOOL)phoneCheck;
- (BOOL)idCardNumCheck;

@end
