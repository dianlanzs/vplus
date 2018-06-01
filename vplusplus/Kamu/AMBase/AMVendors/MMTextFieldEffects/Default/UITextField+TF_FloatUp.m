////
////  UITextField+TF_FloatUp.m
////  Kamu
////
////  Created by Zhoulei on 2017/12/14.
////  Copyright © 2017年 com.Kamu.cme. All rights reserved.
////
//
//#import "UITextField+TF_FloatUp.h"
//#import <objc/runtime.h>
//
//@import ReactiveObjC;
//@interface UITextField ()<UITextFieldDelegate>
//
////custom 自定义参数
//@property (strong, nonatomic) UILabel *lb_placeHolder;
//@property (nonatomic, strong) CALayer *inputBox;
////@property (nonatomic, assign) CGPoint tf_inset;
//
////方法参数赋值变量
//@property (nonatomic, strong) NSMutableAttributedString *lb_text;
//@property (nonatomic, assign) CGFloat  tf_height;
//@property (nonatomic, assign) CGFloat lb_height;
//@property (nonatomic, assign) CGFloat top_height;
//@property (nonatomic, assign) CGFloat ib_borderWidth;
//@property (nonatomic, assign) CGFloat lb_offset_y;
//
//
//@end
//
//
//
//
//@implementation UITextField (TF_FloatUp)
//
//#pragma mark - 自定义绘制，输入框
////- (void)drawRect:(CGRect)rect {
////
////    CALayer *inputBox = [[CALayer alloc] init];
////    inputBox.frame = CGRectMake(0, self.top_height, self.bounds.size.width, self.bounds.size.height - self.top_height);
////    inputBox.borderColor = [UIColor lightGrayColor].CGColor;
////    inputBox.borderWidth = self.ib_borderWidth;
////    inputBox.backgroundColor = [UIColor lightGrayColor].CGColor;
////    inputBox.cornerRadius = 5.0f;
////    inputBox.masksToBounds = YES;
////    
////    self.inputBox = inputBox;
////    [self.layer addSublayer:inputBox];
////
////    //-->添加的时候会调用 layoutSubViews 创建环境 --》调用DrawRect方法
////    CGPoint tf_inset = CGPointMake(6.0f, 0.0f);
////    self.lb_placeHolder.frame = CGRectMake(tf_inset.x * 2, self.lb_offset_y, self.bounds.size.width - tf_inset.x * 4, self.lb_height);
////    [self addSubview:self.lb_placeHolder];
////
////}
//
//
////- (instancetype)initWithFrame:(CGRect)frame {
////
////     self = [super initWithFrame:frame];
////
////     if (self) {
////           self.delegate = (id)self;
////
////
////
////     }
////
////
////}
//
/////MARK:图标和字体不一样大 的 或者没有图标的
//+ (instancetype)textFiedWithText:(NSMutableAttributedString *)attrText iconSize:(CGFloat)iconSize {
//    
//    return  [self textFiedWithText:attrText iconSize:iconSize labelFont:[UIFont systemFontOfSize:15.f]];
//    
//}
//
//
////针对图标 和字体 一样大 的
//+ (instancetype)textFiedWithText:(NSMutableAttributedString *)attrText {
//    
//    return [self textFiedWithText:attrText iconSize:15.f];
//}
//
//
//
//// 自定义 字体
//+ (instancetype)textFiedWithText:(NSMutableAttributedString *)attrText iconSize:(CGFloat)iconSize  labelFont:(UIFont *)labelFont {
//    
//    UITextField *tf = [[UITextField alloc] init];
//    
//    [tf textFiedWithText:attrText iconFontName:@"iconfont" iconFontSize:iconSize labelFont:labelFont tf_H:65.f labelHeight:25.f topHeight:25.f];
//    
//    return tf;
//}
//
////完全自定义 方法
//- (void)textFiedWithText:(NSMutableAttributedString *)attrText iconFontName:(NSString *)iconFontName iconFontSize:(CGFloat)iconSize labelFont:(UIFont *)font  tf_H:(CGFloat)h labelHeight:(CGFloat)labelHeight topHeight:(CGFloat)topHeight {
//    
//   
//    
//    
//    //不遵循 代理     self.delegate = （id）self;
//
//    self.delegate = self;
//    //赋值 伪成员变量
//
//    self.tf_height = h;
//    NSLog(@"🔵%f",self.bounds.size.height);
//    
//    
//    //设置 富文本属性
//    [attrText addAttribute:NSFontAttributeName value:[UIFont fontWithName:iconFontName size:iconSize] range:NSMakeRange(0, 1)];
//    //icon _文字部分
//    [attrText addAttribute:NSFontAttributeName value:font range:NSMakeRange(1, [attrText length] - 1 )];
//    self.lb_text = attrText;
//    
//    
//    
//    self.lb_height = labelHeight;
//    self.ib_borderWidth = 1.0f;
//    self.top_height = topHeight;
//    self.lb_offset_y = ((h - labelHeight - topHeight ) * 0.5) + topHeight;
//
////    设置 placeHoder 样式
//    self.lb_placeHolder = [[UILabel alloc] init];
//    [self.lb_placeHolder setAttributedText:attrText];
//    
//    ///MARK: 字体初始颜色
//    [self.lb_placeHolder setTextColor:[UIColor lightGrayColor]];
//    [self.lb_placeHolder setTextAlignment:NSTextAlignmentLeft];
//    
//    
//    
//    
//    [[self rac_signalForSelector:@selector(drawRect:)] subscribeNext:^(RACTuple * _Nullable x) {
//        CALayer *inputBox = [[CALayer alloc] init];
//        inputBox.frame = CGRectMake(0, self.top_height, self.bounds.size.width, self.bounds.size.height - self.top_height);
//        NSLog(@"🔴%f",self.bounds.size.height);
//        
//        self.tf_height = self.bounds.size.height;
//        
//        ///MARK:输入框 描边 和背景色 初始颜色
//        inputBox.borderColor = [UIColor lightGrayColor].CGColor;
//        inputBox.borderWidth = self.ib_borderWidth;
//        inputBox.backgroundColor = [UIColor whiteColor].CGColor;
//        inputBox.cornerRadius = 3.0f;
//        inputBox.masksToBounds = YES;
//        
//        self.inputBox = inputBox;
//        [self.layer addSublayer:inputBox];
//        
//        //-->添加的时候会调用 layoutSubViews 创建环境 --》调用DrawRect方法
//        CGPoint tf_inset = CGPointMake(6.0f, 0.0f);
//        self.lb_placeHolder.frame = CGRectMake(tf_inset.x * 2, self.lb_offset_y, self.bounds.size.width - tf_inset.x * 4, self.lb_height);
//        [self addSubview:self.lb_placeHolder];
//    }];
//    
//   
//}
//
//
//
//
//
////MARK: 代理回调方法
//#pragma mark - 文本编辑区域 和 光标坐标位置！
//- (CGRect)textRectForBounds:(CGRect)bounds {
//    
//    CGPoint tf_inset = CGPointMake(6.0f, 0.0f);
//    //25 +
//    return CGRectOffset(self.bounds,tf_inset.x * 2, self.top_height + (self.bounds.size.height - self.top_height - self.top_height) * 0.5   );
//}
////编辑 Rect 区域
//- (CGRect)editingRectForBounds:(CGRect)bounds {
//    
//    return [self textRectForBounds:bounds];
//}
//
//
//#pragma mark - **开始编辑状态,改变‘Frame’动画
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    
//    CGPoint tf_inset = CGPointMake(6.0f, 0.0f);
//    [UIView transitionWithView:self.lb_placeHolder duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        self.lb_placeHolder.frame = CGRectMake(tf_inset.x * 2, 0, self.bounds.size.width - tf_inset.x * 4, self.lb_height);
//        self.lb_placeHolder.attributedText = self.lb_text;
//        
//        ///MARK:文字编辑时候  描边 颜色
//        [self.lb_placeHolder setTextColor:[UIColor colorWithHex:@"0066ff"]];
//        self.inputBox.backgroundColor = [UIColor whiteColor].CGColor;
//        self.inputBox.borderColor = [UIColor colorWithHex:@"0066ff"].CGColor;
//    } completion:^(BOOL finished) {
//        //完成后操作....
//    }];
//    
//}
//
////辞去第一响应者
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    
//    //退出键盘
//    [self resignFirstResponder];
////    return NO; === 只有1个 tf
//    
//    return YES;
//    
//}
//
//#pragma mark - 输入内容为空
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    
//    
//    CGPoint tf_inset = CGPointMake(6.0f, 0.0f);
//    
//    if([textField.text isEqual:@""]){
//        
//        [UIView transitionWithView:self.lb_placeHolder duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//            
//            //设置文字 颜色
//            [self.lb_placeHolder setTextColor:[UIColor lightGrayColor]];
//            self.lb_placeHolder.frame = CGRectMake(tf_inset.x * 2, self.lb_offset_y, self.bounds.size.width -  tf_inset.x * 4,   self.lb_height);
//            
//            [self.lb_placeHolder setAttributedText:self.lb_text];
//            
//            
//            ///MARK:下方方框 背景色 描边 ,变化后背景色
//            self.inputBox.backgroundColor = [UIColor whiteColor].CGColor;
//            self.inputBox.borderColor = [UIColor lightGrayColor].CGColor;
//            
//            
//        } completion:^(BOOL finished) {
//            //完成后操作....
//        }];
//        
//    }
//    
//}
//
//#pragma mark - Required!
////tf_inset
//
// 
////占位文字
//- (void)setLb_placeHolder:(UILabel *)lb_placeHolder {
//    objc_setAssociatedObject(self, @selector(lb_placeHolder), lb_placeHolder, OBJC_ASSOCIATION_RETAIN);
//}
//- (UILabel *)lb_placeHolder {
//    return objc_getAssociatedObject(self, @selector(lb_placeHolder));
//}
//
////Layer
//- (void)setInputBox:(CALayer *)inputBox {
//    objc_setAssociatedObject(self, @selector(inputBox), inputBox, OBJC_ASSOCIATION_RETAIN);
//
//}
//- (CALayer *)inputBox {
//    return objc_getAssociatedObject(self, @selector(inputBox));
//}
//
////提示文本
//- (void)setLb_text:(NSMutableAttributedString *)lb_text {
//    objc_setAssociatedObject(self, @selector(lb_text), lb_text, OBJC_ASSOCIATION_COPY_NONATOMIC);
//
//}
//- (NSMutableAttributedString *)lb_text {
//    return objc_getAssociatedObject(self, @selector(lb_text));
//}
//
////tf 高度
//- (void)setTf_height:(CGFloat)tf_height {
//    objc_setAssociatedObject(self, @selector(tf_height), [NSNumber numberWithFloat:tf_height], OBJC_ASSOCIATION_RETAIN);
//}
//- (CGFloat)tf_height {
//    return [objc_getAssociatedObject(self, @selector(tf_height)) floatValue];
//}
//
////文字lable 的高度
//- (void)setLb_height:(CGFloat)lb_height {
//    objc_setAssociatedObject(self, @selector(lb_height), [NSNumber numberWithFloat:lb_height], OBJC_ASSOCIATION_RETAIN);
//}
//- (CGFloat)lb_height {
//    return [objc_getAssociatedObject(self, @selector(lb_height)) floatValue];
//}
//
////top 的高度
//- (void)setTop_height:(CGFloat)top_height {
//    objc_setAssociatedObject(self, @selector(top_height), [NSNumber numberWithFloat:top_height], OBJC_ASSOCIATION_RETAIN);
//
//}
//- (CGFloat)top_height {
//    return [objc_getAssociatedObject(self, @selector(top_height)) floatValue];
//}
//
////边框 描边宽度
//- (void)setIb_borderWidth:(CGFloat)ib_borderWidth {
//    objc_setAssociatedObject(self, @selector(ib_borderWidth), [NSNumber numberWithFloat:ib_borderWidth], OBJC_ASSOCIATION_RETAIN);
//
//}
//- (CGFloat)ib_borderWidth {
//    return [objc_getAssociatedObject(self, @selector(ib_borderWidth)) floatValue];
//}
//
////offset_y
//- (void)setLb_offset_y:(CGFloat)lb_offset_y {
//    objc_setAssociatedObject(self, @selector(lb_offset_y), [NSNumber numberWithFloat:lb_offset_y], OBJC_ASSOCIATION_RETAIN);
//}
//- (CGFloat)lb_offset_y {
//    return [objc_getAssociatedObject(self, @selector(lb_offset_y)) floatValue];
//
//}
//
//
//
////
///* 关联策略
// enum {
// OBJC_ASSOCIATION_ASSIGN = 0, //关联对象的属性是弱引用
// OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, //关联对象的属性是强引用并且关联对象不使用原子性
// OBJC_ASSOCIATION_COPY_NONATOMIC = 3, //关联对象的属性是copy并且关联对象不使用原子性
// OBJC_ASSOCIATION_RETAIN = 01401, //关联对象的属性是copy并且关联对象使用原子性
// OBJC_ASSOCIATION_COPY = 01403 //关联对象的属性是copy并且关联对象使用原子性
// };
//
// */
//
//
//
//
//@end

