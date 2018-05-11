//
//  MineViewController.m
//  Kamu
//
//  Created by YGTech on 2018/1/9.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "MineViewController.h"

@interface MineViewController ()


@end

@implementation MineViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
  
//    UIView *f_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AM_SCREEN_WIDTH, 65)];
        UIView *f_view = [[UIView alloc] init];
    [self.view addSubview:f_view];

    [f_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.equalTo(@64);
    }];

    
    [f_view setBackgroundColor:[UIColor redColor]];
    
    

    
//    UIButton *outter_btn = [[BButton alloc] initWithFrame:CGRectMake(AM_SCREEN_WIDTH/2, 65, 40, 40)];
    UIButton *outter_btn = [[BButton alloc] init];
    [outter_btn setBackgroundColor:[UIColor blueColor]];
    [f_view addSubview:outter_btn];
    
    
    [outter_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(f_view);
        make.centerY.mas_equalTo(32 + 20);
        make.width.height.equalTo(@40);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
