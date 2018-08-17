//
//  QRDoneViewController.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/5.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "QRDoneViewController.h"
#import "Device.h"
#import "AMNavigationController.h"
#import "UITextField+TF_FloatUp.h"

#import "RTSpinKitView.h"
#import "AppDelegate.h"
#import "KMReqest.h"
@interface QRDoneViewController ()<PopupDelegate>

@property (nonatomic, strong) UIView *QRResultView;

@property (nonatomic, strong) UITextField *tf;


@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) RTSpinKitView *spinner;
@property (nonatomic, strong) UIImageView *indicator;
@property (nonatomic, strong) BButton *addBtn;
@property (nonatomic, strong) UILabel *specLable;
@property (nonatomic, strong) UILabel *changeName;

@end

@implementation QRDoneViewController
- (AppDelegate *)appDelegate {
    
    if (!_appDelegate) {
        _appDelegate =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return _appDelegate;
}
//先调用这个方法----> 再调用init方法  //push 设置 之前
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.navigationItem.title = @"添加设备";
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view  setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.QRResultView];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    [self connectDevice];
    
}
- (void)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES]; //debug : 相机视图空白
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 保存按钮点击事件，连接设备
- (void)connectDevice {
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_indicator setImage:[[UIImage imageNamed:@"icon_succeed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_indicator setContentMode:UIViewContentModeScaleAspectFit];
        
        [_specLable setAttributedText:[NSAttributedString attrText:@"我们已找到您的设备，在继续下一步前，建议您更改设备名称！" withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blackColor] aligment:NSTextAlignmentLeft]];
        [_specLable sizeToFit];
        [_changeName setAttributedText:[NSAttributedString underlineAttrText:[NSString stringWithFormat:@"%@",self.qr_String] withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blueColor] aligment:NSTextAlignmentCenter]];
        [_spinner stopAnimating];
        
        [_addBtn setEnabled:YES];
        [_addBtn setColor:[UIColor colorWithHex:@"0066ff"]];

    });
    
}




#pragma mark - Required!!

//扫描成功后 添加设备对象




//扫描结果 View
- (UIView *)QRResultView {
    
    
    if (!_QRResultView) {
        
        //扫描结果视图
        _QRResultView = [[UIView alloc] initWithFrame:self.view.bounds];
        _indicator = [[UIImageView alloc] init];
        [_indicator setTintColor:[UIColor greenColor]];
        [_indicator setContentMode:UIViewContentModeCenter];
        
        
        _spinner = [[RTSpinKitView alloc] initWithFrame:CGRectZero];
        _spinner.spinnerSize = 40.f;
        _spinner.color = [UIColor lightGrayColor];
        _spinner.style = RTSpinKitViewStyleThreeBounce;
        [_spinner setHidesWhenStopped:YES];
        [_spinner startAnimating];
        [_indicator addSubview:_spinner];
        
        [_spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_indicator);
            make.bottom.equalTo(_indicator);
        }];
        
        
        /*
         NSMutableAttributedString *pwdString = [[NSMutableAttributedString alloc] initWithString:@"请输入设备密码"];
         self.tf = [UITextField  textFiedWithText:pwdString];
         self.tf.secureTextEntry = YES;
         self.tf.returnKeyType = UIReturnKeyDone;
         */
        
        
        
        _specLable = [[UILabel alloc] init];
        [_specLable setNumberOfLines:0];
        _changeName = [[UILabel alloc] init];
        
        NSAttributedString *aString = [NSAttributedString attrText:@"正在查找设备请等待...." withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blackColor] aligment:NSTextAlignmentCenter];
        _specLable.attributedText = aString;
        _addBtn = [[BButton alloc] initWithFrame:CGRectZero color:[UIColor grayColor]];
        [_addBtn setTitle:@"添加设备" forState:UIControlStateNormal];
        [_addBtn setEnabled:NO];
        [_addBtn addTarget:self action:@selector(toHome:) forControlEvents:UIControlEventTouchUpInside];
        [_QRResultView addSubview:_indicator];
        [_QRResultView addSubview:_specLable];
        [_QRResultView addSubview:_changeName];
        //        [_QRResultView addSubview:self.tf];
        [_QRResultView addSubview:_addBtn];
        
        //设置约束
        [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_QRResultView).offset(104);
            make.leading.equalTo(_QRResultView).offset(12.0f);
            make.trailing.equalTo(_QRResultView).offset(- 12.0f);
            make.height.equalTo(@60.0f);
        }];
        
        [_specLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_indicator.mas_bottom).offset(20.0f);
            make.leading.equalTo(_QRResultView).offset(12.0f);
            make.trailing.equalTo(_QRResultView).offset(- 12.0f);
        }];
        [_changeName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_specLable.mas_bottom).offset(20.0f);
            make.leading.equalTo(_QRResultView).offset(12.0f);
            make.trailing.equalTo(_QRResultView).offset(- 12.0f);
        }];
        /*
         [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(lb_deviceType.mas_bottom).offset(10.0f);
         make.leading.equalTo(_QRResultView).offset(12.0f);
         make.trailing.equalTo(_QRResultView).offset(- 12.0f);
         make.height.mas_equalTo(kTextFieldH + 25.0f);
         }];
         */
        
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.top.equalTo(self.tf.mas_bottom).offset(15.0f);
            
            make.bottom.equalTo(_QRResultView.mas_bottom).offset(- 104.f);
            make.height.mas_equalTo(kBtnH);
            make.leading.equalTo(_QRResultView).offset(12.0f);
            make.trailing.equalTo(_QRResultView).offset(- 12.0f);
        }];
    }
    return _QRResultView;
}
- (void)popupWillAppear:(Popup *)popup {
    [popup.successBtn setEnabled:NO];
    [popup.successBtn  setShouldShowDisabled:YES];  //也不能点击 只是修改 button 的 disabled 的UI
}
///MARK:  点了按钮之后 才会 先走 popup  代理 ----再调用的block
- (void)button:(BButton *)btn dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray {
    
    if ([stringArray[0] length]) {
        [_changeName setAttributedText:[NSAttributedString underlineAttrText:[NSString stringWithFormat:@"%@",stringArray[0]] withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blueColor] aligment:NSTextAlignmentCenter]];
    }
}
- (void)toHome:(id)sender {
    if ( [[USER.user_devices objectsWhere:[NSString stringWithFormat:@"nvr_id = '%@'",self.qr_String]] firstObject]) {
        [MBProgressHUD showPromptWithText:@"该设备已经被添加到列表"];
    }else {
        NSString * searchDevicePath = [NSString stringWithFormat:@"searchDevice/%@",self.qr_String];
        [[NetWorkTools new] request:GET urlString:KM_API_URL(searchDevicePath) parameters:nil finished:^(id responseObject, NSError *error) {
            NSDictionary *dict = [NSDictionary dictionaryWithJSONData:responseObject];
            NSString *success_s = [NSString stringWithFormat:@"%@",[[dict arrayValueForKey:@"success"] lastObject]];
            NSString *fail_s = [NSString stringWithFormat:@"%@",[[dict arrayValueForKey:@"error"] lastObject]];
            
            
            if (![dict valueForKey:@"success"]) {
                if([fail_s isEqualToString:@"(null)"]) {
                    [MBProgressHUD showError:@"sessionID 过期"];
                }else {
                    [MBProgressHUD showError:fail_s];
                }
            }else {
                Popup *popup = [[Popup alloc] initWithTitle:@"更改设备名称"
                                                   subTitle:@"您想将设备放在何处？比如客厅,门廊,公司，家里..."
                                      textFieldPlaceholders:@[@"设置设备名称.."]
                                                cancelTitle:nil
                                               successTitle:@"确定"
                                                cancelBlock:^{
                                                } successBlock:^{
                                                    
                                                   
                                                    
                                                    Device *db_device =     RLM_R_NVR(self.qr_String);
                                                    if(db_device) {
                                                        [RLM beginWriteTransaction];
                                                        [USER.user_devices addObject:db_device]; ///引用数据库里的对象
                                                        [RLM commitWriteTransaction];

                                                    }else {
                                                        Device *aDevice = [Device new];
                                                        aDevice = [[Device alloc] init];
                                                        [aDevice setNvr_id:self.qr_String];
                                                        [aDevice setNvr_name:self.changeName.text];
                                                        [aDevice setNvr_status:CLOUD_DEVICE_STATE_UNKNOWN];
                                                        
                                                        [RLM beginWriteTransaction];
                                                        [USER.user_devices addObject:aDevice]; ///创建对象到数据库 & 引用数据库这个对象
                                                        [RLM commitWriteTransaction];
                                                    }
                                                    
                                               
                                                    
                                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                                    [[NSNotificationCenter defaultCenter ] postNotificationName:@"addNew" object:nil userInfo:nil];
                                                }];
                
                
                [popup setDelegate:self];//回调代理方法
                [popup setRoundedCorners:YES];
                
                
                [popup setBackgroundBlurType:PopupBackGroundBlurTypeDark];    //背景模糊
                [popup setIncomingTransition:PopupIncomingTransitionTypeFallWithGravity];
                [popup showPopup];
                
                
            }
        }];
        
        
       
    }
    
}
- (void)dealloc {
    NSLog(@"QRDONE 释放了");
}

//随机数 ，100 - 200 ,含100 ，200
- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}


@end
