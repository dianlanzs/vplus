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
@property (nonatomic, assign) __block device_cam_cfg_t *cfg;
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
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"保存") style:UIBarButtonItemStylePlain target:self action:@selector(saveInfo:)];
}
- (device_cam_cfg_t *)cfg {
    
    if (!_cfg) {
        _cfg = (device_cam_cfg_t *)malloc(sizeof(device_cam_cfg_t));
       
    }
    
    return _cfg;
}
- (void)saveInfo:(id)sender {
    
    __block device_cam_cfg_t *config = self.cfg;
    NSString *camName = [NSString string];
    NSString *alertMsg = @"";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [self.root fetchValueIntoObject:dict];
    for (NSString *aKey in dict){
        
        if ([aKey isEqualToString:@"cam_battery_threshold"]) {
            config ->battery_threshold = [[dict valueForKey:aKey] floatValue] * 100;
        }else if ([aKey isEqualToString:@"cam_pir_sensitivity"]) {
            config -> pir_sensitivity = [[dict valueForKey:aKey] floatValue] * 100;
        }else if ([aKey isEqualToString:@"cam_rotate"]) {
            config->rotate = [[dict valueForKey:aKey] boolValue];
        }else if ([aKey isEqualToString:@"cam_rename"]){
            camName = [dict valueForKey:aKey];
        }
        
        alertMsg = [alertMsg stringByAppendingFormat:@"\n %@: %@", aKey, [dict valueForKey:aKey]];
        
    }
    
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:LS(@"提示") message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"取消") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:LS(@"保存") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RLM transactionWithBlock:^{
            [self.navigationController.operatingCam setCam_battery_threshold:(float)config -> battery_threshold / 100];
            [self.navigationController.operatingCam setCam_pir_sensitivity:(float)config -> pir_sensitivity / 100];
            NSLog(@"%d ---- %@",config->pir_sensitivity, self.navigationController.operatingCam);
            [self.navigationController.operatingCam setCam_rotate: config->rotate];
            
            
        }];
        [MBProgressHUD showSpinningWithMessage:LS(@"上传配置信息...")];
        
        cloud_device_cam_set_cfg((void *)self.navigationController.operatingDevice.nvr_h,[self.navigationController.operatingCam.cam_id UTF8String], config);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:saveAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)updateElm:(NSString *)key info:(int)value {
    
    QElement *e = [self.root elementWithKey:key];
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
- (void )dealloc {
    NSLog(@"CAM SETTING 释放了");
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
                      [MBProgressHUD showSuccess:LS(@"设置成功")];
                  }else {
                      [MBProgressHUD showSuccess:LS(@"设置失败")];
                      cloud_device_cam_set_cfg((void *)cs.navigationController.operatingDevice.nvr_h,[cs.navigationController.operatingCam.cam_id UTF8String], cs.cfg);

                  }
            });
        
    }
    
    return 0;
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"-------NAVigationVC CamSetting %@",self.navigationController);
//    cloud_device_cam_get_cfg((void *)self.navigationController.operatingDevice.nvr_h ,nil);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.quickDialogTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view).offset(20.f);
        make.bottom.equalTo(self.view).offset(0.f);
        make.leading.equalTo(self.view).offset(15.f);
        make.trailing.equalTo(self.view).offset(-15.f);
    }];
    
//    self.root.value = [NSString stringWithFormat:@"(%ld)",_friends.elements.count];
//    QElement *vqRoot = [self.root elementWithKey:@"vqRoot"];
//    [vqRoot setValue:self.navigationController.operatingCam.cam_videoQulity];

    
    cloud_set_event_callback((void *)self.navigationController.operatingDevice.nvr_h, device_event_callback_camSettings,(__bridge void *)self);
    cloud_device_cam_get_cfg((void *)self.navigationController.operatingDevice.nvr_h ,[self.navigationController.operatingCam.cam_id UTF8String] );


}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
//    [self.quickDialogTableView setFrame:CGRectMake(15, 64, AM_SCREEN_WIDTH - 30, AM_SCREEN_HEIGHT - 64)];
}
#pragma mark - Required!
- (UIView *)formFooter {
    if (!_formFooter) {
        
        _formFooter = [[UIView alloc] init];
        BButton *restartBtn = [[BButton alloc] initWithFrame:CGRectMake(20.f, 40.f, AM_SCREEN_WIDTH - 40.f - 30.f, 40.f) type:BButtonTypePrimary];
        BButton *deleteBtn = [[BButton alloc] initWithFrame:CGRectMake(20.f, 100.f, AM_SCREEN_WIDTH - 40.f - 30.f, 40.f) type:BButtonTypeDanger];
        
        [deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [restartBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [deleteBtn  setTitle:LS(@"删除摄像头") forState:UIControlStateNormal];
        [restartBtn setTitle:LS(@"重启摄像头" ) forState:UIControlStateNormal];
        
        [_formFooter addSubview:restartBtn];
        [_formFooter addSubview:deleteBtn];
    }
    return _formFooter;
}
- (void)delete:(id)sender {
    Popup *p = [[Popup alloc] initWithTitle:LS(@"提示" ) subTitle:LS(@"请确认是否需要删除该摄像头 ？") cancelTitle:LS(@"取消") successTitle: LS(@"确认") cancelBlock:nil successBlock:^{
      int flag =  cloud_device_del_cam((void *)self.navigationController.operatingDevice.nvr_h, [self.navigationController.operatingCam.cam_id UTF8String]);
        NSLog(@"删除flag %d ",flag);
        if(flag == 0) {
            Cam *deleteCam = RLM_R_CAM(self.navigationController.operatingCam.cam_id);
            if (deleteCam) {
                [RLM transactionWithBlock:^{
                    [RLM deleteObject:deleteCam];
                }];
                [MBProgressHUD showSuccess:LS(@"删除成功")];
                cloud_set_event_callback((void *)self.navigationController.operatingDevice.nvr_h, nil,nil);
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else {
                [MBProgressHUD showSuccess:LS(@"摄像头不存在")];
            }
        } else if(flag == -1) {
            [MBProgressHUD showError:LS(@"主摄像头不能删除!")];
        }
    }];
    [p setIncomingTransition:PopupIncomingTransitionTypeFallWithGravity];
    [p setBackgroundBlurType:PopupBackGroundBlurTypeDark];
    [p showPopup];
}
@end
