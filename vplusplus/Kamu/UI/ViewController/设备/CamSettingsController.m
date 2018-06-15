//
//  CamSettingsController.m
//  Kamu
//
//  Created by Zhoulei on 2018/2/26.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "CamSettingsController.h"

@interface CamSettingsController ()
@property (nonatomic, strong) UIView  *formFooter;
@end

@implementation CamSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置 尾部视图
    QSection *section1 = [self.root.sections objectAtIndex:0];
    [section1 setFooterView:self.formFooter];
    [section1.footerView setBounds:CGRectMake(0, 0, AM_SCREEN_WIDTH, 140.f)];
}
#pragma mark - Required!
- (UIView *)formFooter {
    if (!_formFooter) {
        
        _formFooter = [[UIView alloc] init];
        BButton *restartBtn = [[BButton alloc] initWithFrame:CGRectMake(20.f, 40.f, AM_SCREEN_WIDTH - 40.f, 40.f) type:BButtonTypePrimary];
        BButton *deleteBtn = [[BButton alloc] initWithFrame:CGRectMake(20.f, 100.f, AM_SCREEN_WIDTH - 40.f, 40.f) type:BButtonTypeDanger];
        
        [deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [restartBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [deleteBtn  setTitle:@"删除设备" forState:UIControlStateNormal];
        [restartBtn setTitle:@"重新启动" forState:UIControlStateNormal];
        
        [_formFooter addSubview:restartBtn];
        [_formFooter addSubview:deleteBtn];
        
    }
    
    return _formFooter;
}
- (void)delete:(id)sender {
//    self.deleteCam();

    Device *deviceModel = [self.root.object valueForKey:@"deviceModel"];
    Cam *camModel = [self.root.object valueForKey:@"camModel"];

   
    cloud_device_del_cam((void *)deviceModel.nvr_h, [camModel.cam_id UTF8String]);
    [RLM transactionWithBlock:^{
        [deviceModel.nvr_cams removeObjectAtIndex:camModel.cam_index];
    }];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
