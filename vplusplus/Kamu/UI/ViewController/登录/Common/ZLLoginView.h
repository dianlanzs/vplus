//
//  ZLLoginView.h
//  Kamu
//
//  Created by YGTech on 2018/7/17.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HyLoginButton.h"
#import "ZLTextField.h"

typedef NS_ENUM(NSInteger,ZLLoginType){
    ZLLoginType_register = 0,
    ZLLoginType_prior,
    ZLLoginType_dismiss,
};
typedef void(^loginFinshed)(User *,NSString *,NSError * );


@protocol ZLLoginViewDelegate <NSObject>
@optional
- (void)action:(UIButton *)sender actionType:(ZLLoginType)type;

@end

@interface ZLLoginView : UIView
@property (nonatomic, weak) id <ZLLoginViewDelegate>delegate;

@property (nonatomic, copy) void(^userLogin)(HyLoginButton *, User *);
@property (nonatomic, copy) loginFinshed finished;



@property (nonatomic, strong) UILabel *welcomLb;
@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) HyLoginButton *loginBtn;
@property (nonatomic, strong) ZLTextField *tf_account; ///weak  tf_account 是 loginview 的全局变量 ，loginview 释放才释放
@property (nonatomic, strong) ZLTextField *tf_pwd;
@property (nonatomic, assign) ZLLoginType loginType;
@property (nonatomic, strong) UIButton *signUp;
//@property (nonatomic, strong) UIButton *otherAccount;
@property (nonatomic, strong) UIButton *portraitBtn;

@end
