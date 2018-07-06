//
//  UIView+EqualMargin.m
//  HowToUseMasonry
//
//  Created by sharejoy on 16-05-29.
//  Copyright © 2016年 shangbin. All rights reserved.
//

#import "UIView+EqualMargin.h"
#import "Masonry.h"

@implementation UIView (EqualMargin)




- (void)distributeSpacingHorizontallyWith:(NSArray*)views {
    
    
    NSMutableArray *spaces = [NSMutableArray arrayWithCapacity:views.count + 1];

    
    
    
    ///delete previous v_btns
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 1000) {
            [obj removeFromSuperview];
        }
    }];
    
   
    ///add new  v_btns
    for ( int i = 0 ; i < views.count + 1; ++i ){
        UIButton *v_btn = [UIButton new];
        [v_btn setTag:1000];
        [spaces addObject:v_btn];
        [self addSubview:v_btn];
        [v_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(v_btn.mas_height);   //宽高相同
        }];
    }
    
    
    
    
    
    
    
    
    UIView *v_btn0 = spaces[0];
    
    __weak __typeof(&*self)ws = self;
    
    [v_btn0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.mas_left);
//        make.centerY.equalTo( ((UIView *)views[0] ).mas_centerY );
        make.centerY.equalTo(views[0]);

    }];
    
    UIView *lastSpace = v_btn0;
    
    //views.count
    for ( int i = 0 ; i < views.count; ++i )
    {
        UIView *obj = views[i];
        UIView *space = spaces[i+1];
        
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastSpace.mas_right);
        }];
        
        [space mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(obj.mas_right);
            make.centerY.equalTo(obj.mas_centerY);
            make.width.equalTo(v_btn0);
        }];
        
        lastSpace = space;//更换下一个btn，重复执行约束
    }
    
    [lastSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ws.mas_right);
    }];
    
}



- (void) distributeSpacingVerticallyWith:(NSArray*)views
{
    NSMutableArray *spaces = [NSMutableArray arrayWithCapacity:views.count+1];
    
    for ( int i = 0 ; i < views.count+1 ; ++i )
    {
        UIView *v = [UIView new];
        [spaces addObject:v];
        [self addSubview:v];
        
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(v.mas_height);
        }];
    }
    
    
    UIView *v0 = spaces[0];
    
    __weak __typeof(&*self)ws = self;
    
    [v0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.mas_top);
        make.centerX.equalTo(((UIView*)views[0]).mas_centerX);
    }];
    
    UIView *lastSpace = v0;
    for ( int i = 0 ; i < views.count; ++i )
    {
        UIView *obj = views[i];
        UIView *space = spaces[i+1];
        
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastSpace.mas_bottom);
        }];
        
        [space mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(obj.mas_bottom);
            make.centerX.equalTo(obj.mas_centerX);
            make.height.equalTo(v0);
        }];
        
        lastSpace = space;
    }
    
    [lastSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(ws.mas_bottom);
    }];
}

@end
