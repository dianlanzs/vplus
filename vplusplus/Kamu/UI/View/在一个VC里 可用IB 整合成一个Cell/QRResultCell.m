//
//  QRResultCell.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/7.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "QRResultCell.h"
#import "NSString+StringFrame.h"
#import "ReactiveObjC.h"

#import "AppDelegate.h"


#import "MainViewController.h"
#import "PlayVideoController.h"
#import "PlaybackViewController.h"

#import "AddCamsViewController.h"
#import "NvrSettingsController.h"
#import "LibraryController.h"
#import "DataBuilder.h"

@interface QRResultCell()<UICollectionViewDelegate,UICollectionViewDataSource>

//设备信息
@property (strong, nonatomic) UIImageView *deviceLogo;
//播放视图
@property (strong, nonatomic) UICollectionViewFlowLayout *QRflowLayout;
//顶部Bar
@property (strong, nonatomic) UIButton *settingsBtn;
@property (nonatomic, strong) UIImageView *idIcon;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) RLMNotificationToken *device_token;
@end


@implementation QRResultCell

int my_device_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {

    Device *d = (__bridge Device *)context;
    if (type == CLOUD_CB_STATE) {
        cloud_device_state_t state = *((cloud_device_state_t *)param);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"设备状态改变");
            
            
            
            [RLM beginWriteTransaction];
            d.nvr_status = state;
            [RLM commitWriteTransaction];
            
            
            
        });
    }

    /*
    else if (type == CLOUD_CB_ALARM){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (d.alarmShowed == 0) {
                d.alarmShowed = 1;
                Popup *p_alarm = [[Popup alloc] initWithTitle:@"alarm" subTitle:[NSString stringWithUTF8String:"test"] cancelTitle:nil successTitle:@"ok" cancelBlock:nil successBlock:^{
                    d.alarmShowed = 0;
                }];
                [p_alarm showPopup];
            }
        });
    }
     */
    return 0;
}

#pragma mark - 生命周期
// Designated initializer.  If the cell can be reused, you must pass in a reuse identifier.  You should use the same reuse identifier for all cells of the same form.  
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.footer];
        [self.contentView addSubview:self.QRcv];
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        [self.footer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.equalTo(self.contentView);
            make.height.mas_equalTo(40);
        }];
        [self.QRcv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(0.f);
            make.leading.equalTo(self.contentView).offset(0.0f);
            make.trailing.equalTo(self.contentView).offset(-0.0f);
            make.bottom.mas_equalTo(self.footer.mas_top).offset(0.f);
        }];
        
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
/// cuz CELL 还没有展示！！ nextResponder = nil!!
    [self showShadow];

    
    return self;
}
- (void)showShadow {
    self.layer.shadowOffset = CGSizeMake(1, 1);  //x 方向向右偏移0  ，y 方向向上偏移5 ，负为向上偏移
    self.layer.shadowOpacity = 0.4f; ///阴影透明度
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}

//TURN OUT：delete cell  will call dealloc  method
- (void)dealloc {
    [self.device_token invalidate];
}

#pragma mark - 视图数据源和代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    
    if (self.nvrModel.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
        return 1;
    }else {
        
        if (self.nvrModel.nvr_cams.count < 4) {
            return  4;
        }else {
            [MBProgressHUD showPromptWithText:@"cams num must less than 4!!"];
            return 0;
        }
        
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseID = [NSString stringWithFormat:@"%@",indexPath];
    [self.QRcv registerClass:[VideoCell class] forCellWithReuseIdentifier:reuseID ];
    VideoCell *videoCell = [self.QRcv dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    
    
    if (indexPath.item < self.nvrModel.nvr_cams.count) {

        [videoCell setCam:self.nvrModel.nvr_cams[indexPath.item]];
        
        //            RLMRealm *realm = [RLMRealm realmWithConfiguration:RLM.configuration error:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [RLM beginWriteTransaction];
            videoCell.cam.cam_index = (int)indexPath.item;
            [RLM commitWriteTransaction];
        }) ;
       

        
        
    }else {
        [videoCell setCam:nil];
    }
    return videoCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item < self.nvrModel.nvr_cams.count) {
        [self.vc.navigationController pushViewController:[PlayVideoController new] deviceModel:self.nvrModel camModel:self.nvrModel.nvr_cams[indexPath.row]];
    } else {
        [self.vc.navigationController pushViewController:[AddCamsViewController new] deviceModel:self.nvrModel camModel:nil];
    }
}



#pragma mark - cams
- (void)upadteCams{
    
    device_cam_info_t ipc_info[4];
    int camsNum = cloud_device_get_cams((void *)self.nvrModel.nvr_h, 4, ipc_info);
    NSLog(@"======================= 获取到Cams:%d =======================",camsNum);
    if (camsNum) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [RLM beginWriteTransaction];
            [self.nvrModel.nvr_cams removeAllObjects];
            [RLM commitWriteTransaction];
        }) ;
        
        
        for (NSInteger i = 0; i < camsNum; i++) {
            
            Cam *searchedCam = [Cam new];
            searchedCam.cam_id = [NSString stringWithUTF8String:ipc_info[i].camdid];
//            Cam *find_db_cam =  [[self.nvrModel.nvr_cams objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",searchedCam.cam_id]] firstObject];
//            if (!find_db_cam) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                RLMRealm *realm = [RLMRealm realmWithConfiguration:RLM.configuration error:nil];

                [realm beginWriteTransaction];
                [self.nvrModel.nvr_cams addObject:searchedCam];
                [realm commitWriteTransaction];
            }) ;
//            }
        }
    }
}


- (MainViewController *)vc {
    return  (MainViewController *)[self getViewController];
}

///nextResponder -superview ,cell未加载出来，next responder == nil
- (void)setNvrModel:(Device *)nvrModel {
    
    if (_nvrModel != nvrModel) {
        ///prepare :
        [RLM transactionWithBlock:^{
//            nvrModel.nvr_status = CLOUD_DEVICE_STATE_UNKNOWN; //from db set status unknown！
            nvrModel.nvr_h = (long)cloud_open_device([nvrModel.nvr_id UTF8String]);
        }];
        _nvrModel = nvrModel;
   

        
        __weak typeof (self) ws = self;
        //add & delete opration can not trigger notification!! cuz its not oberseve self.resluts
        self.device_token = [nvrModel addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
            if (deleted) {
                [MBProgressHUD showError:@"设备已经删除"];
            }else {
                for (RLMPropertyChange *property in changes) {

                    ///1. status changed
                    if ([property.name isEqualToString:@"nvr_status"] ) {
                        NSLog(@"---------------DEVICE CHANGED STATUS:%@ ---------------",property.value);
                        
                        UINavigationController *nav = self.vc.navigationController;
                        UIViewController *visibleController = nav.visibleViewController;

                        if ([property.value intValue] == CLOUD_DEVICE_STATE_CONNECTED) {
                           

                            
//                            AFHTTPSessionManager *m = [(AppDelegate *)   [UIApplication sharedApplication].delegate manager];
//                            [m.reachabilityManager startMonitoring]; ///when connected  监测 网络状态 改变！！
                            
                            
                            
                            
                            [ws upadteCams];
                            //Home page state
                            [ws.maskView setHidden:YES];
                            //playable button state
                            for (VideoCell *connect_c in self.QRcv.visibleCells) {
                                [connect_c.playBtn setHidden:NO];
                            }
                            //operating state
                            if ([ws.nvrModel.nvr_id isEqualToString:nav.operatingDevice.nvr_id] && nav.viewControllers.count > 1) {
                                self.vc.navigationController.operatingDevice = ws.nvrModel;
                                [MBProgressHUD showStatus:CLOUD_DEVICE_STATE_CONNECTED];
                                
                                
                                
                                if ([visibleController isKindOfClass:[PlayVideoController class]]) {
                                    [((PlayVideoController *)visibleController).vp lv_start];
                                }else if ([visibleController isKindOfClass:[PlaybackViewController class]]) {
                                    [((PlaybackViewController *)visibleController).vp pb_start];
                                }
                                
                            }
                            
                        } else {
                            
                            
                            [ws.maskView setHidden:NO];
                            [ws.spinner stopAnimating];
                            
                            for (VideoCell *disconnect_c in self.QRcv.visibleCells) {
                                [disconnect_c.playBtn setHidden:YES];
                            }
                            
                            if ([ws.nvrModel.nvr_id isEqualToString:nav.operatingDevice.nvr_id] &&  nav.viewControllers.count > 1) {
                                self.vc.navigationController.operatingDevice = ws.nvrModel;
                                MBProgressHUD *hud =   [MBProgressHUD showStatus:CLOUD_DEVICE_STATE_DISCONNECTED];
                                [hud.actionBtn setHidden:NO];
                                [hud.actionBtn addTarget:self.vc.navigationController action:@selector(reconnect:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                            if ([property.value intValue] ==  CLOUD_DEVICE_STATE_DISCONNECTED) {
                                [ws.statusLabel setText:@"DISCONNECTED"];
                            }else if ([property.value intValue] == CLOUD_DEVICE_STATE_AUTHENTICATE_ERR) {
                                [ws.statusLabel setText:@"AUTHENTICATE_ERR"];
                            }else if ([property.value intValue] == CLOUD_DEVICE_STATE_OTHER_ERR) {
                                [ws.statusLabel setText:@"OTHER_ERR"];
                            }else if ([property.value intValue] == CLOUD_DEVICE_STATE_UNKNOWN) {
                                [ws.statusLabel setText:@"Getting Device Status"];
                                [ws.spinner startAnimating];
                            }
                        }
                    }
                    
                    
                    ///2. cams changed
                    else if ([property.name isEqualToString:@"nvr_cams"]) {
                        [self.QRcv reloadData];
                    }
                    
                    
                    ///3. name changed
                    else if ([property.name isEqualToString:@"nvr_name"]) {
                        [self.footer.deviceLb setText:property.value];
                    }
                    
                }
            }
        }];
        
        
        
        
        
        
        cloud_set_status_callback((void *)nvrModel.nvr_h,my_device_callback,(__bridge void *)nvrModel);
        
        RLMThreadSafeReference *deviceRef = [RLMThreadSafeReference
                                             referenceWithThreadConfined:nvrModel];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            @autoreleasepool {
                RLMRealm *realm = [RLMRealm realmWithConfiguration:RLM.configuration error:nil];
                Device *device = [realm resolveThreadSafeReference:deviceRef];
                if (device) {
                    cloud_connect_device((void *)device.nvr_h, "admin", "123");
                }
            }
            
        });
        
        [self.footer.deviceLb setText:nvrModel.nvr_name];
    }
}

///动态设置每个Item的尺寸大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.nvrModel.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
        return CGSizeMake(AM_SCREEN_WIDTH , 201);
    }else {
        return CGSizeMake( (AM_SCREEN_WIDTH - 1) * 0.5, 100);
    }
}

///动态设置每行的间距大小
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {

     return 1.f;
}

///动态设置每列的间距大小
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}


#pragma mark - getter

- (UICollectionViewFlowLayout *)QRflowLayout {
    
    if (!_QRflowLayout) {
        _QRflowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        /*
        // _QRflowLayout.estimatedItemSize = CGSizeMake(AM_SCREEN_WIDTH , 200); //预估宽高 ，Cell约束高度宽度
        if (@available(iOS 10.0, *)) {
            _QRflowLayout.itemSize = UICollectionViewFlowLayoutAutomaticSize;
        } else {
            // Fallback on earlier versions
        }
        _QRflowLayout.itemSize = CGSizeMake( (AM_SCREEN_WIDTH - 1) * 0.5, 100);
        _QRflowLayout.minimumInteritemSpacing = 1.f;
        _QRflowLayout.minimumLineSpacing = 1.f;
         */
        
        _QRflowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        
    }
    return _QRflowLayout;
}

- (UICollectionView *)QRcv {
    
    if (!_QRcv) {
        //      NSInteger muti = (self.device.ipcCount * 0.5) + (self.device.ipcCount % 2);
        _QRcv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.QRflowLayout];
        _QRcv.dataSource = self;
        _QRcv.delegate = self;
        [_QRcv setBackgroundColor:[UIColor whiteColor]];
    }
    
    return _QRcv;
}

- (UIView *)maskView {
    
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        [_maskView addSubview:self.statusLabel];
        [_maskView addSubview:self.spinner];
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_maskView);
        }];
        
        [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.statusLabel.mas_trailing).offset(5.f);
            make.centerY.equalTo(self.statusLabel);
        }];
        [_maskView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]]; //彩色mask no effect!
    }
    
    return _maskView;
}


- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [UILabel labelWithText:@"Hello" withFont:[UIFont systemFontOfSize:20.f] color:[UIColor whiteColor] aligment:NSTextAlignmentCenter];
    }
    return _statusLabel;
}
- (RTSpinKitView *)spinner {
    if (!_spinner) {
        _spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce color:[UIColor whiteColor] spinnerSize:15.f];
        [_spinner setHidesWhenStopped:YES];
    }
    
    return _spinner;
   
}


#pragma mark - getter
- (DeviceFooter *)footer {
    
    if (!_footer) {
        
        _footer = [[DeviceFooter alloc] init];
        WeakObj(self);
        
        
        _footer.setNvr = ^(DeviceFooter *footer){
            QRootElement *rootForm = [[DataBuilder new] createForNvrSettings:ws.nvrModel]; //创建数据
            NvrSettingsController *nvrSettingsVc = [[NvrSettingsController alloc] initWithRoot:rootForm];
            [ws.vc.navigationController pushViewController:nvrSettingsVc deviceModel:ws.nvrModel camModel:nil];
            nvrSettingsVc .deleteNvr = ^{
                Popup *p = [[Popup alloc] initWithTitle:@"提示" subTitle:@"请确认是否需要删除该设备？" cancelTitle:@"取消" successTitle:@"确认" cancelBlock:nil successBlock:^{
                    [(MainViewController *)ws.vc deleteNvr:[NSIndexPath indexPathForRow:0 inSection:ws.path.section]];
                }];
                
                [p setIncomingTransition:PopupIncomingTransitionTypeFallWithGravity];
                [p setBackgroundBlurType:PopupBackGroundBlurTypeDark];
                [p showPopup];
            };
        };
        
        
        _footer.entryMedias = ^(DeviceFooter *footer) {
            [ws.vc.navigationController pushViewController:[LibraryController new] deviceModel:ws.nvrModel camModel:nil];
        };
    }
    return _footer;
}
@end
