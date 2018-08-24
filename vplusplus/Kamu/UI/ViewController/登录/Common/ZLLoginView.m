//
//  ZLLoginView.m
//  Kamu
//
//  Created by YGTech on 2018/7/17.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "ZLLoginView.h"
#import "KMReqest.h"



@implementation ZLLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.dismissBtn];
        [self addSubview:self.welcomLb ];
        [self addSubview:self.portraitBtn];
        [self addSubview:self.tf_account];
        
        [self addSubview:self.lb_lan];
        [self addSubview:self.switch_btn];
        
        [self addSubview:self.tf_pwd];
        //    [self addSubview:self.loginBtn];
        [self addSubview:self.signUp];
        //    [self addSubview:self.otherAccount];
        [self addSubview:self.loginBtn];
    }
    
    return self;
}

- (void)setLoginType:(ZLLoginType)loginType {
    
    _loginType = loginType;
   
    if (loginType == ZLLoginType_register ) {  // || loginType == ZLLoginType_otherAccount
        
        [self.dismissBtn setHidden:NO];
        [self.portraitBtn setHidden:YES];
        [self.lb_lan setHidden:YES];
        [self.switch_btn setHidden:YES];
        [self.signUp setHidden:YES];
//        [self.otherAccount setHidden:YES];
        [self.tf_account setEnabled:YES];
        [self.welcomLb setHidden:NO];
        [self.loginBtn setTitle: LS(@"注册账户") forState:UIControlStateNormal];
        
        
        
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
        /*
        else if (loginType == ZLLoginType_otherAccount) {
            [self.welcomLb  setHidden:YES];
            [self.loginBtn setTitle: @"登录" forState:UIControlStateNormal];
            [self.tf_account mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(100.f);
                make.leading.equalTo(self).offset(15.f);
                make.trailing.equalTo(self).offset(-15.f);
                make.height.mas_equalTo(40.f);
            }];
            
        }
         */
        ///enable & clear  tf cache
//        [self.tf_account setBorderStyle:UITextBorderStyleRoundedRect];
//        [self.tf_account setKeyboardType:UIKeyboardTypeEmailAddress];
//        [self.tf_account setLeftViewMode:UITextFieldViewModeAlways];
//        self.tf_account.textAlignment = NSTextAlignmentLeft;
//        [self.tf_account setFont:[UIFont systemFontOfSize:15.f]];
        [self.tf_account setText:nil];
        [self.tf_pwd setText:nil];

        
    }else if (loginType == ZLLoginType_prior) {
        [self.dismissBtn setHidden:YES];  ///label . & dismissBtn not belong to loginview , so can't hidden / remove
        [self.welcomLb setHidden:YES];
        [self.portraitBtn setHidden:NO];
        [self.lb_lan setHidden:NO];

        [self.switch_btn setHidden:NO];
        [self.signUp setHidden:NO];
//        [self.otherAccount setHidden:NO];
        [self.loginBtn setTitle: LS(@"登录" ) forState:UIControlStateNormal];
        
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
            make.top.equalTo(self.loginBtn.mas_bottom).offset(20.f);
            make.centerX.equalTo(self.loginBtn);
            make.width.mas_equalTo(AM_SCREEN_WIDTH - 80.f);
            make.height.mas_equalTo(40);
            
            //            make.leading.equalTo(self).offset(20.f);
            //            make.trailing.equalTo(self).offset(-20.f);
            //            make.bottom.equalTo(self).offset(-40.f);
        }];
        
//        [self.otherAccount mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.loginBtn.mas_bottom).offset(10.f);
//            make.trailing.equalTo(self).offset(-20.f);
//        }];
        
        if (USER.user_email.length) {
            
            
            ///show pre tf_account
            [self.tf_account setText: USER.user_email];
            [self.portraitBtn setImage:[UIImage imageWithData:USER.user_portrait] forState:UIControlStateNormal];

//            [self.tf_account setEnabled:NO];
//            [self.tf_account setBorderStyle:UITextBorderStyleNone];
  
//            self.tf_account.textAlignment = NSTextAlignmentCenter;
//            [self.tf_account setLeftViewMode:UITextFieldViewModeNever];
//            [self.tf_account setFont:[UIFont systemFontOfSize:20.f]];
        }
    }
    
    [self.tf_pwd mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tf_account.mas_bottom).offset(20.f);
        make.leading.equalTo(self).offset(15.f);
        make.trailing.equalTo(self).offset(-15.f);
        make.height.mas_equalTo(40.f);
    }];
    
    
    [self.lb_lan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.tf_account).offset(5.f);
        make.top.equalTo(self.tf_pwd.mas_bottom).offset(20.f);
    }];
    [self.switch_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.lb_lan.mas_trailing).offset(5.f);
        make.centerY.mas_equalTo(self.lb_lan);
    }];
    
    [self.loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.switch_btn.mas_bottom).offset(40.f);
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
        _welcomLb = [UILabel labelWithText:LS(@"注册 KAMU 账户") withFont:[UIFont boldSystemFontOfSize:21.f] color:[UIColor blackColor] aligment:NSTextAlignmentCenter];
    }
    return _welcomLb;
}
//- (UIButton *)otherAccount {
//    if (!_otherAccount) {
//        _otherAccount = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_otherAccount setTitle:@"其他账号登录" forState:UIControlStateNormal];
//        [_otherAccount.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
//        [_otherAccount setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [_otherAccount.titleLabel setTextAlignment:NSTextAlignmentCenter];
//        [_otherAccount addTarget:self action:@selector(otherAccountLogin:) forControlEvents:UIControlEventTouchUpInside];
//        [_otherAccount sizeToFit];
//    }
//    return _otherAccount;
//}
- (UIButton *)signUp {
    
    
    if (!_signUp) {
        _signUp = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signUp setTitle:LS(@"没有kamu账号？立即注册新账号!") forState:UIControlStateNormal];

        [_signUp.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_signUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signUp.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_signUp addTarget:self action:@selector(registerAccount:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        [_signUp setBackgroundColor:[UIColor colorWithHex:@"#808080"]];
        [_signUp.layer setCornerRadius:20.f];
        [_signUp.layer setMasksToBounds:YES];
    }
    
    return _signUp;
}
- (void)registerAccount:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(action:actionType:)]) {
        [self.delegate action:sender actionType:ZLLoginType_register];
    }
}
//- (void)otherAccountLogin:(UIButton *)sender {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(action:actionType:)]) {
//        [self.delegate action:sender actionType:ZLLoginType_otherAccount];
//    }
//}
- (void)dismiss:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(action:actionType:)]) {
        [self.delegate action:sender actionType:ZLLoginType_dismiss];
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
        NSMutableAttributedString *pwd_s = [[NSMutableAttributedString alloc] initWithString:LS(@"邮箱:")];
        _tf_account = [[ZLTextField alloc] init];
        [_tf_account setIcon:[UIImage imageNamed:@"btn_email"]];
        [_tf_account setPlaceholder:[pwd_s string]];
        [_tf_account setBorderStyle:UITextBorderStyleRoundedRect];
        [_tf_account setKeyboardType:UIKeyboardTypeEmailAddress];
        _tf_account.returnKeyType = UIReturnKeyDone;
        
        WS(self);
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

- (UISwitch *)switch_btn {
    if (!_switch_btn) {
        _switch_btn = [[UISwitch alloc] init];
        [_switch_btn addTarget:self action:@selector(autoFill:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switch_btn;
}
- (void)autoFill:(UISwitch *)sender {
    if (sender.isOn) {
        [self.tf_account setText:@"admin@ygtek.cn"];
        [self.tf_pwd setText:nil];
        [self.lb_lan setTextColor:[UIColor blackColor]];
    }else {
        [self.tf_account setText: USER.user_email];
        [self.lb_lan setTextColor:[UIColor lightGrayColor]];
        [self setLoginType:ZLLoginType_prior];

    }
}




- (UILabel *)lb_lan {
    if (!_lb_lan) {
        _lb_lan = [UILabel labelWithText:LS(@"设置成局域网模式") withFont:[UIFont systemFontOfSize:14.f] color:[UIColor lightGrayColor] aligment:NSTextAlignmentRight];
    }
    return _lb_lan;
}


- (ZLTextField *)tf_pwd {
    
    if (!_tf_pwd) {
        NSMutableAttributedString *pwd_s = [[NSMutableAttributedString alloc] initWithString:LS(@"密码:" )];
        _tf_pwd = [[ZLTextField alloc] init];
        
        [_tf_pwd setPlaceholder:[pwd_s string]];
        [_tf_pwd setIcon:[UIImage imageNamed:@"button_lock"]];

        [_tf_pwd setBorderStyle:UITextBorderStyleRoundedRect];
        [_tf_pwd setKeyboardType:UIKeyboardTypeDefault];
        
        
        _tf_pwd.secureTextEntry = YES;
        _tf_pwd.returnKeyType = UIReturnKeyDone;
        
        WS(self);
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
    [self.signUp setHidden:YES];
    [self loginWithFirstText:self.tf_account.text secondText:self.tf_pwd.text finished:^(User *user, NSString *errorMsg) {
        user.user_id ? self.userLogin(self.loginBtn,user):[self.loginBtn failedAnimationWithCompletion:^{
            [self.signUp setHidden:NO];}];
    }];
}
/*
 for (Cam *local_cam in [Cam allObjects]) {
 //local no delete  but remote  deleted   crash -- @"Index %zu is out of bounds (must be less than %zu)
 if(local_cam.nvrs.count == 1) { ///although   num == 0 , but RLMArray  is always exist
 Device *cam_owner = local_cam.nvrs[0];
 if([cam_owner.nvr_id isEqualToString:server_device.nvr_id] ){
 [server_device.nvr_cams addObject:local_cam];
 
 /// 设备名称  --- 会有很多 cam ，只进来一次
 if (!server_device.nvr_name) {
 server_device.nvr_name = cam_owner.nvr_name;
 }
 ///用户头像
 if ( !response_user.user_portrait && cam_owner.nvr_users.count == 1 ) {
 User *local_user = cam_owner.nvr_users[0];
 if ([local_user.user_id isEqualToString:response_user.user_id]) {
 NSLog(@"------------设备 只有 1 个 User ---------------");
 response_user.user_portrait = local_user.user_portrait;
 }
 }
 }
 }
 }
 */

///局域网登录
- (void)localLogin:(loginFinshed)Completion {
    User *localUser = [User new];
    [localUser setUser_id:@"-1"];
    [RLM transactionWithBlock:^{
        [RLM addOrUpdateObject:localUser];
    }];
    if ([self.tf_account.text isEqualToString:@"admin@ygtek.cn"] && [self.tf_pwd.text isEqualToString:@"123"]) {
        Completion(localUser,nil);
    }else {
        [self.loginBtn failedAnimationWithCompletion:^{
            [MBProgressHUD showError:@"用户名或密码不正确"];
        }];
    }
}
///远程登录
- (void)loginWithFirstText:(NSString *)account secondText:(NSString *)pwd finished:(loginFinshed)finished {
    if (![self isValidateEmail:account]) {
        [MBProgressHUD showPromptWithText:@"邮箱格式不正确"];
        return;
    }
    
    [self.loginBtn scaleAnimation];
    NSString *URL = @"";
    if (self.loginType == ZLLoginType_prior && self.switch_btn.isOn){//self.loginType == ZLLoginType_otherAccount ||
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self localLogin:finished];
              return;
        });
    }
    else if (self.loginType == ZLLoginType_prior && !self.switch_btn.isOn) {
        URL = KM_API_URL(@"login");
    }
    else if (self.loginType == ZLLoginType_register) {
        URL = KM_API_URL(@"signup");
    }
   
    ///REQEST
    __block NetWorkTools *loginReq = [NetWorkTools new];
    [loginReq request:POST
            urlString:URL parameters:@{ @"email":account,
                                        @"password":pwd,
                                        }
             finished:^(id responseDict, NSString *errorMsg) {
                 if (responseDict) {
                     if ([loginReq.URL  isEqualToString:KM_API_URL(@"signup")]) {
                         [loginReq requestData:KM_API_URL(@"login")];
                     }else {
                         User *response_user =  [User mj_objectWithKeyValues:responseDict];
                         NSLog(@"🎆 RESPNOSE_USER---:%@  ---ResponseObj : %@",response_user,[responseDict description]);
                         if(response_user ) {
                             response_user.user_email = account;
                             response_user.user_pwd = pwd;
                             finished([response_user matchingWithLogin:YES],errorMsg) ;
                         } else {
                             [self.loginBtn failedAnimationWithCompletion:^{
                                 [MBProgressHUD showError:LS(@"服务器访问错误")];
                             }];
                         }
                     }
                 }else {
                     [self.loginBtn failedAnimationWithCompletion:nil];
                 }
                 loginReq = nil;/// 如果 weakReq 已经释放了 ，思考 ？？ ————strong 也没意义！！ 其实是有意义的
             }];
}

//利用正则表达式验证
-(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *regexMatchEmail = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexMatchEmail];
    return [predicate evaluateWithObject:email];
}

/// LoginView 里 touches began 键盘回收
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for(UIView *view in self.subviews){
        [view resignFirstResponder];
    }
}
/*
 [self.portraitBtn setTitle:USER.user_email forState:UIControlStateNormal];
 [self.portraitBtn.titleLabel sizeToFit];  ///require to get titleLabel size
 
 //image top，title down：
 CGSize titleSize = self.portraitBtn.titleLabel.bounds.size;
 CGSize imageSize = self.portraitBtn.imageView.bounds.size;
 NSLog(@"titleSize:-%@,imageSIze:-%@",NSStringFromCGSize(titleSize),NSStringFromCGSize(imageSize));
 self.portraitBtn.imageEdgeInsets = UIEdgeInsetsMake(0, titleSize.width / 2, titleSize.height + 5, -titleSize.width / 2);
 self.portraitBtn .titleEdgeInsets = UIEdgeInsetsMake(imageSize.height + 5, -imageSize.width, 0,0);
 */
@end
