//
//  UINavigationItem+Custom.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UINavigationItem;

@protocol CustomNavigationItemDelegate <NSObject>

@optional
- (void)didNavigationTitleClicked;
@end


@interface UINavigationItem (Custom)

-(void)setDelegate:(id<CustomNavigationItemDelegate>)delegate;
-(void)setTitle:(NSString *)title withColor:(UIColor*)color;
-(void)setTitle:(NSString *)title withColor:(UIColor *)color shadowOffset: (CGSize)shadowOffset shadowColor: (UIColor *)shadowColor;
// for paintingTycoon
-(void)setPTTitle:(NSString *)title;

@end
