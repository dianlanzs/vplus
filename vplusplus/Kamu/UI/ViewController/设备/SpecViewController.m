//
//  SpecViewController.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/16.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "SpecViewController.h"

#import "AddDeviceViewController.h"

@interface SpecViewController ()

@property (nonatomic, strong) UIImageView *imv;
@property (nonatomic, strong) UIView *specView;

@property (nonatomic, strong) UIButton *scanBtn;

@end

@implementation SpecViewController


- (UIButton *)scanBtn {
    
    if (!_scanBtn) {
        
        _scanBtn = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypePrimary];
        [_scanBtn setTitle:@"扫描设备二维码" forState:UIControlStateNormal];
        [_scanBtn setImage:[UIImage imageNamed:@"button_scan_normal"] forState:UIControlStateNormal];
        _scanBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);

        [_scanBtn addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanBtn;
}

- (void)scan:(id)sender {
    
    
    //设置 presentingViewController 为 当前nav
    AddDeviceViewController *addDeviceVc = [[AddDeviceViewController alloc]  init];
    
    //模态弹出
//    addDeviceVc.modalPresentationStyle = UIModalPresentationCurrentContext;
//    self.definesPresentationContext = YES;
//    [self.navigationController presentViewController:addDeviceVc animated:YES completion:nil];
    
    
    //push！
    [self.navigationController pushViewController:addDeviceVc animated:YES];

}

- (UIImageView *)imv {
    
    if (!_imv) {
        _imv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spec"]];
    }
    
    return _imv;
    
}


- (UIView *)specView {
    
    if (!_specView) {
        
        
        _specView = [[UIView alloc] init];
        
        NSArray *NumIcons = @[@"step1",@"step2", @"step3"];
        NSArray *specTexts = @[@"使用以太网将基站连接至路由器,插入交流电源插座。",
                               @"确保您的基站和路由器处于同一网段。",
                               @"按下基站背后 On-Off 按钮。"];
        
        CGFloat padding = 15.f;
        CGFloat numIconWidth = 30.f;
        CGFloat numIconHeight = 30.f;
        
        
        
        for (int i = 0; i < NumIcons.count; i++) {
            
            UIImageView *numIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NumIcons[i]]];
            [numIconView setContentMode:UIViewContentModeScaleAspectFit];
            
            UILabel *specText = [UILabel labelWithText:specTexts[i] withFont:[UIFont systemFontOfSize:17.f] color:[UIColor blackColor] aligment:NSTextAlignmentLeft];
            [specText setNumberOfLines:0];
            
            
            [_specView addSubview:numIconView];
            [_specView addSubview:specText];
            
            //设置约束
            [numIconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_specView).offset(0.f + i * (padding + numIconHeight));
                make.leading.equalTo(_specView).offset(0.f);
                make.size.mas_equalTo(CGSizeMake(numIconWidth, numIconHeight));
            }];
            
            [specText mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(numIconView.mas_trailing).offset(10.f);
                make.trailing.equalTo(_specView).offset(0.f);
                make.centerY.equalTo(numIconView);
            }];
            
        }
        
        
        
        
    }
    
    
    return _specView;
    
}




- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.imv];
    [self.view addSubview:self.specView];
    [self.view addSubview:self.scanBtn];
    
    //设置约束：
    
    [self.imv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(104.f);
        make.width.mas_equalTo(AM_SCREEN_WIDTH * 0.6);
        make.height.mas_equalTo(self.imv.mas_width).multipliedBy(0.71);
        make.centerX.equalTo(self.view);
    }];
    
    
    [self.specView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imv.mas_bottom).offset(40.f);
        make.leading.equalTo(self.view).offset(15.f);
        make.trailing.equalTo(self.view).offset(-15.f);
    }];
    
    
    [self.scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20.f);
        make.trailing.equalTo(self.view).offset(-20.f);
        make.bottom.equalTo(self.view).offset(-20.f);
        make.height.mas_equalTo(40.f);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
