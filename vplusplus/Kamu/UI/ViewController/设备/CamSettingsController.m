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
    QSection *section1 = [self.root.sections objectAtIndex:0];
    [section1 setFooterView:self.formFooter];
    [section1.footerView setBounds:CGRectMake(0, 0, AM_SCREEN_WIDTH, 140.f)];
    
    [self setNavgation];
    
}
- (void)setNavgation {
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveInfo:)];
}

- (void)saveInfo:(id)sender {
    
    
    
    //    [root fetchValueIntoObject:dict];
    //
  
    //    for (NSString *aKey in dict){
    //        msg = [msg stringByAppendingFormat:@"\n- %@: %@", aKey, [dict valueForKey:aKey]];
    //    }
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello"
    //                                                    message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
    
    
   __block device_cam_cfg_t cfg;
    NSString *camName = [NSString string];
    NSString *alertMsg = @"";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [self.root fetchValueIntoObject:dict];
    for (NSString *aKey in dict){
        
        if ([aKey isEqualToString:@"cam_battery_threshold"]) {
            cfg.battery_threshold = [[dict valueForKey:aKey] floatValue] * 100;
        }else if ([aKey isEqualToString:@"cam_pir_sensitivity"]) {
            cfg.pir_sensitivity = [[dict valueForKey:aKey] floatValue] * 100;
            NSLog(@"");
        }else if ([aKey isEqualToString:@"cam_rotate"]) {
            cfg.rotate = [[dict valueForKey:aKey] boolValue];
        }else if ([aKey isEqualToString:@"cam_rename"]){
            camName = [dict valueForKey:aKey];
        }
        
        alertMsg = [alertMsg stringByAppendingFormat:@"\n %@: %@", aKey, [dict valueForKey:aKey]];

    }
   
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RLM transactionWithBlock:^{
            [self.navigationController.operatingCam setCam_name:camName];
        }];
        [MBProgressHUD showSpinningWithMessage:@"uploading..."];
        cloud_device_cam_set_cfg((void *)self.navigationController.operatingDevice.nvr_h,[self.navigationController.operatingCam.cam_id UTF8String], &cfg);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:saveAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)updateElm:(NSString *)elmKey info:(int)value {
    
    QElement *e = [self.root elementWithKey:elmKey];
    if ([e isKindOfClass:[QBooleanElement class]]) {
        [(QBooleanElement *)e setBoolValue:value];
    }
    else if ([e isKindOfClass:[QFloatElement class]]) {
        [(QFloatElement *)e setFloatValue:(float)value / 100];
    }
    [e setEnabled:YES];
    [self.quickDialogTableView reloadData];


//   __block device_cam_cfg_t cfg;
//    e.onValueChanged = ^(QElement *changedElm) {
//
//        device_cam_cfg_t cfg;
//
//        if ([changedElm.key isEqualToString:@"cam_battery_threshold"]) {
//             cfg.battery_threshold = [changedElm.value intValue];
//        }else if ([changedElm.key isEqualToString:@"cam_pir_sensitivity"]) {
//             cfg.pir_sensitivity = [changedElm.value intValue];
//        }else if ([changedElm.key isEqualToString:@"cam_rotate"]) {
//             cfg.rotate = [changedElm.value intValue];
//        }
//
//     cloud_device_cam_set_cfg((void *)self.navigationController.operatingDevice.nvr_h,[self.navigationController.operatingCam.cam_id UTF8String], &cfg);
//
//
//    };
    
    
    //    [e.cell setUserInteractionEnabled:YES];
    //    [e.cell.textLabel setTextColor:[UIColor blackColor]];
    
    
    //    [self.quickDialogTableView cellForElement:e];
    //    [self.quickDialogTableView reloadRowsAtIndexPaths:@[[e getIndexPath]] withRowAnimation:UITableViewRowAnimationFade];
    
    
    
    
}


int device_event_callback_camSettings(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {
    
    CamSettingsController *cs = (__bridge CamSettingsController *)context;
    
   if (type == CLOUD_CB_CAM_CFG) {
        device_cam_cfg_t *info = (device_cam_cfg_t *)param;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [cs updateElm:@"cam_battery_threshold" info:info->battery_threshold];
            [cs updateElm:@"cam_pir_sensitivity" info:info->pir_sensitivity];
            [cs updateElm:@"cam_rotate" info:info->rotate];
        });
        
    }
    
    if (type == CLOUD_CB_CAM_SET_CFG) {
        device_cam_result_t *info = (device_cam_result_t *)param;
      
            dispatch_async(dispatch_get_main_queue(), ^{
                
                  if (info->ret_val == 0) {
                      [MBProgressHUD showSuccess:@"设置成功"];
                  }else {
                      [MBProgressHUD showSuccess:@"设置失败"];
                  }
            });
        
    }
    
    return 0;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    
    
    
    cloud_set_event_callback((void *)self.navigationController.operatingDevice.nvr_h, device_event_callback_camSettings,(__bridge void *)self);
    cloud_device_cam_get_cfg((void *)self.navigationController.operatingDevice.nvr_h ,[self.navigationController.operatingCam.cam_id UTF8String] );


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
    cloud_device_del_cam((void *)self.navigationController.operatingDevice.nvr_h, [self.navigationController.operatingCam.cam_id UTF8String]);
    
    Cam *deleteCam = RLM_R_CAM(self.navigationController.operatingCam.cam_id);
    if (deleteCam) {
        [RLM transactionWithBlock:^{
            NSLog(@"%@",self.navigationController.operatingCam);
            [self.navigationController.operatingDevice.nvr_cams removeObjectAtIndex:self.navigationController.operatingCam.cam_index];
        }];
    }
    
    [MBProgressHUD showSuccess:@"DELETE SUCCESS"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
