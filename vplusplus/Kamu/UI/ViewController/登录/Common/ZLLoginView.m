//
//  ZLLoginView.m
//  Kamu
//
//  Created by YGTech on 2018/7/17.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "ZLLoginView.h"
#import "NSDictionary+JSON.h"
#import "NSDictionary+Extension.h"
#import "KMReqest.h"


@implementation ZLLoginView

- (void)setLoginType:(ZLLoginType)loginType {
    
    _loginType = loginType;
    [self addSubview:_dismissBtn];
    [self addSubview:self.welcomLb ];
    [self addSubview:self.portraitBtn];
    [self addSubview:self.tf_account];
    [self addSubview:self.tf_pwd];
    [self addSubview:self.loginBtn];
    [self addSubview:self.signUp];
    [self addSubview:self.otherAccount];
    
    if (loginType == ZLLoginType_register || loginType == ZLLoginType_otherAccount ) {
        
        [self.dismissBtn setHidden:NO];
        [self.portraitBtn setHidden:YES];
        [self.signUp setHidden:YES];
        [self.otherAccount setHidden:YES];
        [self.tf_account setEnabled:YES];
        
        if (loginType == ZLLoginType_register) {
            [self.welcomLb setHidden:NO];
            [self.loginBtn setTitle: @"注册账户" forState:UIControlStateNormal];
            
            [self.welcomLb  mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self).offset(15.f);
                make.trailing.equalTo(self).offset(-15.f);
                make.top.equalTo(self).offset(70.f);
            }];
            [self.tf_account mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.welcomLb ).offset(70.f);
                make.leading.equalTo(self).offset(15.f);
                make.trailing.equalTo(self).offset(-15.f);
                make.height.mas_equalTo(40.f);
            }];
        }else if (loginType == ZLLoginType_otherAccount) {
            [self.welcomLb  setHidden:YES];
            [self.loginBtn setTitle: @"登录" forState:UIControlStateNormal];
            [self.tf_account mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(100.f);
                make.leading.equalTo(self).offset(15.f);
                make.trailing.equalTo(self).offset(-15.f);
                make.height.mas_equalTo(40.f);
            }];
            
        }
        ///enable & clear  tf cache
        [self.tf_account setBorderStyle:UITextBorderStyleRoundedRect];
        [self.tf_account setKeyboardType:UIKeyboardTypeEmailAddress];
        [self.tf_account setText:nil];
        [self.tf_pwd setText:nil];

        
    }else if (loginType == ZLLoginType_prior) {
        [self.dismissBtn setHidden:YES];  ///label . & dismissBtn not belong to loginview , so can't hidden / remove
        [self.welcomLb setHidden:YES];
        [self.portraitBtn setHidden:NO];
        [self.signUp setHidden:NO];
        [self.otherAccount setHidden:NO];
        [self.loginBtn setTitle: @"登录" forState:UIControlStateNormal];
        
        [self.portraitBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(60.f);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(100, 100));
        }];
        
        [self.tf_account mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.portraitBtn.mas_bottom).offset(40.f);
            make.leading.equalTo(self).offset(15.f);
            make.trailing.equalTo(self).offset(-15.f);
            make.height.mas_equalTo(40.f);
        }];
        [self.signUp mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginBtn.mas_bottom).offset(10.f);
            make.leading.equalTo(self).offset(20.f);
        }];
        [self.otherAccount mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginBtn.mas_bottom).offset(10.f);
            make.trailing.equalTo(self).offset(-20.f);
        }];
        
        if (USER.user_email.length) {
            ///disable tf_account
            [self.tf_account setEnabled:NO];
            [self.tf_account setBorderStyle:UITextBorderStyleNone];
            [self.tf_account setText: USER.user_email];
            [self.portraitBtn setImage:[UIImage imageWithData:USER.user_portrait] forState:UIControlStateNormal];
        }
    }
    
    [self.tf_pwd mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tf_account.mas_bottom).offset(20.f);
        make.leading.equalTo(self.tf_account);
        make.trailing.equalTo(self.tf_account);
        make.height.mas_equalTo(40.f);
    }];
    
    [self.loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tf_pwd.mas_bottom).offset(40.f);
        make.centerX.equalTo(self.tf_pwd);
        make.width.mas_equalTo(AM_SCREEN_WIDTH - 80.f);
        make.height.mas_equalTo(40);
    }];
    
    ///验证相同元素 是否被重复添加 ,TURN OUT : 不会重复添加！！！
    NSLog(@"%zd",self.subviews.count);
    
}

- (UIButton *)dismissBtn {
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissBtn setFrame:CGRectMake(15, 20, 40, 40)];
        [_dismissBtn setImage:[UIImage imageNamed:@"nav_close"] forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _dismissBtn;
}
- (UILabel *)welcomLb {
    if (!_welcomLb) {
        _welcomLb = [UILabel labelWithText:@"注册 KAMU 账户" withFont:[UIFont boldSystemFontOfSize:21.f] color:[UIColor blackColor] aligment:NSTextAlignmentCenter];
    }
    return _welcomLb;
}
- (UIButton *)otherAccount {
    if (!_otherAccount) {
        _otherAccount = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherAccount setTitle:@"other account Login" forState:UIControlStateNormal];
        [_otherAccount.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_otherAccount setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_otherAccount.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_otherAccount addTarget:self action:@selector(otherAccountLogin:) forControlEvents:UIControlEventTouchUpInside];
        [_otherAccount sizeToFit];
    }
    return _otherAccount;
}
- (UIButton *)signUp {
    
    
    if (!_signUp) {
        _signUp = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUp setTitle:@"register account" forState:UIControlStateNormal];
        [_signUp.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_signUp setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_signUp.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_signUp addTarget:self action:@selector(registerAccount:) forControlEvents:UIControlEventTouchUpInside];
        [_signUp sizeToFit];
    }
    
    return _signUp;
}
- (void)registerAccount:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(action:actionType:)]) {
        [self.delegate action:sender actionType:ZLLoginType_register];
    }
}
- (void)otherAccountLogin:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(action:actionType:)]) {
        [self.delegate action:sender actionType:ZLLoginType_otherAccount];
    }
}
- (void)dismiss:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(action:actionType:)]) {
        [self.delegate action:sender actionType:ZLLoginType_dismiss];
    }
}

/// LoginView 里 touches began 键盘回收
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for(UIView *view in self.superview.subviews){
        [view resignFirstResponder];
    }
}


- (UIButton *)portraitBtn {
    
    if (!_portraitBtn) {
        _portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_portraitBtn setContentMode:UIViewContentModeScaleAspectFill];
        [_portraitBtn setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
        [_portraitBtn.layer setBorderColor:[UIColor groupTableViewBackgroundColor].CGColor];
        [_portraitBtn.layer setBorderWidth:1.f];
        [_portraitBtn.layer setCornerRadius:50.f];
        [_portraitBtn.layer setMasksToBounds:YES];
        [_portraitBtn setBackgroundColor:[UIColor lightTextColor]];
    }
    return _portraitBtn;
}

- (UITextField *)tf_account {
    if (!_tf_account) {
        NSMutableAttributedString *pwd_s = [[NSMutableAttributedString alloc] initWithString:@"邮箱:"];
        _tf_account = [[ZLTextField alloc] init];
        
        [_tf_account setPlaceholder:[pwd_s string]];
        [_tf_account setBorderStyle:UITextBorderStyleRoundedRect];
        [_tf_account setKeyboardType:UIKeyboardTypeEmailAddress];
        _tf_account.returnKeyType = UIReturnKeyDone;
        
        WeakObj(self);
        [_tf_account setFilledNotify:^(BOOL flag) {
            if (flag == YES) {
                [ws.loginBtn setEnabled:YES];
                [ws.loginBtn setAlpha:1.f];
            }else {
                [ws.loginBtn setEnabled:NO];
                [ws.loginBtn setAlpha:0.4f];
            }
        }];
    }
    return _tf_account;
}

- (ZLTextField *)tf_pwd {
    
    if (!_tf_pwd) {
        NSMutableAttributedString *pwd_s = [[NSMutableAttributedString alloc] initWithString:@"密码:" ];
        _tf_pwd = [[ZLTextField alloc] init];
        
        [_tf_pwd setPlaceholder:[pwd_s string]];
        [_tf_pwd setBorderStyle:UITextBorderStyleRoundedRect];
        [_tf_pwd setKeyboardType:UIKeyboardTypeDefault];
        
        
        _tf_pwd.secureTextEntry = YES;
        _tf_pwd.returnKeyType = UIReturnKeyDone;
        
        WeakObj(self);
        [_tf_pwd setFilledNotify:^(BOOL flag) {
            if (flag == YES) {
                [ws.loginBtn setEnabled:YES];
                [ws.loginBtn setAlpha:1.f];
            }else {
                [ws.loginBtn setEnabled:NO];
                [ws.loginBtn setAlpha:0.4f];
            }
        }];
    }
    return _tf_pwd;
}

- (HyLoginButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn =  [[HyLoginButton alloc] initWithHeight:40.f];
        [_loginBtn setBackgroundColor:[UIColor colorWithHex:@"0066ff"]];
        [_loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginBtn setEnabled:NO];
        [_loginBtn setAlpha:0.4f];
    }
    
    
    return _loginBtn;
}
- (void)loginAction:(HyLoginButton *)sender {
    [self.tf_pwd endEditing:YES];
    [self.tf_account endEditing:YES];
    [self loginWithFirstText:self.tf_account.text secondText:self.tf_pwd.text finished:^(User *user,NSString *errorMsg, NSError *errorFlag) {
        
        
        if (!errorMsg && user.user_id) {

            [self.loginBtn succeedAnimationWithCompletion:^{
                
                self.userLogin(user);

                if (self.loginType == ZLLoginType_register) {
                    [MBProgressHUD showSuccess:@"注册成功 "];
                }else if (self.loginType == ZLLoginType_prior || self.loginType == ZLLoginType_otherAccount) {
                    [MBProgressHUD showSuccess:@"登录成功 "];
                }
            }];
      
            
            
        }else if (errorMsg) {
            [MBProgressHUD showError:errorMsg];
            [self.loginBtn failedAnimationWithCompletion:nil];
        }
        
        
    } type:self.loginType];
}

- (void)loginWithFirstText:(NSString *)account secondText:(NSString *)pwd finished:(loginFinshed)finished type:(ZLLoginType)type {
    if ([self isValidateEmail:account]) {
        [self.loginBtn scaleAnimation];
        
        KMReqest *kmReq = [[KMReqest alloc] init];
        kmReq.finished = ^(id responseObject, NSError *error) {
            if (!error) {
                NSDictionary *dict = [NSDictionary dictionaryWithJSONData:responseObject];
                NSNumber *user_id = [dict numberValueForKey:@"id"];
                NSString *errorMsg = [[dict arrayValueForKey:@"loginMessage"] objectAtIndex:0];
                User *db_user = [[User objectsWhere:[NSString stringWithFormat:@"user_id = %@",user_id]] firstObject];
                
                if (!errorMsg) {
                    if (!db_user) {
                        
                        ///create & add a new user
                        User *aUser = [User new];
                        aUser.user_id = user_id;
                        aUser.user_email = account;
                        aUser.user_pwd = pwd;
                        aUser.user_isLogin = YES;
                        aUser.user_devices = [dict arrayValueForKey:@"ipc"];
                        
                        
                        
                        aUser.user_portrait = UIImageJPEGRepresentation([UIImage imageNamed:@"portrait"], 1.0);
                        [RLM transactionWithBlock:^{
                            [RLM addObject:aUser];
                        }];
                        
                        finished(aUser,errorMsg,nil);
                    }else {
                        ///update user devices other infos
                        [RLM transactionWithBlock:^{
                            db_user.user_isLogin = YES;
                            db_user.user_devices = [dict arrayValueForKey:@"ipc"];
                        }];
                        finished(db_user,errorMsg,nil);
                    }
                }else {
                    finished(nil,errorMsg,error);
                }
                
            }
            
        };
        
        [kmReq setMethod:POST];
        
        [kmReq configURLPrams:@{@"email":account,
                                @"password":pwd,
                                }];
        if (type == ZLLoginType_register) {
            [kmReq requestData:KM_API_URL(@"signup")];
        }else if (type == ZLLoginType_otherAccount ||type == ZLLoginType_prior ){
            [kmReq requestData:KM_API_URL(@"login")];
        }
        
    }else {
        [MBProgressHUD showPromptWithText:@"邮箱格式不正确"];
    }
    
}

//利用正则表达式验证
-(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *regexMatchEmail = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexMatchEmail];
    return [predicate evaluateWithObject:email];
}
@end
