//
//  Popup.m
//  PopupDemo
//
//  Created by Mark Miscavage on 4/16/15.
//  Copyright (c) 2015 Mark Miscavage. All rights reserved.
//

#import "Popup.h"
#import "NSString+StringFrame.h"
//#import "UITextField+deleteEvent.h"


NSString const *SwipeVertical = @"VERTICAL";
#define FlatWhiteColor [UIColor colorWithRed:0.937 green:0.945 blue:0.961 alpha:1] /*#eff1f5*/
#define FlatWhiteDarkColor [UIColor colorWithRed:0.875 green:0.882 blue:0.91 alpha:1] /*#dfe1e8*/
//Title 文本设置
#define FONT_SUB  [UIFont fontWithName:@"HelveticaNeue" size:kPopupSubTitleFontSize]
#define FONT_HEAD [UIFont fontWithName:@"HelveticaNeue" size:kPopupHeadFontSize]
//主副标题 ,placeholder字体大小
static const CGFloat kPopupHeadFontSize = 20.f;
static const CGFloat kPopupSubTitleFontSize = 17.f;
static const CGFloat kTextFieldHolderSize = 15.f;

//弹框，键盘尺寸
CGFloat currentKeyboardHeight = 0.0f;
CGFloat popupDimensionWidth = 300.0f;
//按钮和文本框高度
CGFloat pTextFieldHeight = 40;
CGFloat pButtonHeight = 40;
CGFloat pHeaderHeight = 50;
//上下左右间距
CGFloat pTBPadding = 15;
CGFloat pLRPadding = 15;
//行间距
CGFloat pLineSpacing = 15;
//模糊效果
BOOL isBlurSet = YES;

@interface Popup () <UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate ,UITextInputTraits/*For swiping to dimiss*/> {
    
    UIView *backgroundView;
    UIView *popupView;
    
    UIScreen *mainScreen;
    blocky pSuccessBlock;
    blocky pCancelBlock;
    
    PopupBackGroundBlurType popupBlurType;
    
    PopupIncomingTransitionType incomingTransitionType;
    PopupOutgoingTransitionType outgoingTransitionType;
    
#pragma mark - 全局参数
    NSString *pTitle;
    NSString *pSubTitle;
    
    NSArray *pTextFieldPlaceholderArray;
    NSMutableArray *pTextFieldArray;
    
    NSString *pCancelTitle;
    NSString *pSuccessTitle;

    NSMutableArray *panHolder;

}
///IM3 ： 全局的PopView 高度
@property (nonatomic, assign) CGFloat popupDimensionHeight;

//主副标题
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@end






@implementation Popup

#pragma mark - Required!,自动设置高度
- (CGFloat)popupDimensionHeight {

    //设置间距系数
    CGFloat mutiple = pTextFieldPlaceholderArray.count + 2.5; //2 ~ 3 之间
    if (_popupDimensionHeight == 0) {
        
            _popupDimensionHeight = ceilf(pTBPadding * 2 + pButtonHeight + pHeaderHeight + pLineSpacing * mutiple + pTextFieldPlaceholderArray.count * pTextFieldHeight + [pSubTitle boundingRectWithFont:FONT_SUB]);
    }
    
    return _popupDimensionHeight;
}

//设置popView
- (void)setupPopupView {

    popupView = [[UIView alloc] initWithFrame:CGRectZero];
    [popupView setBackgroundColor:FlatWhiteColor];
    [popupView.layer setMasksToBounds:YES];
    [popupView.layer setCornerRadius:8.0];
    [popupView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [popupView.layer setBorderWidth:1.0];
    [self addSubview:popupView];
    
    //设置约束
    [popupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(popupDimensionWidth, self.popupDimensionHeight));
    }];
    
}

//主标题
- (UILabel *)titleLabel {
    
        if (pTitle) {
            
            if (!_titleLabel) {
                _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                [_titleLabel setFont:FONT_HEAD];
                [_titleLabel setAdjustsFontSizeToFitWidth:YES];
                [_titleLabel setTextAlignment:NSTextAlignmentCenter];
                [_titleLabel setTextColor:[UIColor blackColor] /*#546595*/];
                [_titleLabel setNumberOfLines:1]; //限制一行
                
            }
            //1、先添加到‘popup视图’再约束
            [_titleLabel setText:pTitle];
            [popupView addSubview:_titleLabel];
    
            //2、设置 header 的约束
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(popupView).offset(pTBPadding);
                make.leading.equalTo(popupView).offset(pLRPadding);
                make.trailing.equalTo(popupView).offset(- pLRPadding);
                //自动缩放
                [_titleLabel sizeToFit];
            }];
    
    
        }
    return _titleLabel;
}

///MARK:副标题
- (UILabel *)subTitleLabel {

    if (pSubTitle) {
        if (!_subTitleLabel) {
            //需要设置Frame 的一个 默认 初始值！
            _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [_subTitleLabel setFont:FONT_SUB];
            [_subTitleLabel setAdjustsFontSizeToFitWidth:YES];
            [_subTitleLabel setTextAlignment:NSTextAlignmentCenter];//  1.NSTextAlignmentCenter /  2.NSTextAlignmentLeft
            [_subTitleLabel setTextColor:[UIColor darkGrayColor] /*#687aae*/];
            _subTitleLabel.numberOfLines = 0;//不限制行数
            [_subTitleLabel setText:pSubTitle];
            
            //1、*先添加再设置约束
            [popupView addSubview:_subTitleLabel];
            //2、设置约束
            [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                //              make.center.equalTo(popupView);
                make.top.equalTo(self.titleLabel.mas_bottom).offset(pLineSpacing);
                make.leading.equalTo(self.titleLabel);
                make.trailing.equalTo(self.titleLabel);
                [_subTitleLabel sizeToFit]; //自动缩放
            }];
            
        }
        
    }
    
    return _subTitleLabel;
}


#pragma mark - 按钮
//取消按钮
- (BButton *)cancelBtn {

    if (!_cancelBtn) {
        _cancelBtn = [[BButton alloc] init];
        [_cancelBtn setTitleColor:FlatWhiteDarkColor forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]];
        [_cancelBtn setColor:[UIColor colorWithRed:0.91 green:0.184 blue:0.184 alpha:1] /*#e82f2f*/];
        [_cancelBtn addTarget:self action:@selector(pressAlertButton:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn.layer setCornerRadius:6.0];
        [_cancelBtn.layer setMasksToBounds:YES];
        
        //添加取消按钮
        [_cancelBtn setTitle:pCancelTitle forState:UIControlStateNormal];
        [popupView addSubview:_cancelBtn];
    }
    
    
    return _cancelBtn;
}

//确认按钮
- (BButton *)successBtn {
    
    if (!_successBtn) {
        _successBtn = [[BButton alloc] init];
        [_successBtn setTitleColor:FlatWhiteDarkColor forState:UIControlStateNormal];
        [_successBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0]];
        [_successBtn setColor:[UIColor colorWithHex:@"0066ff"]] ;//#687aae
        [_successBtn addTarget:self action:@selector(pressAlertButton:) forControlEvents:UIControlEventTouchUpInside];
        [_successBtn.layer setCornerRadius:6.0];
        [_successBtn.layer setMasksToBounds:YES];
        
        //添加取消按钮
        [_successBtn setTitle:pSuccessTitle forState:UIControlStateNormal];
        [popupView addSubview:_successBtn];
    }
    
    return _successBtn;
}



#pragma mark - Instance Types *** 对象实例化方式 ***
- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle {
    
    if ([super init]) {
        pTitle = title;
        pSubTitle = subTitle;
        pCancelTitle = cancelTitle;
        pSuccessTitle = successTitle;
        
        [self formulateEverything];
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
        textFieldPlaceholders:(NSArray *)textFieldPlaceholderArray
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle
                  cancelBlock:(blocky)cancelBlock
                 successBlock:(blocky)successBlock {
    
    if ([super init]) {
        pTitle = title;
        pSubTitle = subTitle;
        pTextFieldPlaceholderArray = textFieldPlaceholderArray;
        pCancelTitle = cancelTitle;
        pSuccessTitle = successTitle;
        pCancelBlock = cancelBlock;
        pSuccessBlock = successBlock;
        
        [self formulateEverything];
    }
    
    return self;
}


- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle
                  cancelBlock:(blocky)cancelBlock
                 successBlock:(blocky)successBlock {
    
    if ([super init]) {
        pTitle = title;
        pSubTitle = subTitle;
        pSuccessBlock = successBlock;
        pCancelTitle = cancelTitle;
        pSuccessTitle = successTitle;
        pCancelBlock = cancelBlock;
        
        [self formulateEverything];
    }
    
    return self;
}

#pragma mark - Creation Methods

- (void)formulateEverything {
    
  
    
    mainScreen =  [UIScreen mainScreen];
    [self setFrame:mainScreen.bounds];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:YES];
    
    
    //链式约束，按顺序约束 ，有依赖顺序！
    [self setupPopupView];
    
    [self titleLabel];
    [self subTitleLabel];
 


    
//先创建Buttons ,cuz约束从底部开始的
    [self setupButtons];
    [self setupTextFields];  ///MARK: 必须在TF 创建之后  注册 监听 ，&  通知 只能 注册 一次
    
    [self setIsShowing:NO];
    
}

- (void)blurBackgroundWithType:(PopupBackGroundBlurType)blurType {
    
    UIVisualEffect *blurEffect;

    switch (blurType) {
        case PopupBackGroundBlurTypeDark:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            break;
        case PopupBackGroundBlurTypeExtraLight:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            break;
        case PopupBackGroundBlurTypeLight:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            break;
        case PopupBackGroundBlurTypeNone:
            return;
            break;
        default:
            break;
    }
    
    backgroundView = [[UIView alloc] initWithFrame:mainScreen.bounds];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [visualEffectView setFrame:backgroundView.bounds];
    [backgroundView addSubview:visualEffectView];
    
    [backgroundView setAlpha:0.0];
    
    [self insertSubview:backgroundView belowSubview:popupView];
}



#pragma mark - Accessor Methods

- (void)setBackgroundBlurType:(PopupBackGroundBlurType)backgroundBlurType {
    [self blurBackgroundWithType:backgroundBlurType];
}

- (void)setIncomingTransition:(PopupIncomingTransitionType)incomingTransition {
    incomingTransitionType = incomingTransition;
}

- (void)setOutgoingTransition:(PopupOutgoingTransitionType)outgoingTransition {
    outgoingTransitionType = outgoingTransition;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [popupView setBackgroundColor:backgroundColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    [popupView.layer setBorderColor:borderColor.CGColor];
    [popupView.layer setBorderWidth:1.0];
}

- (void)setTitleColor:(UIColor *)titleColor {
    [self.titleLabel setTextColor:titleColor];
}

- (void)setSubTitleColor:(UIColor *)subTitleColor {
    [self.subTitleLabel setTextColor:self.subTitleColor];
}

- (void)setSuccessBtnColor:(UIColor *)successBtnColor {
    [self.successBtn setBackgroundColor:successBtnColor];
}

- (void)setSuccessTitleColor:(UIColor *)successTitleColor {
    [self.successBtn setTitleColor:successTitleColor forState:UIControlStateNormal];
}

- (void)setCancelBtnColor:(UIColor *)cancelBtnColor {
    [self.cancelBtn setBackgroundColor:cancelBtnColor];
}

- (void)setCancelTitleColor:(UIColor *)cancelTitleColor {
    [self.cancelBtn setTitleColor:cancelTitleColor forState:UIControlStateNormal];
}

- (void)setRoundedCorners:(BOOL)roundedCorners {
    if (roundedCorners) {
        [popupView.layer setMasksToBounds:YES];
        [popupView.layer setCornerRadius:8.0];
    }
    else {
        [popupView.layer setMasksToBounds:YES];
        [popupView.layer setCornerRadius:0.0];
    }
}

- (void)setOverallKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
 
    for (int i = 0; i < [pTextFieldArray count]; i++) {
        UITextField *textField = pTextFieldArray[i];
        [textField setKeyboardAppearance:keyboardAppearance];
    }
    
}

- (void)setTapBackgroundToDismiss:(BOOL)tapBackgroundToDismiss {

    if (tapBackgroundToDismiss) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
        [tap setNumberOfTapsRequired:1];
        [backgroundView addGestureRecognizer:tap];
    }
}

- (void)setSwipeToDismiss:(BOOL)swipeToDismiss {

    if (swipeToDismiss) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [pan setDelegate:self];
        [pan setMinimumNumberOfTouches:1];
        [pan setMaximumNumberOfTouches:1];
        [popupView addGestureRecognizer:pan];
        
        if (!panHolder) {
            panHolder = [NSMutableArray array];
        }
    }
}



#pragma mark - shrink tittle and subtitle if beyond its Frame
- (void)setupTextFields {

    if (pTextFieldPlaceholderArray) {
        
        //触碰文本框 的时候 退出 键盘
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
        [tap setNumberOfTapsRequired:1];
        [tap setDelegate:self];
        [popupView addGestureRecognizer:tap];
        //发送键盘状态通知
        [self setKeyboardNotifications];

//
//        static UITextField *textField1 = nil;
//        static UITextField *textField2 = nil;
//        static UITextField *textField3 = nil;
//        NSMutableArray *tf_array = [NSMutableArray array];
        UITextField *tf;
        pTextFieldArray = [NSMutableArray array];
        for (int i = 0; i < [pTextFieldPlaceholderArray count]; i++) {
            
//            if (i == 0) {
            
                [pTextFieldArray addObject:[self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:i + 1]];
//                tf = [self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:1];
//            }
            
//            else if (i == 1) {
//                tf = [self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:2];
//                [pTextFieldArray addObject:[self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:i + 1]];
//
//            }
            
//            else if (i == 2) {
//                tf = [self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:3];
//                [pTextFieldArray addObject:[self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:i + 1]];

//            }
            
//            else {
             if (i > 2) {
                NSException *exception = [NSException
                                          exceptionWithName:@"Array exceeds limit."
                                          reason:@"Popups can only have at most 3 fields! TextFieldPlaceholderArray exceeds this limit. ¯|_(ツ)_/¯ "
                                          userInfo:nil];
                @throw exception;
            }
            
            
            //通过通知监听文本框变化 为每个 TF 添加通知
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tf_valueChange:) name:UITextFieldTextDidChangeNotification object:pTextFieldArray[i]];//WJTextFieldDidDeleteBackwardNotification
            
//
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tf_deleteBackward:) name:WJTextFieldDidDeleteBackwardNotification object:nil];
            
            
            //UITextFieldTextDidEndEditingNotification
        }
        
        
        
        //设置 'TextField' 约束
        
        //1.
        if ([pTextFieldPlaceholderArray count] == 1) {
            
//            pTextFieldArray = @[tf_array[0]];
            [popupView addSubview:pTextFieldArray[0]];
            [self constraintBottomField:pTextFieldArray[0]];
    
        }
        
        //2.
        else if ([pTextFieldPlaceholderArray count] == 2) {
            
//            pTextFieldArray = @[textField1, textField2];
            [self constraintBottomField:pTextFieldArray[1]];
            [self constraintUpperField:pTextFieldArray[0] toLowerField:pTextFieldArray[1]];
        }
        
        //3.
        else if ([pTextFieldPlaceholderArray count] == 3) {

//            pTextFieldArray = @[textField1, textField2, textField3];
            [popupView addSubview:pTextFieldArray[2]];
            [self constraintBottomField:pTextFieldArray[2]];
            [self constraintUpperField:pTextFieldArray[1] toLowerField:pTextFieldArray[2]];
            [self constraintUpperField:pTextFieldArray[0] toLowerField:pTextFieldArray[1]];
            
        }
        
        
        
    }
}


//还是要输入 上去  才回调

//- (void)tf_deleteBackward:(NSNotification *)notifi{
//
//
//    for (UITextField *tf in pTextFieldArray) {
//            if ([[tf text] length]) {
//                [self.successBtn setEnabled:YES];
//                [self.successBtn setShouldShowDisabled:NO];
//            }
//    }
//}

- (void)tf_valueChange:(NSNotification *)nf {
    
    if ([[nf.object text] length]) {
        [self.successBtn setEnabled:YES];
        [self.successBtn setShouldShowDisabled:NO];
    }else {
        [self.successBtn setEnabled:NO];
        [self.successBtn setShouldShowDisabled:YES];
    }
    
    
}


//wrap
- (void)constraintBottomField:(UITextField *)bottomField {
    
    [popupView addSubview:bottomField];
    [bottomField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(pCancelTitle ? self.cancelBtn.mas_top : self.successBtn.mas_top).offset(-  pLineSpacing * 2);
        make.leading.equalTo(popupView).offset(pLRPadding);
        make.trailing.equalTo(popupView).offset(- pLRPadding);
        make.height.mas_equalTo(pTextFieldHeight);
        
    }];
    
}
//wrap
- (void)constraintUpperField:(UITextField *)upperField toLowerField:(UITextField *)lowerField {

    //先添加再约束
    [popupView addSubview:upperField];
    [popupView addSubview:lowerField];
    
    [upperField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(lowerField.mas_top).offset(- pLineSpacing);
        make.leading.equalTo(popupView).offset(pLRPadding);
        make.trailing.equalTo(popupView).offset(- pLRPadding);
        make.height.mas_equalTo(pTextFieldHeight);
        
    }];
    
    
    
}

#pragma mark -设置 button
- (void)setupButtons {

    //设置2个按钮约束
    if (pCancelTitle && pSuccessTitle) {
 
        //设置‘取消按钮’约束
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(popupView).offset(- pTBPadding);
            make.leading.equalTo(popupView).offset(pLRPadding);
            make.trailing.equalTo(self.successBtn.mas_leading).offset(- 20);
            make.height.mas_equalTo(pButtonHeight);
        }];
        
        //设置 ‘确认按钮’ 约束
        [self.successBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(popupView).offset(- pTBPadding);
            make.trailing.equalTo(popupView).offset(- pTBPadding);
            make.width.equalTo(self.cancelBtn);
            make.height.mas_equalTo(pButtonHeight);
        }];
    }
    

    //设置单个按钮约束
    if (pCancelTitle && !pSuccessTitle) {

        [self constraintSingleBtn:self.cancelBtn];

    }
    
    if (!pCancelTitle && pSuccessTitle) {

        [self constraintSingleBtn:self.successBtn];
    }
    
    
}

//wraper
- (void)constraintSingleBtn:(BButton *)btn {

    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(popupView).offset(pLRPadding);
        make.bottom.equalTo(popupView).offset(- pTBPadding);
        make.trailing.equalTo(popupView).offset(- pLRPadding);
        make.height.mas_equalTo(pButtonHeight);
        
    }];
    
 
}



#pragma mark - Presentation Methods

- (void)showPopup {
    
    if (!self.isShowing) {
         [self setIsShowing:YES];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self];
        [window makeKeyAndVisible];
        
        if( [self.delegate respondsToSelector:@selector(popupWillAppear:)] ) {
            [self.delegate popupWillAppear:self];
        }
        
        [self showAnimation];

       
    }
 
}

- (void)showAnimation {
    [UIView animateWithDuration:0.1 animations:^{
        [backgroundView setAlpha:1.0];
    }];
    
    [self configureIncomingAnimationFor: incomingTransitionType ? incomingTransitionType : PopupIncomingTransitionTypeAppearCenter];
}

#pragma mark - Dismissing Methods  --- //先执行消失  ---- 在执行endWithButtonType --->再执行blocky 的

- (void)dismissPopup:(PopupButtonType)buttonType {
    
    if (buttonType != PopupButtonSuccess && buttonType != PopupButtonCancel) {
        //For tapping and swiping to dismiss
        buttonType = PopupButtonCancel;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(popupWillDisappear:buttonType:)] ) {
        [self.delegate popupWillDisappear:self buttonType:buttonType];
    }
    
    
    
    [self configureOutgoingAnimationFor:outgoingTransitionType ? outgoingTransitionType : PopupOutgoingTransitionTypeDisappearCenter withButtonType:buttonType];
    
    
    [self setIsShowing:NO];
   
}

#pragma mark - Button Methods

- (void)pressAlertButton:(id)sender {
    
    [self dismissKeyboards]; //退出键盘

    BButton *button = (BButton *)sender;
    
    PopupButtonType buttonType;
    
    BOOL isBlock = false;
    
    if ([button isEqual:self.successBtn]) {
        NSLog(@"Success!");
        
        buttonType = PopupButtonSuccess;
        if (pSuccessBlock) isBlock = true;
    }
    else {
        NSLog(@"Cancel!");
        
        buttonType = PopupButtonCancel;
        if (pCancelBlock) isBlock = true;
    }
    
    if ([self.delegate respondsToSelector:@selector(popupPressButton:buttonType:)]) {
        [self.delegate popupPressButton:self buttonType:buttonType];
    }
    
    ///MARK: 在 dismiss  前拦截
    if (self.delegate && [pTextFieldPlaceholderArray count] > 0 && [self.delegate respondsToSelector:@selector(button:dictionary:forpopup:stringsFromTextFields:)]) {
        [self.delegate button:sender dictionary:[self createDictionaryForTextfields] forpopup:self stringsFromTextFields:[self arrayForStringOfTextfields]];
    }
    
    
    
    
        [self dismissPopup:buttonType]; //退出 popup
    
 
}





#pragma mark - UIPanGestureRecognizer Methods

- (void)panFired:(id)sender {
    //Make sure this delegate method only gets called once
    static int i = 1;
    if (i == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popupWillDisappear:buttonType:)] ) {
            [self.delegate popupWillDisappear:self buttonType:PopupButtonCancel];
            i = 0;
        }
    }
    
    UIPanGestureRecognizer *panRecog = (UIPanGestureRecognizer *)sender;
    CGPoint vel = [panRecog velocityInView:popupView];
    
    UIView *recogView = [panRecog view];
    
    CGPoint translation = [panRecog translationInView:popupView];
    CGFloat curY = popupView.frame.origin.y;
    
    [self endEditing:YES];
    
    if (panRecog.state == UIGestureRecognizerStateChanged) {
        //drag view vertially
        CGRect frame = popupView.frame;
        frame.origin.y = curY + translation.y;
        recogView.frame = frame;
        [panRecog setTranslation:CGPointMake(0.0f, 0.0f) inView:popupView];
    }
    else if (panRecog.state == UIGestureRecognizerStateEnded) {
        
        CGFloat finalX = popupView.frame.origin.x;
        CGFloat finalY = 50.0f;
        CGFloat curY = popupView.frame.origin.y;
        
        CGFloat distance = curY - finalY;
        
        //Normalize velocity
        //Multiply by -1 in this case since final desitination y < curY
        //and recog's y velocity is negative when draggin up
        //(therefore also works when released when dragging down)
        CGFloat springVelocity = -1.0f * vel.y / distance;
        
        //If the springVelocity is really slow, speed it up a bit
        if (springVelocity > 1.5f) {
            springVelocity = -1.5f;
        }
        
        [UIView animateWithDuration:springVelocity delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            CGRect frame = popupView.frame;
            frame.origin.x = finalX;
            frame.origin.y = finalY;
            popupView.frame = frame;
            
            [backgroundView setAlpha:0.0];
            if (curY > 115.1) {
                [UIView animateWithDuration:0.1 animations:^{
                    popupView.frame = CGRectMake(30, 600, popupDimensionWidth, self.popupDimensionHeight);
                } completion:^(BOOL finished) {
                    popupView.alpha = 0.0;
                }];
            }
            else {
                [UIView animateWithDuration:0.1 animations:^{
                    popupView.frame = CGRectMake(30, -400, popupDimensionWidth, self.popupDimensionHeight);
                } completion:^(BOOL finished) {
                    popupView.alpha = 0.0;
                }];
            }
            
        } completion:^(BOOL finished) {
            [self endWithButtonType:PopupButtonCancel];
        }];
 
    }
}

#pragma mark - Textfield Getter Methods

- (NSMutableDictionary *)createDictionaryForTextfields {
    
    static NSMutableDictionary *dictionary = nil;
    
    if (!dictionary) dictionary = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [pTextFieldArray count]; i++) {
        if (i == 0) {
            UITextField *textField1 = pTextFieldArray[i];
            
            [dictionary setObject:textField1.text forKey:pTextFieldPlaceholderArray[i]];
        }
        else if (i == 1) {
            UITextField *textField2 = pTextFieldArray[i];
            
            [dictionary setObject:textField2.text forKey:pTextFieldPlaceholderArray[i]];
        }
        else if (i == 2) {
            UITextField *textField3 = pTextFieldArray[i];
            
            [dictionary setObject:textField3.text forKey:pTextFieldPlaceholderArray[i]];
        }
    }
    
    return dictionary;
}

- (NSArray *)arrayForStringOfTextfields {
    
    NSString *textField1String = @"";
    NSString *textField2String = @"";
    NSString *textField3String = @"";
    
    
    for (int i = 0; i < [pTextFieldArray count]; i++) {
        if (i == 0) {
            UITextField *textField1 = pTextFieldArray[i];
            textField1String = textField1.text;
        }
        else if (i == 1) {
            UITextField *textField2 = pTextFieldArray[i];
            textField2String = textField2.text;
        }
        else if (i == 2) {
            UITextField *textField3 = pTextFieldArray[i];
            textField3String = textField3.text;
        }
        else {
            NSException *exception = [NSException
                                      exceptionWithName:@"Array exceeds limit."
                                      reason:@"Popups can only have at most 3 fields, TextFieldArray exceeds this limit."
                                      userInfo:nil];
            
            @throw exception;
        }
    }
    
    if ([pTextFieldPlaceholderArray count] == 1) {
        return @[textField1String];
    }
    else if ([pTextFieldPlaceholderArray count] == 2) {
        return @[textField1String, textField2String];
    }
    else if ([pTextFieldPlaceholderArray count] == 3) {
        return @[textField1String, textField2String, textField3String];
    }
    else return nil;
    
}

#pragma mark - UITextField Methods

- (void)setTextFieldTypeForTextFields:(NSArray *)textFieldTypeArray {
    
    NSArray *canBeArray = @[@"",
                            @"DEFAULT",
                            @"PASSWORD"];
    
    int counter = 0;

    for (NSString *type in textFieldTypeArray) {
        if ([type isKindOfClass:[NSString class]]) {
            if ([canBeArray containsObject:type]) {
                if ([type isEqualToString:@"PASSWORD"]) {
                    if (counter < 3) {
                        
                        UITextField *field = pTextFieldArray[counter];
                        [field setSecureTextEntry:YES];
                    
                    }
                    else {
                        NSException *exception = [NSException
                                                  exceptionWithName:@"Array exceeds limit."
                                                  reason:@"Popups can only have at most 3 fields, TextFieldTypeArray exceeds this limit."
                                                  userInfo:nil];
                        
                        @throw exception;
                    }
                }
            }
            else {
                NSString *canBeString = [canBeArray componentsJoinedByString:@", "];
                
                NSException *exception = [NSException
                                          exceptionWithName:@"Not a valid textfield type."
                                          reason:[NSString stringWithFormat:@"TextField type needs to be of type NSString and either: %@", canBeString]
                                          userInfo:nil];
                @throw exception;
            }
        }
        else {
            NSException *exception = [NSException
                                      exceptionWithName:@"Not a valid textfield class type."
                                      reason:@"TextField type needs to be of type NSString."
                                      userInfo:nil];
            @throw exception;
        }
        
        counter ++;
    }
}

- (void)setTextFieldTextForTextFields:(NSArray *)textFieldTextArray {
        
    for (int i = 0; i < [pTextFieldArray count]; i++) {
        
        if (i < 3) {
            UITextField *field = [pTextFieldArray objectAtIndex:i];
            NSString *textToFill = [textFieldTextArray objectAtIndex:i];
            
            if (field && textToFill) {
                if ([field isKindOfClass:[UITextField class]]) {
                    if ([textToFill isKindOfClass:[NSString class]]) {
                        [field setText:textToFill];
                    }
                    else {
                        NSException *exception = [NSException
                                                  exceptionWithName:@"Not valid textfield text."
                                                  reason:@"TextField text needs to be of type NSString."
                                                  userInfo:nil];
                        @throw exception;
                    }
                }
            }
            
        }
        else {
            NSException *exception = [NSException
                                      exceptionWithName:@"Array exceeds limit."
                                      reason:@"Popups can only have at most 3 fields, TextFieldTypeArray exceeds this limit."
                                      userInfo:nil];
            
            @throw exception;
        }
    }
    
}

- (void)setKeyboardTypeForTextFields:(NSArray *)keyboardTypeArray {
    
    NSArray *canBeArray = @[@"",
                            @"DEFAULT",
                            @"ASCIICAPABLE",
                            @"NUMBERSANDPUNCTUATION",
                            @"URL",
                            @"NUMBER",
                            @"PHONE",
                            @"NAMEPHONE",
                            @"EMAIL",
                            @"DECIMAL",
                            @"TWITTER",
                            @"WEBSEARCH"];
    
    int counter = 0;

    for (NSString *type in keyboardTypeArray) {
        if ([type isKindOfClass:[NSString class]]) {
            if ([canBeArray containsObject:type]) {
                if (counter < 3) {
                    UITextField *field = pTextFieldArray[counter];
                    [field setKeyboardType:[self getKeyboardTypeFromString:type]];
                }
                else {
                    NSException *exception = [NSException
                                              exceptionWithName:@"Array exceeds limit."
                                              reason:@"Popups can only have at most 3 fields, KeyboardTypeArray exceeds this limit."
                                              userInfo:nil];
                
                    @throw exception;
                }
            }
            else {
                NSString *canBeString = [canBeArray componentsJoinedByString:@", "];

                NSException *exception = [NSException
                                            exceptionWithName:@"Not a valid textfield type."
                                            reason:[NSString stringWithFormat:@"Keyboard type needs to be of type NSString and either: %@", canBeString]
                                            userInfo:nil];
                @throw exception;
            }
        }
        else {
            NSException *exception = [NSException
                                        exceptionWithName:@"Not a valid textfield class type."
                                        reason:@"Keyboard type needs to be of type NSString."
                                        userInfo:nil];
            @throw exception;
        }
        counter ++;
    }
}

- (UIKeyboardType)getKeyboardTypeFromString:(NSString *)string {
    
    UIKeyboardType keyboardType;

    if ([string isEqualToString:@""]) {
        keyboardType = UIKeyboardTypeDefault;
    }
    else if ([string isEqualToString:@"DEFAULT"]) {
        keyboardType = UIKeyboardTypeDefault;
    }
    else if ([string isEqualToString:@"ASCIICAPABLE"]) {
        keyboardType = UIKeyboardTypeASCIICapable;
    }
    else if ([string isEqualToString:@"NUMBERSANDPUNCTUATION"]) {
        keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    else if ([string isEqualToString:@"URL"]) {
        keyboardType = UIKeyboardTypeURL;
    }
    else if ([string isEqualToString:@"NUMBER"]) {
        keyboardType = UIKeyboardTypeNumberPad;
    }
    else if ([string isEqualToString:@"PHONE"]) {
        keyboardType = UIKeyboardTypePhonePad;
    }
    else if ([string isEqualToString:@"NAMEPHONE"]) {
        keyboardType = UIKeyboardTypeNamePhonePad;
    }
    else if ([string isEqualToString:@"EMAIL"]) {
        keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if ([string isEqualToString:@"DECIMAL"]) {
        keyboardType = UIKeyboardTypeDecimalPad;
    }
    else if ([string isEqualToString:@"TWITTER"]) {
        keyboardType = UIKeyboardTypeTwitter;
    }
    else if ([string isEqualToString:@"WEBSEARCH"]) {
        keyboardType = UIKeyboardTypeWebSearch;
    }
    else {
        keyboardType = UIKeyboardTypeDefault;
    }
    
    return keyboardType;
}


///MARK: 创建 TF
- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholderText numberOfField:(int)num {
    
    UITextField *textField;
    textField = [[UITextField alloc] init];
    [textField setKeyboardType:UIKeyboardTypeDefault];
    [textField setBorderStyle:UITextBorderStyleNone];
    [textField setDelegate:self];
    

    [textField setAdjustsFontSizeToFitWidth:YES];
    
    //IM2
    [textField setFont:[UIFont fontWithName:@"HelveticaNeue" size:kTextFieldHolderSize]];
    [textField setTextColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
    [textField setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [textField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [textField setTag:num];
    [textField setPlaceholder:placeholderText];
    [textField.layer setBorderColor:[UIColor colorWithWhite:0.8 alpha:1.0].CGColor];
    [textField.layer setBorderWidth:1.0];
    [textField.layer setCornerRadius:4.0];
    [textField.layer setMasksToBounds:YES];
    
    if (num == [pTextFieldPlaceholderArray count]) {
        [textField setReturnKeyType:UIReturnKeyDone];
    }
    else {
        [textField setReturnKeyType:UIReturnKeyNext];
    }
    
    //???
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [textField setLeftView:paddingView];
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    
    return textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField tag] == [pTextFieldPlaceholderArray count]) {
        [self dismissKeyboards];
    }
    else {
        UITextField *fieldAddOne = (UITextField *)[self viewWithTag:[textField tag]+1];
        
        if ([textField tag] == 1) {
            [textField resignFirstResponder];
            [fieldAddOne becomeFirstResponder];
        }
        else if ([textField tag] == 2) {
            [textField resignFirstResponder];
            [fieldAddOne becomeFirstResponder];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self setPopupFrameForTextField:(int)[textField tag]];
    return YES;
}

- (void)setPopupFrameForTextField:(int)num {
    
    currentKeyboardHeight = 216;
    int subtractor = 0;

    //Integrate for iPhone 4, 5, 6, 6+ screen sizes
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        //If is iPhone4
        subtractor = 70;
    }
    else if ([UIScreen mainScreen].bounds.size.height == 568) {
        //If is iPhone5
        subtractor = 30;
    }
    else if ([UIScreen mainScreen].bounds.size.height > 568) {
        //If is iPhone6, 6+
        subtractor = 0; //Redunant but specific
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), mainScreen.bounds.size.height/2 - currentKeyboardHeight - subtractor, popupDimensionWidth, self.popupDimensionHeight)];
    }];
}

- (void)dismissKeyboards {
    //Dismiss all and any keyboards
    [self endEditing:YES];
    
    //Reset the frame of Popup
    [UIView animateWithDuration:0.2 animations:^{
        [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), mainScreen.bounds.size.height/2 - (self.popupDimensionHeight/2), popupDimensionWidth, self.popupDimensionHeight)];
    }];
}

#pragma mark - Keyboard Methods

- (void)setKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    currentKeyboardHeight = kbSize.height;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Transition Methods

- (void)configureIncomingAnimationFor:(PopupIncomingTransitionType)trannyType {

    CGRect mainRect = CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), mainScreen.bounds.size.height/2 - (self.popupDimensionHeight/2), popupDimensionWidth, self.popupDimensionHeight);
    
    switch (trannyType) {
        case PopupIncomingTransitionTypeBounceFromCenter: {

            popupView.transform = CGAffineTransformMakeScale(0.4, 0.4);

            [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
                popupView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeSlideFromLeft: {
            
            [popupView setFrame:CGRectMake(-popupDimensionWidth, mainScreen.bounds.size.height/2 - (self.popupDimensionHeight/2), popupDimensionWidth, self.popupDimensionHeight)];
            
            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:mainRect];

            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeSlideFromTop: {
            
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), -self.popupDimensionHeight, popupDimensionWidth, self.popupDimensionHeight)];
            
            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:mainRect];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeSlideFromBottom: {
            
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), mainScreen.bounds.size.height+self.popupDimensionHeight, popupDimensionWidth, self.popupDimensionHeight)];
            
            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:mainRect];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeSlideFromRight: {
            
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width + popupDimensionWidth, mainScreen.bounds.size.height/2 - (self.popupDimensionHeight/2), popupDimensionWidth, self.popupDimensionHeight)];
            
            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:mainRect];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeEaseFromCenter: {
            
            [popupView setAlpha:0.0];
            popupView.transform = CGAffineTransformMakeScale(0.75, 0.75);
            
            [UIView animateWithDuration:0.25 animations:^{
                popupView.transform = CGAffineTransformIdentity;
                [popupView setAlpha:1.0];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeAppearCenter: {
            
            [popupView setAlpha:0.0];
            
            [UIView animateWithDuration:0.05 animations:^{
                [popupView setAlpha:1.0];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeFallWithGravity: {
            
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), -self.popupDimensionHeight, popupDimensionWidth, self.popupDimensionHeight)];
            
            [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{
                [popupView setFrame:mainRect];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
    
            break;
        }
        case PopupIncomingTransitionTypeGhostAppear: {
            
            [popupView setAlpha:0.0];
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^ {
                [popupView setAlpha:1.0];

            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeShrinkAppear: {

            [popupView setAlpha:0.0];
            popupView.transform = CGAffineTransformMakeScale(1.25, 1.25);
            
            [UIView animateWithDuration:0.25 animations:^{
                popupView.transform = CGAffineTransformIdentity;
                [popupView setAlpha:1.0];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        default: {
            break;
        }
    }

}

- (void)configureOutgoingAnimationFor:(PopupOutgoingTransitionType)trannyType withButtonType:(PopupButtonType)buttonType {
    
    //Make the blur/background fade away
    [UIView animateWithDuration:0.175 animations:^{
        [backgroundView setAlpha:0.0];
    }];

    switch (trannyType) {
        case PopupOutgoingTransitionTypeBounceFromCenter: {

            [UIView animateWithDuration:0.1 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
                popupView.transform = CGAffineTransformMakeScale(1.15, 1.15);
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    
                    popupView.transform = CGAffineTransformMakeScale(0.75, 0.75);
                    
                } completion:^(BOOL finished) {
                    [self endWithButtonType:buttonType];
                }];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeSlideToLeft: {
            
            CGRect rect = CGRectMake(-popupDimensionWidth, mainScreen.bounds.size.height/2 - (self.popupDimensionHeight/2), popupDimensionWidth, self.popupDimensionHeight);

            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:rect];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeSlideToTop: {

            CGRect rect = CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), -self.popupDimensionHeight, popupDimensionWidth, self.popupDimensionHeight);

            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:rect];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];

            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeSlideToBottom: {

            CGRect rect = CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), mainScreen.bounds.size.height + self.popupDimensionHeight, popupDimensionWidth, self.popupDimensionHeight);

            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:rect];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];

            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeSlideToRight: {

            CGRect rect = CGRectMake(mainScreen.bounds.size.width + popupDimensionWidth, mainScreen.bounds.size.height/2 - (self.popupDimensionHeight/2), popupDimensionWidth, self.popupDimensionHeight);

            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:rect];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeEaseToCenter: {
            
            [UIView animateWithDuration:0.2 animations:^{
                popupView.transform = CGAffineTransformMakeScale(0.75, 0.75);
                [popupView setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeDisappearCenter: {
            
            [UIView animateWithDuration:0.25 animations:^{
                popupView.transform = CGAffineTransformMakeScale(0.65, 0.65);
                [popupView setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeFallWithGravity: {
            
            CGRect initialRect = CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), mainScreen.bounds.size.height/2 - (self.popupDimensionHeight/2), popupDimensionWidth, self.popupDimensionHeight);
            CGRect endingRect = CGRectMake(mainScreen.bounds.size.width/2 - (popupDimensionWidth/2), mainScreen.bounds.size.height + self.popupDimensionHeight, popupDimensionWidth, self.popupDimensionHeight);

            [UIView animateWithDuration:0.1 delay:0.0 usingSpringWithDamping:0.24 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{
                [popupView setFrame:initialRect];

            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.35 animations:^{
                    [popupView setFrame:endingRect];

                } completion:^(BOOL finished) {
                    [self endWithButtonType:buttonType];
                }];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeGhostDisappear: {
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                [popupView setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeGrowDisappear: {
            
            [UIView animateWithDuration:0.25 animations:^{
                popupView.transform = CGAffineTransformMakeScale(1.25, 1.25);
                [popupView setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        default: {
            break;
        }
    }
    
}
///MARK:执行 DISMISS
- (void)endWithButtonType:(PopupButtonType)buttonType {

    blocky blockster;
    
    if (buttonType == PopupTypeSuccess) {
        pSuccessBlock ? blockster = pSuccessBlock: nil;
    }
    else {
        pCancelBlock ? blockster = pCancelBlock: nil;
    }
    
    [self removeFromSuperview];
    
    if (blockster) blockster();
    else if (self.delegate && [self.delegate respondsToSelector:@selector(popupDidDisappear:buttonType:)]) {
        [self.delegate popupDidDisappear:self buttonType:buttonType];
    }
}

@end
