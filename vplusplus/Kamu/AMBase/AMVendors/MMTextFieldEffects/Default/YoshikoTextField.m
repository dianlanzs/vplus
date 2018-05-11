//
//  YoshikoTextField.m
//  BWWalkthroughExample
//
//  Created by mukesh mandora on 24/07/15.
//  Copyright (c) 2015 Yari D'areglia. All rights reserved.
//



#define FONT [UIFont systemFontOfSize:16.0f]
static const CGFloat TF_H = 65.0f;
static const CGFloat topSpace_h = 25.0f;
static const CGFloat holderLabel_h = 20.0f;

static const CGFloat inputF_boderW = 2.0f;
static const CGFloat inputF_cornerRadius = 5.0f;

static const CGFloat holderLabel_Y = ((TF_H - holderLabel_h - topSpace_h ) * 0.5) + topSpace_h;


static NSString *holderText = @"请输入密码";
#import "YoshikoTextField.h"

@interface YoshikoTextField () {
    //间距
    CGFloat inset;
    //边框
    CALayer *borderTextField;
    //占位文字 inset
    CGPoint textFieldInset,placeholderInset;
}

//Label
@property (strong, nonatomic) UILabel *placeHolderLabel;
//高度
@property (nonatomic,assign) CGFloat placeholderHeight;


@end





@implementation YoshikoTextField
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

#pragma mark - 自定义绘制，输入框
- (void)drawRect:(CGRect)rect {
    
    borderTextField = [[CALayer alloc] init];
    borderTextField.frame = CGRectMake(0, topSpace_h, self.bounds.size.width, self.bounds.size.height - topSpace_h);
    borderTextField.borderColor = [UIColor lightGrayColor].CGColor;
    borderTextField.borderWidth = inputF_boderW;
    borderTextField.backgroundColor = [UIColor lightGrayColor].CGColor;
    borderTextField.cornerRadius = inputF_cornerRadius;
    borderTextField.masksToBounds = YES;
    [self.layer addSublayer:borderTextField];
    [self addPlaceHolderLabel];
    
}

- (void)valueChanged {
    ;
}
#pragma mark - 初始化实例方法
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    self.delegate = self;
    //通过通知监听文本框变化 ,,,改变Button 点击状态用的 ，这里不需要 ，如果有值改变 ，Enanble = YES
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueChanged) name:UITextFieldTextDidChangeNotification object:self];
    
    
    if (self) {
//        self.placeHolderLabel = [[UILabel alloc] init];
//        self.placeHolderLabel.text = @"请输入设备密码:";
//        self.placeHolderLabel.textColor = [UIColor whiteColor];
//        self.placeHolderLabel.backgroundColor = [UIColor clearColor];
//        self.placeHolderLabel.font = FONT;
//        self.placeHolderLabel.textAlignment = NSTextAlignmentLeft;
    
        self.placeHolderLabel = [UILabel labelWithText:holderText withFont:FONT color:[UIColor whiteColor] aligment:NSTextAlignmentLeft];
        self.placeHolderLabel.backgroundColor = [UIColor clearColor];

        
        placeholderInset = CGPointMake(6, 0);
        textFieldInset = CGPointMake(6, 0);
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
    
}


#pragma mark - 占位文字高度 setter/getter
- (void)setPlaceholderHeight:(CGFloat)placeholderHeight {
    
}

//获取高度
- (CGFloat)placeholderHeight {
    
    //TextField 高度 * 0.7 // default is nil. use system font 12 pt
    
    //-25 = *** 55!!
    
    // ,fontSize = 22    //fontOfText = Helvetica ,fontSize = 22*0.7 = 15.4 ,, fontOfText lineH ~18 ,placeH = 18 + 6 = 24
    //self.font = XXX   LabelH = 20 , self.Font.lineH = 30.05
    UIFont *fontOfText = [UIFont fontWithName:@"HelveticaNeue" size:self.font.pointSize * 0.7];
    //高度偏移6 + 字的高度
    
    /*    */
    return placeholderInset.y + fontOfText.lineHeight;

}


//添加 placeHoder
- (void)addPlaceHolderLabel {
    
    //H总 - h - LableH /2   + 25
    self.placeHolderLabel.frame = CGRectMake(textFieldInset.x * 2, holderLabel_Y, self.bounds.size.width - textFieldInset.x * 4, holderLabel_h);
    [self addSubview:self.placeHolderLabel];
    
}

- (void)setBorderLayer {
    
}


#pragma mark - 文本编辑区域 和 光标坐标位置！
-(CGRect)textRectForBounds:(CGRect)bounds {
///MARK:光标坐标 = TF的高度 - Top Space 的高度！即 65 - 25!!!!
    return CGRectOffset(self.bounds,textFieldInset.x * 2, 32.5  );
}
//编辑 Rect 区域
-(CGRect)editingRectForBounds:(CGRect)bounds {
    
    return [self textRectForBounds:bounds];
}


#pragma mark - **开始编辑状态,改变‘Frame’动画
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView transitionWithView:self.placeHolderLabel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
    self.placeHolderLabel.frame = CGRectMake(textFieldInset.x * 2, 0, self.bounds.size.width - textFieldInset.x * 4, holderLabel_h);
    [self.placeHolderLabel setText:[holderText uppercaseString]];
    [self.placeHolderLabel setTextColor:[UIColor colorWithRed:1 green:0.4 blue:0 alpha:1]];
    borderTextField.backgroundColor = [UIColor whiteColor].CGColor;
    borderTextField.borderColor = [UIColor colorWithRed:1 green:0.4 blue:0 alpha:1].CGColor;
    } completion:^(BOOL finished) {
        //完成后操作....
    }];
    
}

//辞去第一响应者
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self resignFirstResponder];
    return YES;
}

#pragma mark - 输入内容为空
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if([textField.text isEqual:@""]){
        
        [UIView transitionWithView:self.placeHolderLabel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.placeHolderLabel setTextColor:[UIColor whiteColor]];
            self.placeHolderLabel.frame = CGRectMake(textFieldInset.x * 2, holderLabel_Y, self.bounds.size.width - textFieldInset.x * 4, holderLabel_h);
            [self.placeHolderLabel setText:[holderText capitalizedString]];
            borderTextField.backgroundColor = [UIColor lightGrayColor].CGColor;
            borderTextField.borderColor = [UIColor clearColor].CGColor;
        } completion:^(BOOL finished) {
            //完成后操作....
        }];
        
    }
    
}


@end


