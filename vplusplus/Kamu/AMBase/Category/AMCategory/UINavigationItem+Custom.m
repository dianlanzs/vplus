//
//  UINavigationItem+Custom.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "UINavigationItem+Custom.h"

static id<CustomNavigationItemDelegate> _delegate;
@implementation UINavigationItem (Custom)

- (void)setTitle:(NSString *)title withColor:(UIColor*)color {
    UILabel *customLab = [[UILabel alloc] initWithFrame:CGRectMake((320 - 180)/2, 0, 180, 44)];
    customLab.textColor = color;
    [customLab setText:title];
    customLab.backgroundColor = [UIColor clearColor];
    customLab.textAlignment = NSTextAlignmentCenter;
    customLab.font = [UIFont boldSystemFontOfSize:20];
    self.titleView = customLab;
}

- (void)setTitle:(NSString *)title withColor:(UIColor *)color shadowOffset: (CGSize)shadowOffset shadowColor: (UIColor *)shadowColor {
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake((320 - 180)/2, 0, 180, 44)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *customLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    customLab.textColor = color;
    [customLab setText:title];
    customLab.backgroundColor = [UIColor clearColor];
    customLab.textAlignment = NSTextAlignmentCenter;
    customLab.font = [UIFont boldSystemFontOfSize:20];
    customLab.shadowColor = shadowColor;
    customLab.shadowOffset = shadowOffset;
    [view addSubview:customLab];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = customLab.frame;
    [btn addTarget: self action: @selector(didButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    self.titleView = view;
    _delegate = nil;
}

-(void)setPTTitle:(NSString *)title {
#if 0
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake((320 - 180)/2, 0, 180, 44)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *customLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
    [customLab setText:title];
    customLab.textColor = [UIColor whiteColor];
    customLab.backgroundColor = [UIColor clearColor];
    customLab.textAlignment = NSTextAlignmentCenter;
    customLab.font = [UIFont boldSystemFontOfSize:20];
    [view addSubview:customLab];
    [customLab release];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = customLab.frame;
    [btn addTarget: self action: @selector(didButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    self.titleView = view;
    _delegate = nil;
#else
    [self setTitle:title];
#endif
}

-(void)didButtonPressed:(id)sender {
    if ( [_delegate respondsToSelector:@selector(didNavigationTitleClicked)] ) {
        [_delegate didNavigationTitleClicked];
    }
}

-(void)setDelegate:(id<CustomNavigationItemDelegate>)delegate {
    _delegate = delegate;
}

-(id<CustomNavigationItemDelegate>)getDelegate {
    return _delegate;
}

@end

