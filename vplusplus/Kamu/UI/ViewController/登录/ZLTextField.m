//
//  ZLTextField.m
//  Kamu
//
//  Created by YGTech on 2018/7/10.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "ZLTextField.h"
#import "UIView+Frame.h"
@implementation ZLTextField 


///given new feture   move up automatic

- (instancetype)init {
    if (self = [super init] ) {
        [self addNotifications];
        [self setFont:[UIFont systemFontOfSize:15.f]];
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;  ///capitalization ,大写
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
    return self;
}

/// drawing and positioning overrides
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    
    ///override  父类方法 ，必须先还原  保持父类 feature ,!调用 super
    CGRect iconRect = [super leftViewRectForBounds:bounds]; iconRect.origin.x += 10;
    //像右边偏15
    return iconRect;
    
}
    
  
- (void)setIcon:(UIImage *)icon {
    if (icon != _icon) {
        _icon = icon;
        self.leftView = [[UIImageView alloc] initWithImage:icon];
        self.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addNotifications];
}
- (void)addNotifications {
    //注册键盘弹出、隐藏通知

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueChanged) name:UITextFieldTextDidChangeNotification object:self];
    [self setDelegate:self];

}
- (void)valueChanged {
    //判断文本框内容
    BOOL flag = NO;
    for (UITextField *tf in self.superview.subviews) {
        ///其他 tf
        if ([tf isKindOfClass:[UITextField class]]&& ![tf isEqual:self] ) {
             flag = (self.text.length > 0 &&  tf.text.length > 0);
        }
        ///一个 tf
        else if ([tf isEqual:self] ) {
            flag = self.text.length > 0;
        }
    }
    
    self.filledNotify(flag);
}

//键盘弹出后将视图向上移动

-(void)keyboardWillShow:(NSNotification *)note {
    
    NSDictionary *info = [note userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //目标视图UITextField
    
   
    UIView *bottomWiget = [UIView new];
    [self.superview.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (bottomWiget.y < obj.y  ) {
            [bottomWiget setFrame:obj.frame];
        }
    }];

    

    int y = bottomWiget.frame.origin.y + bottomWiget.frame.size.height - (self.superview.frame.size.height - keyboardSize.height);
    
    NSTimeInterval animationDuration = 0.3f;
    
    [UIView beginAnimations:@"ResizeView" context:nil];
    
    
    [UIView setAnimationDuration:animationDuration];
    
    if(y > 0){
        
        self.superview.frame = CGRectMake(0, - (y + 10), self.superview.frame.size.width, self.superview.frame.size.height); //10  系数
        
    }
    
    [UIView commitAnimations];
    
}


//键盘隐藏后将视图恢复到原始状态

-(void)keyboardWillHide:(NSNotification *)note {
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeView" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    self.superview.frame =CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);
    
    [UIView commitAnimations];
    
}

#pragma mark - TextField 代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // called when 'return' key pressed. return NO to ignore.
    [textField resignFirstResponder];
    return YES;
}

@end
