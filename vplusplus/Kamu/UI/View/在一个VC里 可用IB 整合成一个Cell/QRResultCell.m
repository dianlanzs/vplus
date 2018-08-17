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
///对方添加 删除 cam 会掉线！
int my_device_status_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {

    QRResultCell *cell = (__bridge QRResultCell *)context;
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if(cell.nvrModel.nvr_id) {
            if (type == CLOUD_CB_STATE) {
                cloud_device_state_t state = *((cloud_device_state_t *)param);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"设备状态改变 修改状态 %@",[NSThread currentThread]);
                    [RLM beginWriteTransaction];
                    cell.nvrModel.nvr_status = state;
                    [RLM commitWriteTransaction];
                });
            }
        }
        
    });
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
        [self.contentView addSubview:self.maskView];
      
        [self.footer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.equalTo(self.contentView);
            make.height.mas_equalTo(FOOTER_H);
        }];
        [self.QRcv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(0.f);
            make.leading.equalTo(self.contentView).offset(0.0f);
            make.trailing.equalTo(self.contentView).offset(-0.0f);
            make.bottom.mas_equalTo(self.footer.mas_top).offset(0.f);
        }];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.leading.equalTo(self.contentView);
            make.trailing.equalTo(self.contentView);
            make.bottom.equalTo(self.footer.mas_top);
        }];
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
// cuz CELL 还没有展示！！ nextResponder = nil!!
    [self showShadow];
    return self;
}
- (void)showShadow {
    self.layer.shadowOffset = CGSizeMake(1, 1);  //x 方向向右偏移0  ，y 方向向上偏移5 ，负为向上偏移
    self.layer.shadowOpacity = 0.4f; ///阴影透明度
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}

///TURN OUT：delete cell  will call dealloc  method
- (void)dealloc {
    [self.device_token invalidate];
    NSLog(@"==================== device Token 释放");
}

#pragma mark - 视图数据源和代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    
    if (self.nvrModel.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
        return 1;
    }else {
        if (self.nvrModel.nvr_cams.count < 4) {
            return  4;
        }else {
            [MBProgressHUD showError:@"cams num must less than 4!!"];
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

///只能更新 不能做添加
- (void)upadteCams{
    
    [RLM transactionWithBlock:^{
        [self.nvrModel.nvr_cams removeAllObjects];
    }];
    
    
    device_cam_info_t ipc_info[4];
    int camsNum = cloud_device_get_cams((void *)self.nvrModel.nvr_h, 4, ipc_info);
    NSLog(@"======================= 获取到Cams:%d =======================",camsNum);
    if (camsNum) {
        for (NSInteger i = 0; i < camsNum; i++) {
            
            NSString *camID_key=     [NSString stringWithUTF8String:ipc_info[i].camdid];
//            Cam *nvr_ref_sc =  [self.nvrModel.nvr_cams objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",cam_id_key]].firstObject;
            ///nvr_cams add refference
//            if(!nvr_ref_sc) {
                //"Attempting to create an object of type 'Cam' with an existing primary key value 'gw000c434fa9e5'.")
                Cam *db_cam = RLM_R_CAM(camID_key)
                if(db_cam) {
                    [RLM beginWriteTransaction];
                    [self.nvrModel.nvr_cams addObject:db_cam];
                    [RLM commitWriteTransaction];
                }else {
                    [RLM beginWriteTransaction];
                    [self.nvrModel.nvr_cams addObject:[[Cam alloc] initWithValue:@{@"cam_id": camID_key }]]; ///创建对象到数据库 & 引用数据库这个对象
                    [RLM commitWriteTransaction];
                }
//            }
        }
//        NSLog(@"🌈--- CAM 表 --%@ ",[Cam allObjects]);
    }
}


- (MainViewController *)vc {
    return  (MainViewController *)[self getViewController];
}

///nextResponder -superview ,cell未加载出来，next responder == nil

- (void)reset_db_Device:(Device *)nvrModel{
    [RLM transactionWithBlock:^{
        
        //        if(nvrModel.nvr_h == 0) {
        ///  insertSections  方法  不会重复  open!!!!
        long h =  (long) cloud_open_device([nvrModel.nvr_id UTF8String]);
        if(h) {/// can open
            [nvrModel setNvr_h:h];
        }
        //        }
        [nvrModel setNvr_status:CLOUD_DEVICE_STATE_UNKNOWN];
        ///覆盖 DB  nvr_h!!
        NSLog(@"-------- OPEN _ DEVICE -------- %ld",nvrModel.nvr_h);
    }];
}
- (void)setNvrModel:(Device *)nvrModel {
    
    if (_nvrModel != nvrModel ) { ///指针虽然不一样 但是设备是一样的！！！！！！！！！！！！ 这里会重复 open 设备！！
        [self reset_db_Device:nvrModel];
        _nvrModel = nvrModel;
        WS (self);
        NSLog(@"%@",self.device_token);
        self.device_token = [nvrModel addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
            //add & delete opration can not trigger notification!! cuz its not oberseve self.resluts
            if (deleted) {
                NSLog(@"%@",[NSThread currentThread]);
                [MBProgressHUD showSuccess:@"REALM 监听 删除成功"];
            }else {
                for (RLMPropertyChange *property in changes) {
                    ///1. status changed
                    UINavigationController *nav = ws.vc.navigationController;
                    UIViewController *visibleController = nav.visibleViewController;
                    if ([property.name isEqualToString:@"nvr_status"] ) {
                        NSLog(@"---------------DEVICE CHANGED STATUS:%@ ---------------",property.value);
                     
                        if ([property.value intValue] == CLOUD_DEVICE_STATE_CONNECTED) {
                            
                            /// __imp_ = (__imp_ = "The Realm is already in a write transaction")
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [ws upadteCams];
                            });
                          
                            //1. Home page state
                            [ws.maskView setHidden:YES];
                            //2. playable button state
                            for (VideoCell *connect_c in ws.QRcv.visibleCells) {
                                [connect_c.playBtn setHidden:NO];
                            }
                            //3. operating state
                            NSLog(@"检测NVR 是否无效 %d",[ws.nvrModel isInvalidated]);
                            
                            if(nav.viewControllers.count > 1) {
                                
                                
                                if([ws.nvrModel.nvr_id isEqualToString:nav.operatingDevice.nvr_id]) { ///nav.operatingDevice，栈顶设备没被更新 还是 损坏的设备！！！！！！！！！！！！！！！！！！！！！！！！！！！！
                                    ws.vc.navigationController.operatingDevice = ws.nvrModel;
//                                    [MBProgressHUD showStatus:CLOUD_DEVICE_STATE_CONNECTED];
                                    ///LP
                                    if ([visibleController isKindOfClass:[PlayVideoController class]]) {
                                        [((PlayVideoController *)visibleController).vp lv_start];
                                    }
                                    ///PB
                                    else if ([visibleController isKindOfClass:[PlaybackViewController class]]) {
                                        [((PlaybackViewController *)visibleController).vp pb_start];
                                    }
                                }
                                 
                            }
                        }  else {
                            [ws.maskView.spinner stopAnimating];
                            [ws.maskView setHidden:NO];
                            ws.maskView.blurEffectView.effect = nil;
                            [UIView animateWithDuration:1.5f delay:0.f usingSpringWithDamping:1.f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                ws.maskView.blurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                                /// uiview（blur effect ) 是透明的
                            } completion:^(BOOL finished) {
                                ;
                            }];
                            
                            for (VideoCell *disconnect_c in ws.QRcv.visibleCells) {
                                [disconnect_c.playBtn setHidden:YES];
                            }
                            
                            if ([ws.nvrModel.nvr_id isEqualToString:nav.operatingDevice.nvr_id] &&  nav.viewControllers.count > 1) {
                                nav.operatingDevice = ws.nvrModel;
                                
                                ///断线提醒
//                                if([visibleController isKindOfClass:[PlayVideoController class]]) {
//                                 ZLPlayerView *vp =   [(PlayVideoController *)visibleController vp];
//                                }
                            
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                MBProgressHUD *hud =   [MBProgressHUD showStatus:CLOUD_DEVICE_STATE_DISCONNECTED];
                                [hud.actionBtn setHidden:NO];
                                [hud.actionBtn addTarget:ws.vc.navigationController action:@selector(reconnect:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                            
                            if ([property.value intValue] ==  CLOUD_DEVICE_STATE_DISCONNECTED) {
                                [ws.maskView.statusLabel setText:LS(@"断开连接")];
                            }else if ([property.value intValue] == CLOUD_DEVICE_STATE_AUTHENTICATE_ERR) {
                                [ws.maskView.statusLabel setText:LS(@"授权错误")];
                            }else if ([property.value intValue] == CLOUD_DEVICE_STATE_OTHER_ERR) {
                                [ws.maskView.statusLabel setText:LS(@"其他错误")];
                            }else if ([property.value intValue] == CLOUD_DEVICE_STATE_UNKNOWN) {
                                [ws.maskView.statusLabel setText:LS(@"正在获取设备状态...")];
                                [ws.maskView.spinner startAnimating];
                            }
                            
//                            else if ([property.value intValue] == CLOUD_DEVICE_STATE_UNINITILIZED) {
//                                [ws.maskView.statusLabel setText:@"网络连接断开！！请检查网络"];
//                                [ws.maskView.spinner stopAnimating];
//
//                            }
                        }
                        
                    }
                    /**
                     The value of the property after the change occurred. This will always be `nil`
                     for `RLMArray` properties.
                     */
                    else if ([property.name isEqualToString:@"nvr_cams"]) {
                        [ws.QRcv reloadData];
//                        NSLog(@"-------------------- QRCV RELOAD CAM表 --------------------- %@",[Cam allObjects]);
                    }
                    ///3. name changed
                    else if ([property.name isEqualToString:@"nvr_name"]) {
                        [ws.footer.deviceLb setText:property.value];
                    }
                }
            }
        }];
        cloud_set_status_callback((void *)nvrModel.nvr_h,my_device_status_callback,(__bridge void *)self);
        [self.footer.deviceLb setText:nvrModel.nvr_name];
        [self.nvrModel threadReslove:^(RLMObject *reslovedObj) {
            Device *reslovedDevice = (Device *) reslovedObj;
            cloud_connect_device((void *)reslovedDevice.nvr_h, "admin", "123"); ///connect 就是添加操作
        }];
    }
}

- (void)setPath:(NSIndexPath *)path {
    if(_path != path) {
        _path = path;
        [RLM beginWriteTransaction];
        self.nvrModel.nvr_index = (int)path.section;
        [RLM commitWriteTransaction];
    }
}

///动态设置每个Item的尺寸大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.nvrModel.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
//        return CGSizeMake(AM_SCREEN_WIDTH , 201);
        return CGSizeMake(AM_SCREEN_WIDTH , COLLECTION_VIEW_H);
    }else {
//        return CGSizeMake((AM_SCREEN_WIDTH - 1 ) / 2, 100);
        return CGSizeMake(ITEM_W, ITEM_H);
    }
}

///动态设置每行的间距大小
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {

     return ITEM_INTER_SPACING;
}

///动态设置每列的间距大小
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return ITEM_INTER_SPACING;
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

- (ZLMaskView *)maskView {
    
    if(!_maskView) {
        _maskView = [ZLMaskView new];
    }
    return _maskView;
}
#pragma mark - getter
- (DeviceFooter *)footer {
    
    if (!_footer) {
        
        _footer = [[DeviceFooter alloc] init];
        WS(self);
        __weak typeof (_footer) weak_footer = _footer;
        
        weak_footer.setNvr = ^(DeviceFooter *footer){
            QRootElement *rootForm = [[DataBuilder new] createForNvrSettings:ws.nvrModel]; //创建数据
            NvrSettingsController *nvrSettingsVc = [[NvrSettingsController alloc] initWithRoot:rootForm];
            [ws.vc.navigationController pushViewController:nvrSettingsVc deviceModel:ws.nvrModel camModel:nil];
            nvrSettingsVc .deleteNvr = ^{
                Popup *p = [[Popup alloc] initWithTitle:LS(@"提示") subTitle:LS(@"请确认是否需要删除该设备？") cancelTitle:LS(@"取消") successTitle:LS(@"确认") cancelBlock:nil successBlock:^{
                    [(MainViewController *)ws.vc deleteNvr:[NSIndexPath indexPathForRow:0 inSection:ws.path.section]];///nvrModel.nvr_index
                }];
                
                [p setIncomingTransition:PopupIncomingTransitionTypeFallWithGravity];
                [p setBackgroundBlurType:PopupBackGroundBlurTypeDark];
                [p showPopup];
            };
        };
        
        
        weak_footer.entryMedias = ^(DeviceFooter *footer) {
            [ws.vc.navigationController pushViewController:[LibraryController new] deviceModel:ws.nvrModel camModel:nil];
        };
    }
    return _footer;
}
@end
