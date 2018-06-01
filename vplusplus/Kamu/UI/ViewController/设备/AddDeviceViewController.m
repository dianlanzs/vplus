//
//  AddDeviceViewController.m
//  Kamu
//
//  Created by Zhoulei on 2017/11/20.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "QRCScanner.h"
#import "AMNavigationController.h"

#import "QRDoneViewController.h"



#import "Device.h"
#import "ReactiveObjC.h"
//#import "ManualInputViewController.h"
@interface AddDeviceViewController ()<QRCodeScanDelegate>

@property (weak, nonatomic) IBOutlet UIView *addDeviceView;

@property (nonatomic, strong) UIImageView *specView;
@property (nonatomic, strong) UILabel *descLb;

@property (nonatomic, strong) QRCScanner *scanner;
@end

@implementation AddDeviceViewController






#pragma mark - 生命周期
//先调用这个方法----> 再调用init方法
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.navigationItem.title = @"扫设备二维码";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加 Scannner
    [self addSubviews];
    
//
//
//    //设置右侧 item按钮
//    UIImage *buttonItemimage =  [UIImage imageNamed:@"navigation_add"];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:buttonItemimage style:UIBarButtonItemStylePlain target:self action:@selector(addButtonDidPressed:)];
//    
    
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];

}
#pragma mark -QRCodeScanne Delegate
- (void)didScannedQRCode:(NSString *)result {
    
    //合法性验证 ，必须是deviceID
//    RLMResults<Device *> *rets = [Device objectsWhere:[NSString stringWithFormat:@"did = '%@'",result]];
    

        
        if (result) {
            QRDoneViewController *QRdoneVc = [QRDoneViewController new];
            QRdoneVc.qr_String = result;
            [self.navigationController pushViewController:QRdoneVc animated:YES];
            
        }else{
            [MBProgressHUD showPromptWithText:@"未扫描到结果请退App出重新扫描!"];
        }

    
}





- (QRCScanner *)scanner {
    
    if (!_scanner) {
        _scanner = [[QRCScanner alloc] initQRCScannerWithView:self.view];
        _scanner.delegate = self;
    }
    
    return _scanner;
}

#pragma mark - 添加子（QR）视图
- (void)addSubviews {
    
    [self.view addSubview:self.scanner];
    
    //说明View
    [self.view addSubview:self.specView];
    [self.view addSubview:self.descLb];
    
    
    
    //其他方式添加视图
//    [self.view addSubview:self.addDeviceView];
    
    
    
    
    //约束：
    [self.specView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20.f);
        make.trailing.equalTo(self.view).offset(- 20.f);
        make.bottom.equalTo(self.view).offset(- 50.f);
//        make.size.mas_equalTo(CGSizeMake(AM_SCREEN_WIDTH - 20.f, 120.f));
        make.height.mas_equalTo(120);
    }];
    
    [self.descLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.specView.mas_bottom).offset(5.f);

    }];
    
}










#pragma mark - data required


- (UIImageView *)specView {
    
    if (!_specView) {
        _specView = [[UIImageView alloc] init];
        
        _specView.contentMode = UIViewContentModeScaleAspectFit;
        _specView.image = [UIImage imageNamed:@"imv_qrExample"];
     
    }
    
    return _specView;
}

- (UILabel *)descLb {
    
    if (!_descLb) {
        _descLb = [UILabel labelWithText:@"请扫描机身或说明书上二维码进行设备添加" withFont:
                   [UIFont systemFontOfSize:15.f] color:
                   [UIColor lightGrayColor] aligment:NSTextAlignmentCenter];
        
        _descLb.numberOfLines = 0;
    }
    
    return _descLb;
}
- (UIView *)addDeviceView {
        
        if (!_addDeviceView) {
            _addDeviceView = [[UINib nibWithNibName:@"AddDevice" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
            
            //图标数组
            NSArray *iconArray = @[@"manual",@"sound",@"wifi"];

            //设置button UI
            NSInteger index = 0;
            for (id obj in _addDeviceView.subviews) {
                
                if ([obj isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)obj;
                    UIImage *buttonImage = [[UIImage imageNamed:[NSString stringWithFormat:@"button_%@",iconArray[index]]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    button.tag = index;
                    [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                    [button setImage:buttonImage forState:normal];
                    [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
                    //子视图不指定渗透色，会使用父视图的 tintColor
                    button.tintColor = [UIColor whiteColor];
                    index++;
                }
                
            }
            
            _addDeviceView.frame = CGRectMake(0, AM_SCREEN_HEIGHT - 49, AM_SCREEN_WIDTH, AM_BAR_HEIGHT);
            _addDeviceView.backgroundColor = [UIColor blackColor];
            
            
        }
        
        return _addDeviceView;
    }



@end
