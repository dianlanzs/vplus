//
//  UIView+ButtonsBar.m
//  Kamu
//
//  Created by YGTech on 2018/1/8.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "UIView+ButtonsBar.h"
#import "UIView+EqualMargin.h"

@implementation UIView (ButtonsBar)


- (void)addButtons:(NSArray *)icons width:(CGFloat)width constarintToView:(UIView *)refView centerOffset:(CGFloat)offset isZoomMiddle:(BOOL)needZoom {
    
    
    //faterView  需要临时创建  ---调用这个方法
    
    //图标数组
//    NSArray *iconArray = @[@"lock",@"bell",@"cloud",@"SDCard",@"settings"];
    
    //设置按钮的宽度
    CGFloat btnWidth = width;
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        
        MRoundedButton *btn = [[MRoundedButton alloc] initWithFrame:CGRectZero buttonStyle:MRoundedButtonCentralImage appearanceIdentifier:@"MRButton_Default"];
        
        //设置 button 图标 ，并且设置 图片渲染模式
        UIImage *btnIcon = [[ UIImage imageNamed:[NSString stringWithFormat:@"button_%@",icons[i]] ] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        btn.imageView.image = btnIcon;
        btn.tag =  i;
        
        //先添加 到父视图 ,,--->cell 加到 contentView
        [self addSubview:btn];
        [buttons addObject:btn];
        
        
        
        ////设置约束！ 修改中间的button的宽度：60
        if (btn.tag == 2 && needZoom) {
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                //约束1： button中心 对其 media底部
                make.centerY.equalTo(refView.mas_bottom).offset(offset);
                //约束2：设置宽度
                make.width.mas_equalTo(btnWidth * 1.2);
                //约束3： 宽高比例 1：1
                make.height.equalTo(btn.mas_width);
                
                btn.foregroundColor = [UIColor purpleColor];
            }];
        }else{
            
            //其他 button 控件 宽度 ：40
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.equalTo(refView.mas_bottom).offset(0.f);
                make.width.mas_equalTo(btnWidth);
                make.height.equalTo(btn.mas_width);
                
            }];
            
        }
        
    }
    
    
    //水平方向 平分button布局
    [self distributeSpacingHorizontallyWith:buttons];
    
    
    
    
    
}

@end
