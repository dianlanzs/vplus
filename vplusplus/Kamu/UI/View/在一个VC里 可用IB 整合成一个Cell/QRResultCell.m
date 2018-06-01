//
//  QRResultCell.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/7.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "QRResultCell.h"
#import "NSString+StringFrame.h"
#import "PlayVideoController.h"
#import "ReactiveObjC.h"


@interface QRResultCell()<UICollectionViewDelegate,UICollectionViewDataSource>

//设备信息
@property (strong, nonatomic) UIImageView *deviceLogo;
//@property (nonatomic, strong) UIView *topView;
//播放视图
@property (strong, nonatomic) UICollectionViewFlowLayout *QRflowLayout;


//顶部Bar

@property (strong, nonatomic) UIButton *settingsBtn;
@property (nonatomic, strong) UIImageView *idIcon;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) RLMNotificationToken *token;




@end


@implementation QRResultCell

int my_device_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {

    Device *d = [Device new];
    QRResultCell *ctx = (__bridge QRResultCell *)context;
    
    if (type == CLOUD_CB_STATE) {
        cloud_device_state_t state = *((cloud_device_state_t *)param);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"设备状态改变");
            [RLM transactionWithBlock:^{
                   ctx.nvrModel.nvr_status = state;
            }];

        });
    }
    
    else if (type == CLOUD_CB_VIDEO || type == CLOUD_CB_AUDIO ){
        [ctx.nvrModel.avDelegate device:ctx.nvrModel sendAvData:param dataType:type];
    }
    
    else if (type == CLOUD_CB_RECORD_LIST) {
//        record_filelist_t *info = (record_filelist_t *)param;
//        int i;
//        for (i=0;i<info->num;i++) {
//            printf("id %d: %s - %d \n",i,info->blocks[i].filename,info->blocks[i].createtime);
//        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [ctx.nvrModel.listDelegate device:ctx.nvrModel sendListData:param dataType:type];
            
        });
    }
    
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
    return 0;
}
//
//- (void)updateNvr:(void *)nvrHandle withState:(cloud_device_state_t)state  {
//}

#pragma mark - 生命周期
// Designated initializer.  If the cell can be reused, you must pass in a reuse identifier.  You should use the same reuse identifier for all cells of the same form.  
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.footer];
        [self.contentView addSubview:self.QRcv];
        [self.footer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.contentView.bounds), 40.f));
        }];
        [self.QRcv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(0.f);
            make.leading.equalTo(self.contentView).offset(0.0f);
            make.trailing.equalTo(self.contentView).offset(-0.0f);
            make.bottom.mas_equalTo(self.footer.mas_top).offset(0.f);
        }];
        
        
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self shadow];

    return self;
}
- (void)shadow {
    self.layer.shadowOffset = CGSizeMake(1, 1);  //x 方向向右偏移0  ，y 方向向上偏移5 ，负为向上偏移
    self.layer.shadowOpacity = 0.4f; ///阴影透明度
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}

//TURN OUT：删除cell  will call dealloc 
- (void)dealloc {
    [self.token invalidate];
}
- (DeviceFooter *)footer {
    if (!_footer) {
        _footer = [[DeviceFooter alloc] init];
    }
    return _footer;
}

#pragma mark - 视图数据源和代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.nvrModel.nvr_cams.count < 4 ? 4 : self.nvrModel.nvr_cams.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"2");
    //会注册多次，可以不使用 reuseID
    [self.QRcv registerClass:[VideoCell class] forCellWithReuseIdentifier: [NSString stringWithFormat:@"%@",indexPath]];
    VideoCell *videoCell = [self.QRcv dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"%@",indexPath] forIndexPath:indexPath];
    videoCell.nvr_status = self.nvrModel.nvr_status;
    
    if (indexPath.item < self.nvrModel.nvr_cams.count) { //并且 防止数组越界
        [videoCell setCam:self.nvrModel.nvr_cams[indexPath.row]];
    }else {
        [videoCell setCam:nil];
    }
    return videoCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //中途会掉线 
    if (_nvrModel.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
        indexPath.item < self.nvrModel.nvr_cams.count ? self.play(self, indexPath) :  self.add(self, indexPath);
    }
    else if (_nvrModel.nvr_status == CLOUD_DEVICE_STATE_UNKNOWN) {
        [MBProgressHUD showPromptWithText:@"正在连接中...请等待"];
    }else {
        [MBProgressHUD showPromptWithText:@"设备已离线，请检查网络"];
        return;
    }
    
}







#pragma mark - cams
- (void)upadteCams{
    
    device_cam_info_t ipc_info[4];
    int camsNum = cloud_device_get_cams((void *)self.nvrModel.nvr_h, 4, ipc_info);
    NSLog(@"==== 获取Cams:%d ====",camsNum);
    if (camsNum) {
        
        for (NSInteger i = 0; i < camsNum; i++) {
            
            Cam *searchedCam = [Cam new];
            searchedCam.cam_id = [NSString stringWithUTF8String:ipc_info[i].camdid];
            
            RLMArray *db_cams = self.nvrModel.nvr_cams;
            Cam *db_cam =  [[db_cams objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",searchedCam.cam_id]] firstObject];
            if (!db_cam) {
                [RLM transactionWithBlock:^{
                    [self.nvrModel.nvr_cams addObject:searchedCam]; //if 别人往中继 添加cam？？
                }];
            }
            
        }
        
    }
    
    [self.QRcv reloadData];
    
}


- (void)setNvrModel:(Device *)nvrModel {
    
    if (_nvrModel != nvrModel) {
        _nvrModel = nvrModel;
        [RLM transactionWithBlock:^{
            nvrModel.nvr_h = (long)cloud_open_device([nvrModel.nvr_id UTF8String]);
            nvrModel.nvr_status = CLOUD_DEVICE_STATE_UNKNOWN; //from db set status unknown！
        }];
        
        if (!_token) {
            __weak typeof (self) ws = self;
            //add & delete opration can not trigger notification!! cuz its not oberseve self.resluts
            self.token = [nvrModel addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
                if (deleted) {
                    NSLog(@"设备已经删除！");
                }else {
                    for (RLMPropertyChange *property in changes) {
                        if ([property.name isEqualToString:@"nvr_status"] ) {
                            NSLog(@"------------------DEVICE CHANGED STATUS:%@ ------------------",property.value);
                            if ([property.value intValue] == CLOUD_DEVICE_STATE_CONNECTED) {
                                [ws.maskView setHidden:YES];
                                [ws upadteCams];
                            } else {
                                [ws.maskView setHidden:NO];
                                [ws.spinner stopAnimating];
                                if ([property.value intValue] ==  CLOUD_DEVICE_STATE_DISCONNECTED) {
                                    [ws.statusLabel setText:@"DISCONNECT"];
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
                    }
                }
            }];
        }

        
        
        
        cloud_set_pblist_callback((void *)nvrModel.nvr_h, my_device_callback, (__bridge void *) self);
        cloud_set_data_callback((void *)nvrModel.nvr_h, my_device_callback, (__bridge void *) self);

        

        
        
        
        cloud_set_status_callback((void *)nvrModel.nvr_h,my_device_callback,(__bridge void *) self);
        cloud_set_event_callback((void *)nvrModel.nvr_h, my_device_callback,(__bridge void *) self);
        
        
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
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




#pragma mark - getter
- (UICollectionViewFlowLayout *)QRflowLayout {
    
    if (!_QRflowLayout) {
        _QRflowLayout = [[UICollectionViewFlowLayout alloc] init];
        // _QRflowLayout.estimatedItemSize = CGSizeMake(AM_SCREEN_WIDTH , 200); //预估宽高 ，Cell约束高度宽度
        if (@available(iOS 10.0, *)) {
            _QRflowLayout.itemSize = UICollectionViewFlowLayoutAutomaticSize;
        } else {
            // Fallback on earlier versions
        }
        _QRflowLayout.itemSize = CGSizeMake( (AM_SCREEN_WIDTH - 1) * 0.5, 100);
        _QRflowLayout.minimumInteritemSpacing = 1.f;
        _QRflowLayout.minimumLineSpacing = 1.f;
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
        _spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce color:[UIColor whiteColor] spinnerSize:25.f];
        [_spinner setHidesWhenStopped:YES];
    }
    
    return _spinner;
   
}


@end
