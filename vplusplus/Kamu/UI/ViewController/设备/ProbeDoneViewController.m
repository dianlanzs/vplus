//
//  ProbeDoneViewController.m
//  测试Demo
//
//  Created by Zhoulei on 2018/3/22.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "ProbeDoneViewController.h"

@interface ProbeDoneViewController ()<PopupDelegate>
@property (nonatomic, strong) UIView *ProbView;




@property (nonatomic, strong) RTSpinKitView *spinner;
@property (nonatomic, strong) UIImageView *indicator;
@property (nonatomic, strong) BButton *addBtn;
@property (nonatomic, strong) UILabel *specLable;
@property (nonatomic, strong) UILabel *changeName;

@end







@implementation ProbeDoneViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.navigationItem.title = @"Probe Camara";
    }
    return self;
}



- (void)connectDevice {
    
    RLMThreadSafeReference *deviceRef = [RLMThreadSafeReference
                                         referenceWithThreadConfined:self.nvrCell.nvrModel];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        @autoreleasepool {
            RLMRealm *realm = [RLMRealm realmWithConfiguration:RLM.configuration error:nil];
            Device *device = [realm resolveThreadSafeReference:deviceRef];
            if (device) {
                cloud_device_probe_cam((void *)device.nvr_h, my_device_action_callback,  (__bridge void *)self);
            }
        }
        
    });
}

//注册回调 cam 有数据的 时候会走 callback！
int my_device_action_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {
 
    dispatch_async(dispatch_get_main_queue(), ^{
        ProbeDoneViewController * ctx = (__bridge ProbeDoneViewController *)context;
        ctx.probedCam.cam_id = [NSString stringWithUTF8String:(char *)param];
        //动画：
        [UIView animateWithDuration:1.f delay:0.f usingSpringWithDamping:7.f initialSpringVelocity:4.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [ctx.indicator setImage:[[UIImage imageNamed:@"icon_succeed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [ctx.indicator setContentMode:UIViewContentModeScaleAspectFit];
            
            [ctx.specLable setAttributedText:[NSAttributedString attrText:@"我们已探测到您的CAM!，在继续下一步前，建议您更改设备名称！" withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blackColor] aligment:NSTextAlignmentLeft]];
            [ctx.specLable sizeToFit];
            [ctx.changeName setAttributedText:[NSAttributedString underlineAttrText:[NSString stringWithFormat:@"%@",ctx.probedCam.cam_id] withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blueColor] aligment:NSTextAlignmentCenter]];
            [ctx.spinner stopAnimating];
            
            [ctx.addBtn setEnabled:YES];
            [ctx.addBtn setColor:[UIColor blueColor]];
        } completion:nil];
        
        
  
       
    });
    return 0;
}

- (Cam *)probedCam {
    if (!_probedCam) {
        _probedCam = [[Cam alloc] init];
    }
    
    return _probedCam;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view  setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.ProbView];
    
    [self connectDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popupWillAppear:(Popup *)popup {
    [popup.successBtn setEnabled:NO];
    [popup.successBtn  setShouldShowDisabled:YES];
}
///MARK:  点了按钮之后 才会 先走 popup  代理 --------> 最后再调用的block
- (void)button:(BButton *)btn dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray {
    
    if ([stringArray[0] length]) {
        [_changeName setAttributedText:[NSAttributedString underlineAttrText:[NSString stringWithFormat:@"%@",stringArray[0]] withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blueColor] aligment:NSTextAlignmentCenter]];
    }
    
    [RLM transactionWithBlock:^{
        self.probedCam.cam_name = self.changeName.text;
    }];
    
}
- (void)toHome:(id)sender {
    

    if ([[self.nvrCell.nvrModel.nvr_cams objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",self.probedCam.cam_id]] firstObject]) {
        [MBProgressHUD showPromptWithText:@"该cam已经被添加"];
    }else {
        //局部变量会 出域 就释放了 不需要 ws
        Popup *popup = [[Popup alloc] initWithTitle:@"更改设备名称"
                                           subTitle:@"您想将设备放在何处？比如客厅,门廊,公司，家里..."
                              textFieldPlaceholders:@[@"设置Cam名称.."]
                                        cancelTitle:nil
                                       successTitle:@"Confirm"
                                        cancelBlock:^{
                                        } successBlock:^{
                                            
                                            [RLM transactionWithBlock:^{
                                                [self.nvrCell.nvrModel.nvr_cams addObject:self.probedCam];
                                            }];
                                            [self.nvrCell.QRcv reloadItemsAtIndexPaths:@[self.indexPath]];
                                            [self.navigationController popToRootViewControllerAnimated:YES];
                                            
                                        }];
        
        
        [popup setDelegate:self];
        [popup setRoundedCorners:YES];
        
        
        [popup setBackgroundBlurType:PopupBackGroundBlurTypeDark];    //背景模糊
        [popup setIncomingTransition:PopupIncomingTransitionTypeFallWithGravity];
        [popup showPopup];
        
        
    }
    
}





//扫描结果 View
- (UIView *)ProbView {
    
    
    if (!_ProbView) {
        
        //扫描结果视图
        _ProbView = [[UIView alloc] initWithFrame:self.view.bounds];
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
        
        NSAttributedString *aString = [NSAttributedString attrText:@"正在探测摄像头请等待...." withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blackColor] aligment:NSTextAlignmentCenter];
        
        
        
        
        
        
        
        
        _specLable.attributedText = aString;
        _addBtn = [[BButton alloc] initWithFrame:CGRectZero color:[UIColor grayColor]];
        [_addBtn setTitle:@"add Cam" forState:UIControlStateNormal];
        [_addBtn setEnabled:NO];
        
        [_addBtn addTarget:self action:@selector(toHome:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [_ProbView addSubview:_indicator];
        [_ProbView addSubview:_specLable];
        
        [_ProbView addSubview:_changeName];
        //        [_QRResultView addSubview:self.tf];
        
        
        [_ProbView addSubview:_addBtn];
        
        //设置约束
        [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_ProbView).offset(104);
            make.leading.equalTo(_ProbView).offset(12.0f);
            make.trailing.equalTo(_ProbView).offset(- 12.0f);
            make.height.equalTo(@60.0f);
            
        }];
        
        [_specLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_indicator.mas_bottom).offset(20.0f);
            make.leading.equalTo(_ProbView).offset(12.0f);
            make.trailing.equalTo(_ProbView).offset(- 12.0f);
            
            
        }];
        
        
        [_changeName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_specLable.mas_bottom).offset(20.0f);
            make.leading.equalTo(_ProbView).offset(12.0f);
            make.trailing.equalTo(_ProbView).offset(- 12.0f);
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
            
            make.bottom.equalTo(_ProbView.mas_bottom).offset(- 104.f);
            make.height.mas_equalTo(kBtnH);
            make.leading.equalTo(_ProbView).offset(12.0f);
            make.trailing.equalTo(_ProbView).offset(- 12.0f);
        }];
        
        
    }
    
    return _ProbView;
    
}
@end
