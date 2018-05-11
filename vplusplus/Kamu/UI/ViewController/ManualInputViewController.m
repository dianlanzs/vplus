//
//  ManualInputViewController.m
//  ilnkDemo
//
//  Created by YGTech on 2017/11/22.
//  Copyright © 2017年 com.ilnkDemo.cme. All rights reserved.
//

#import "ManualInputViewController.h"
#import "AMCommonDef.h"

#import "UIBarButtonItem+Item.h"
#import "CommonDefine.h"

#import "PPPPManager.h"


#import "MBProgressHUD+ZLCategory.h"






//======= Reactive Cocoa=========
//#import "RACSignal.h"
//#import "UIControl+RACSignalSupport.h" //controlEvents
//#import "NSObject+RACSelectorSignal.h"//行为 信号
//#import "NSObject+RACPropertySubscribing.h"
////#import "RACTuple.h"
//
//#import "RACTuple.h"
@import ReactiveObjC;

// ====== IPC ===========
#import "PlayLandscapeController.h"
#import "Device.h"
@interface ManualInputViewController ()<UITextFieldDelegate,PPPPManagerStatusDelegate>
@property (weak, nonatomic) IBOutlet UIView *manual;
@property (weak, nonatomic) IBOutlet UITextField *pwd;

@property (weak, nonatomic) IBOutlet UITextField *deviceID;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (assign, nonatomic) BOOL isConnected;

@property (assign, nonatomic) NSNumber *num;

@end

@implementation ManualInputViewController






#pragma mark - 生命周期
- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        //initialize self
        self.navigationItem.title = @"手动添加";
        [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [self.view addSubview:self.manual];
        UIBarButtonItem *rBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveDevice)];
        rBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem = rBarButtonItem;
        
//        _isConnected = NO;
        
    }
    return self;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置代理
    [PPPPManager sharedPPPPManager].statusDelegate = self;
    
    [[self rac_signalForSelector:@selector(ppppStatus:statusType:status:)] subscribeNext:^(RACTuple * _Nullable x) {
        if ([x.third isEqual:@(10)]) {
            //这个代理方法 调用是不在 主队列 上
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showSuccess:@"连接成功"]; //showSucess 不需要隐藏？？
            });

        }
    }];
    
//    //监听文本框 文字改变
//    [self.pwd addTarget:self
//                       action:@selector(touchInTextField:)
//             forControlEvents:UIControlEventEditingChanged];
//
//    [self.deviceID addTarget:self
//                           action:@selector(touchInTextField:)
//                 forControlEvents:UIControlEventEditingChanged];
//}
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}




- (void)touchInTextField:(UITextField *)textField {


    self.saveButton.enabled = self.pwd.text.length && self.pwd.text.length;

}






#pragma mark - P2P 连接
- (void)saveDevice{
    //输入框 是否为空
    if (!self.deviceID.text.length && !self.pwd.text.length) {
        [MBProgressHUD showPromptWithText:@"请输入设备号和密码" inView:nil];
    }
    //密码为空
    if (self.deviceID.text.length && !self.pwd.text.length) {
        [MBProgressHUD showPromptWithText:@"请输入密码" inView:nil];
    }
    //设备号为空
    if (!self.deviceID.text.length && self.pwd.text.length) {
        [MBProgressHUD showPromptWithText:@"请输入设备号" inView:nil];
    }
    //输入完成
    if (self.deviceID.text.length && self.pwd.text.length) {
        
#warning Long-running Operation
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
              [self startP2PThread];
        });
        
//        [MBProgressHUD showLoadingWithMessage:@"正在连接中..."];// 不退出，没连接上！
        
      [self startP2PThread];
        NSLog(@"%@=====当前线程",[NSThread currentThread]);
    }

}

- (void)startP2PThread {
    
    //关闭 上一个 设备连接
    [[PPPPManager sharedPPPPManager] closePPPP:self.deviceID.text];
    //新的连接 user ,默认 admin
    [[PPPPManager sharedPPPPManager] startPPPP:self.deviceID.text user:@"admin" pwd:self.pwd.text];
    
}

//连接设备之后，状态回调  ，strDID :设备号 ， status:接收状态
- (void)ppppStatus:(NSString *)strDID statusType:(NSInteger)statusType status:(NSInteger)status {
    //验证 通知类型是否 PPPP 状态
    if (statusType == MSG_NOTIFY_TYPE_PPPP_STATUS ) {
        _isConnected = YES;
        _num = [NSNumber numberWithInteger:status];
    }

}



#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    [self.pwd resignFirstResponder];
    [self.deviceID resignFirstResponder];
    
    return YES;
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    //开始编辑时触发,更改placehoder 颜色！
//    [self.pwd setValue:[UIColor greenColor] forKeyPath:@"_placeholderLabel.textColor"];

}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; {
//
//    // return NO to not change text//当用户使用自动更正功能，把输入的文字修改为推荐的文字时，就会调用这个方法。
//    //这对于想要加入撤销选项的应用程序特别有用
//    //可以跟踪字段内所做的最后一次修改，也可以对所有编辑做日志记录,用作审计用途。
//    //这个方法的参数中有一个NSRange对象，指明了被改变文字的位置，建议修改的文本也在其中
//    return YES;
//}

#pragma mark - Data Required

- (UIView *)manual {
    
    if (!_manual) {
        _manual = [[UINib nibWithNibName:@"Manual" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        _manual.frame = CGRectMake(0, kTopbarHeight, AM_SCREEN_WIDTH, _manual.bounds.size.height);
    }
    
    return _manual;
}

//- (UIButton *)button {
//
//
//    if (!_saveButton) {
//
//        [_saveButton setFrame:CGRectMake(50, 50, 100, 50)];
//        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
//        [_saveButton bs_configureAsDefaultStyle];
//        //添加点击事件
//        [[_saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
//            [self saveButtonClick:_saveButton];
//            //            self.pushBtn.tag = 20;
//        }];
//    }
//
//        [self.view addSubview:_saveButton];
//
//    
//
//    return _saveButton;
//
//}
//
//
//
//
//- (void)saveButtonClick:(UIButton *)button {
//
//
//    //进入视频页面
//    Device *aDevice = [[Device alloc] init];
//    aDevice.did = self.deviceID.text;
//    aDevice.user = @"admin";
//    aDevice.pwd = self.pwd.text;
//
//    PlayLandscapeController * landscapeViewController = [[PlayLandscapeController alloc]init];
//    landscapeViewController.dataModel = aDevice;
//    [self.navigationController pushViewController:landscapeViewController animated:YES];
//
//
//
//}




@end
