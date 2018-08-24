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


#import "KMReqest.h"
#import "UIView+rotate.h"

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

// NSString *reuseID = [NSString stringWithFormat:@"%@",@"reuseId"]; //// if rid = indexpath every time cell reuse!!
static NSString *reuseID = @"reuseId";
@implementation QRResultCell
///对方添加 删除 cam 会掉线！
int my_device_status_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {
    
    QRResultCell *c_self = (__bridge QRResultCell *)context;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(c_self.nvrModel.nvr_id && type == CLOUD_CB_STATE) {
            cloud_device_state_t state = *((cloud_device_state_t *)param);
            
            
               
                [c_self.nvrModel asyncThreadReslove:^(RLMObject *reslovedObj) {
                    [RLM beginWriteTransaction];
                    [(Device *)reslovedObj setNvr_status:state];
                    [RLM commitWriteTransaction];
                }];
            
         
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//            });
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
   
    NSString *uniq_tag = [NSString stringWithFormat:@"%zd/%zd",(long)indexPath.section,(long)indexPath.item]; ///释放
    [self.QRcv registerClass:[VideoCell class] forCellWithReuseIdentifier:uniq_tag];
    VideoCell *videoCell = [self.QRcv dequeueReusableCellWithReuseIdentifier:uniq_tag forIndexPath:indexPath];
    NSLog(@" 第%@个 video cell🏆%@ ",indexPath,videoCell);
    
    // For each reuse identifier that the collection view will use, register either a class or a nib from which to instantiate a cell.
    // If a nib is registered, it must contain exactly 1 top level object which is a UICollectionViewCell.
    // If a class is registered, it will be instantiated via alloc/initWithFrame:
    
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
//                    [self.nvrModel.nvr_cams replaceObjectAtIndex:i withObject:db_cam]; /// if other app delete

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

- (void)open_db_Device:(Device *)nvrModel{
    long h =  (long) cloud_open_device([nvrModel.nvr_id UTF8String]);
    if(h) {
        [RLM transactionWithBlock:^{
            [nvrModel setNvr_h:h];
        }];
    }
}
- (void)reset_db_device_state:(Device *)nvrModel {
    [RLM transactionWithBlock:^{
        [nvrModel setNvr_status:CLOUD_DEVICE_STATE_UNKNOWN];
    }];
}
- (void)setNvrModel:(Device *)nvrModel {
    if (nvrModel && _nvrModel != nvrModel ) { ///指针虽然不一样 但是设备是一样的！！！！！！！！！！！！ 这里会重复 open 设备！！
        [self.footer.deviceLb setText:nvrModel.nvr_name];
        ///---------- DB -------------
        WS (self);
        _device_token = [nvrModel addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
            if (deleted) {
                NSLog(@"%@",[NSThread currentThread]);
                [MBProgressHUD showSuccess:@"REALM 监听 删除成功"];
            }else {
                for (RLMPropertyChange *property in changes) {
                    NSLog(@"--------------- %@ DEVICE CHANGED %@ : value = %@ ---------------",ws.nvrModel,property.name, property.value);
                    if ([property.name isEqualToString:@"nvr_status"] ) {
                        cloud_device_state_t currentState = [property.value intValue];
                        cloud_device_state_t previousState = [property.previousValue intValue];
            
                        
                        
                        if (currentState != CLOUD_DEVICE_STATE_UNKNOWN && previousState != CLOUD_DEVICE_STATE_CONNECTED && ![USER.user_id isEqualToString:@"-1"]) {
                            
                            ///连接之后返回的状态---- maybe  随时 会被删除  ，在每次连接状态后 check 是否 是云端设备  --  !weak_nvrModel.nvr_isCloud &&
//                            [self.footer.syncLable setText:@"(checking...)"];
                            [self.footer.syncedIcon setImage:[UIImage imageNamed:@"syncing"]];
                            [self.footer.syncedIcon setHidden:NO];
                            [self.footer.syncedIcon rotateWithDuration:2.f repeatCount:MAXFLOAT timingMode:TimingModeEaseInEaseOut];
                            [[NetWorkTools new] request:GET urlString:KM_API_URL(@"profile") parameters:nil finished:^(id responseDict, NSString *errorMsg) {
                                User *response_user =  [User mj_objectWithKeyValues:responseDict];
                                if(response_user && [response_user.user_id isEqualToString:USER.user_id]) {
                                    for (Device *response_device in response_user.user_devices) {
                                        if ([response_device.nvr_id isEqualToString:self.nvrModel.nvr_id]) {
                                            [ws.footer.syncedIcon setImage:[UIImage imageNamed:@"synced"]];
//                                            [self.footer.syncLable setText:@"(R)"];
///                                            [weak_nvrModel setNvr_isCloud:YES];   访问的还 是nvrModel
                                            [ws.nvrModel setNvr_isCloud:YES];
                                        }
                                    }
                                    if ([self.footer.syncedIcon.image isEqual:[UIImage imageNamed:@"syncing"]]) {
                                        [ws.footer.syncedIcon setImage:[UIImage imageNamed:@"warning"]];
//                                        [self.footer.syncLable setText:@"(L)"];
                                        [ws.nvrModel setNvr_isCloud:NO];
                                    }
                                    [ws.footer.syncedIcon.layer removeAnimationForKey:@"transform"];
//                                    [ws.footer.syncedIcon.layer removeAllAnimations];

                                }else {
                                    [self.footer.syncLable setText:@"(cheking fail!)"];
                                }
                            }];
                        }
                        
                        
                        
                        
                        currentState == CLOUD_DEVICE_STATE_CONNECTED ? [self deviceConnected] : [self deviceDisconnected:currentState previousState:previousState];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"STATUS" object:property.value];
                    }
                    else if ([property.name isEqualToString:@"nvr_cams"]) {
                        [ws.QRcv reloadData];
                    }
                    else if ([property.name isEqualToString:@"nvr_name"]) {
                        [ws.footer.deviceLb setText:property.value];
                    }
                }
            }
        }];
        
               ///---------- TUTK -------------
        [self open_db_Device:nvrModel];
        cloud_set_status_callback((void *)nvrModel.nvr_h,my_device_status_callback,(__bridge void *)self);
        cloud_connect_device((void *)nvrModel.nvr_h, "admin", "123");///connect 就是添加操作 , 同步Logo 旋转
        [self reset_db_device_state:nvrModel];
      
        _nvrModel = nvrModel; /// if _nvrModel has value , reuseid cell will override it

    }
}
- (void)deviceConnected {
  UINavigationController *nav = self.vc.navigationController;
    /// __imp_ = (__imp_ = "The Realm is already in a write transaction")
    dispatch_async(dispatch_get_main_queue(), ^{
        [self upadteCams];
    });
    [self.maskView setHidden:YES];
    if(nav.viewControllers.count > 1) {
        if([self.nvrModel.nvr_id isEqualToString:nav.operatingDevice.nvr_id]) { ///nav.operatingDevice，栈顶设备没被更新 还是 损坏的设备！！！！！！！！！！！！！！！！！！！！！！！！！！！！
            self.vc.navigationController.operatingDevice = self.nvrModel;
            if ([nav.visibleViewController isKindOfClass:[PlayVideoController class]]) {
                [((PlayVideoController *)nav.visibleViewController).vp lv_start];
            } else if ([nav.visibleViewController isKindOfClass:[PlaybackViewController class]]) {
                [((PlaybackViewController *)nav.visibleViewController).vp pb_start];
            }
        }
        
    }
}

- (void)deviceDisconnected:(cloud_device_state_t)currentState previousState:(cloud_device_state_t)previousState {
    UINavigationController *nav = self.vc.navigationController;
    [self.maskView.spinner stopAnimating];
    [self.maskView setHidden:NO];
    self.maskView.blurEffectView.effect = nil;
    [UIView animateWithDuration:1.5f delay:0.f usingSpringWithDamping:1.f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.maskView.blurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        /// uiview（blur effect ) 是透明的
    } completion:nil];
    if (nav.viewControllers.count > 1) {
        
        if ([self.nvrModel.nvr_id isEqualToString:nav.operatingDevice.nvr_id]) {
            nav.operatingDevice = self.nvrModel;
            MBProgressHUD *hud =   [MBProgressHUD showStatus:CLOUD_DEVICE_STATE_DISCONNECTED];
            [hud.actionBtn setHidden:NO];
            [hud.actionBtn addTarget:self.vc.navigationController action:@selector(reconnect:) forControlEvents:UIControlEventTouchUpInside];
        }
       
    }
    if (currentState ==  CLOUD_DEVICE_STATE_DISCONNECTED) {
        [self.maskView.statusLabel setText:LS(@"断开连接")];
    }else if (currentState == CLOUD_DEVICE_STATE_AUTHENTICATE_ERR) {
        [self.maskView.statusLabel setText:LS(@"授权错误")];
    }else if (currentState == CLOUD_DEVICE_STATE_OTHER_ERR) {
        [self.maskView.statusLabel setText:LS(@"其他错误")];
    }else if (currentState == CLOUD_DEVICE_STATE_UNKNOWN) {
        [self.maskView.statusLabel setText:LS(@"正在获取设备状态...")];
        [self.maskView.spinner startAnimating];

        if (![USER.user_id isEqualToString:@"-1"]) {
//            [self.footer.syncLable setText:@"(adding..)"];
//            [self.footer.syncedIcon setImage:[UIImage imageNamed:@"syncing"]];
//            [self.footer.syncedIcon rotateWithDuration:2.f repeatCount:MAXFLOAT timingMode:TimingModeEaseInEaseOut];
            [self.footer.syncedIcon setHidden:YES];
        }
        
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
                    [(MainViewController *)ws.vc deleteNvr:ws.nvrModel];///nvrModel.nvr_index
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
