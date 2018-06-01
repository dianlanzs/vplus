//
//  LoginView.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "LoginView.h"
#import "UITextField+TF_FloatUp.h"
//#import "HyTransitions.h"

#import "UIButton+Login.h"
@interface LoginView()

@property (nonatomic, strong) UIImageView *imv_logo;

//账号 密码
@property (nonatomic, strong) UITextField *tf_account;
@property (nonatomic, strong) UITextField *tf_pwd;

//登录 按钮
@property (nonatomic, strong) UIButton *btn_login;
@property (nonatomic, strong) UIButton *btn_register;




@property (nonatomic, strong) UILabel *signUp;

@end




@implementation LoginView






#pragma mark - Required!


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];

    if (self) {
        
        [self addSubview:self.imv_logo];
        [self addSubview:self.tf_account];
        [self addSubview:self.tf_pwd];
        [self addSubview:self.btn_login];
        [self addSubview:self.signUp];
//        [self addSubview:self.btn_register];
        
        [self setConstraints];
        
        
    }
    
    return self;
}

- (void)setConstraints {
    
    
    
    [self.imv_logo mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self).offset(20.f);
        make.centerX.equalTo(self).offset(0.f);

        make.size.mas_equalTo(CGSizeMake(AM_SCREEN_WIDTH * 0.62, AM_SCREEN_WIDTH * 2 / 3));
        
    }];
    
    
    [self.tf_account mas_makeConstraints:^(MASConstraintMaker *make) {
        //屏幕中间
        make.top.equalTo(self.imv_logo.mas_bottom).offset( 10.f);
        make.centerX.equalTo(self).offset(0.f);
        make.width.mas_equalTo(AM_SCREEN_WIDTH - 30.f);
        make.height.mas_equalTo(65.f);
    }];
    
    
    [self.tf_pwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tf_account.mas_bottom).offset(3.f);
        make.leading.equalTo(self.tf_account);
        make.trailing.equalTo(self.tf_account);
        make.height.mas_equalTo(65.f);

    }];
    
    [self.signUp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15.f);
        make.trailing.equalTo(self).offset(-15.f);
        make.bottom.equalTo(self).offset(-20.f);
    }];

    
    
//    [self.btn_login mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.top.equalTo(self.tf_pwd.mas_bottom).offset(40.f);
//        make.centerX.equalTo(self.tf_pwd);
//        make.width.mas_equalTo(AM_SCREEN_WIDTH - 80.f);
//        make.height.mas_equalTo(40);
//
//    }];
    

//    [self.btn_register mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.btn_login.mas_bottom).offset(20.f);
//        make.centerX.equalTo(self.btn_login);
//        make.size.mas_equalTo(self.btn_login);
//    }];
    
    
    
}



- (UILabel *)signUp {
    
    
    if (!_signUp) {
        _signUp = [UILabel labelWithText:@"没有账号？ 立即注册" withFont:[UIFont systemFontOfSize:14.f]
                                   color:[UIColor lightGrayColor] aligment:NSTextAlignmentCenter];
    }
    
    return _signUp;
}

- (UIImageView *)imv_logo {
    
    if (!_imv_logo) {
        _imv_logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arlo"]];
        _imv_logo.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imv_logo;
}


- (UITextField *)tf_account {
    
    if (!_tf_account) {
    
        
        NSMutableAttributedString *account_s = [[NSMutableAttributedString alloc] initWithString:@"\U0000e702 邮箱:"];
        _tf_account = [UITextField textFiedWithText:account_s];
        
    }
    
    
    return _tf_account;
}

- (UITextField *)tf_pwd {
    
    if (!_tf_pwd) {
        
        
        NSMutableAttributedString *pwd_s = [[NSMutableAttributedString alloc] initWithString:@"\U0000e627密码:" ];
        _tf_pwd = [UITextField textFiedWithText:pwd_s iconSize:20.f];
        _tf_pwd.secureTextEntry = YES;
        _tf_pwd.returnKeyType = UIReturnKeyDone;

    }
    
    
    return _tf_pwd;
}

- (UIButton *)btn_login {
    
    if (!_btn_login) {
        
//        _btn_login = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypePrimary];
        
//       _btn_login = [[HyLoginButton alloc] initWithFrame:CGRectZero];
       _btn_login =  [[HyLoginButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40)];
       [_btn_login setBackgroundColor:[UIColor colorWithHex:@"0066ff"]];
//        _btn_login.enabled = NO;
        [_btn_login setTitle:@"登录" forState:UIControlStateNormal];//UIControlStateSelected
        [_btn_login addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
 
    return _btn_login;
}

- (UIButton *)btn_register {
    
    if (!_btn_register) {
        
        _btn_register = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeInverse];
        [_btn_register setTitle:@"没有账号？立即注册" forState:UIControlStateNormal];//UIControlStateSelected

    }
    return _btn_register;
}

- (void)loginClick:(UIButton *)sender {
    
    [sender loginWithFirstField:self.tf_account secondField:self.tf_pwd s:^{
        // 注册 controller present 操作
        self.notify(self.btn_login,YES);
    } f:^{
        self.notify(self.btn_login,NO);

    }];
    
}
@end
