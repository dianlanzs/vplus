//
//  NvrSettingsController.m
//  Kamu
//
//  Created by YGTech on 2018/1/26.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "NvrSettingsController.h"

@interface NvrSettingsController ()

@property (nonatomic, strong) UIView  *formFooter;

@end

@implementation NvrSettingsController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置 尾部视图
    QSection *section1 = [self.root.sections objectAtIndex:0];
    [section1 setFooterView:self.formFooter];
    [section1.footerView setBounds:CGRectMake(0, 0, AM_SCREEN_WIDTH, 140.f)];
    

}





- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


///MARK:********** controllerForRoot方法 ====>  必须创建 这个 控制器类 ，这里重写 很重要，会创建不同 的展示 vc!!! ,说白了就是 不需要在文件中再创建 类了！！！！！！ 不写这个 就要写 controllerName？？？
//- (void)displayViewControllerForRoot:(QRootElement *)element {
//
//    QuickDialogController *newController = [QuickDialogController controllerForRoot:element];
//    [super displayViewController:newController];
//}




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
    self.deleteNvr();
//    cloud_device_del_cam(cloud_device_handle handle, cloud_cam_handle  cam_handle)
    
//    self.signal_delete(); //也可以 统一 使用通知 ///GLDraw 先停止绘制,--->然后刷新 数据源--->最后 回到主界面
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"camDelete" object:self.root];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
