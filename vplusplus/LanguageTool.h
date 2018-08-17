//
//  LanguageTool.h
//  Kamu
//
//  Created by YGTech on 2018/8/15.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageTool : NSObject

@property(nonatomic,copy)NSString *appLanguage;


+ (id)sharedInstance;
///LS wrappered
- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;

- (void)setNewAppLanguage:(NSString *)appLanguage;

@end
