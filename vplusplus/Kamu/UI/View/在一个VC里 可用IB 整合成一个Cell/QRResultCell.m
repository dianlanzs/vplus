//
//  QRResultCell.m
//  Kamu
//
//  Created by YGTech on 2017/12/7.
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






@end


@implementation QRResultCell



- (void)updateNvr:(void *)nvrHandle withState:(cloud_device_state_t)state  {

    
    if (nvrHandle == (void *)self.nvrModel.nvr_h) {
        [self.spinner stopAnimating];
        if (state == CLOUD_DEVICE_STATE_CONNECTED) {
            [self upadteCams];
            [self.maskView setHidden:YES];
        } else {
            if (state ==  CLOUD_DEVICE_STATE_DISCONNECTED) {
                [self.statusLabel setText:@"DISCONNECT"];
            }else if (state == CLOUD_DEVICE_STATE_AUTHENTICATE_ERR) {
                [self.statusLabel setText:@"AUTHENTICATE_ERR"];
            }else if (state == CLOUD_DEVICE_STATE_OTHER_ERR) {
                [self.statusLabel setText:@"OTHER_ERR"];
            }else if (state == CLOUD_DEVICE_STATE_UNKNOWN) {
                [self.statusLabel setText:@"STATE_UNKNOWN"];
            }
            
            [self.maskView setHidden:NO];
        }
        
        [RLM transactionWithBlock:^{
            self.nvrModel.nvr_status = state;
        }];
        [self.QRcv reloadData];
    }
  
}

#pragma mark - 生命周期
// Designated initializer.  If the cell can be reused, you must pass in a reuse identifier.  You should use the same reuse identifier for all cells of the same form.  
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.QRcv];
        [self.QRcv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(0.f);
            make.leading.equalTo(self.contentView).offset(0.0f);
            make.trailing.equalTo(self.contentView).offset(-0.0f);
            make.bottom.equalTo(self.contentView).offset(0.f);
        }];
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
//    [self.layer setCornerRadius:5.f];
//    [self.layer setMasksToBounds:YES];
    return self;
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
            searchedCam.cam_h = ipc_info[i].index;
            
            RLMArray *db_cams = self.nvrModel.nvr_cams;
            Cam *db_cam =  [[db_cams objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",searchedCam.cam_id]] firstObject];
            if (!db_cam) {
                [RLM transactionWithBlock:^{
                    [self.nvrModel.nvr_cams addObject:searchedCam]; //if 别人往中继 添加cam？？
                }];
            }
            
        }
        
    }
    
}


- (void)setNvrModel:(Device *)nvrModel {
    
    if (_nvrModel != nvrModel) {
        [RLM transactionWithBlock:^{
            nvrModel.nvr_h = (long)cloud_create_device([nvrModel.nvr_id UTF8String]);
            nvrModel.nvr_status = CLOUD_DEVICE_STATE_UNKNOWN;
        }];
        
        _nvrModel = nvrModel;
        cloud_set_data_callback((void *)nvrModel.nvr_h, my_device_callback, (__bridge void *) self);
        cloud_set_status_callback((void *)nvrModel.nvr_h,my_device_callback,(__bridge void *) self);
        cloud_set_event_callback((void *)nvrModel.nvr_h, my_device_callback,(__bridge void *) self);
        
        
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.equalTo(self).offset(10.f);
//            make.trailing.equalTo(self).offset(-10.f);
//            make.top.equalTo(self).offset(0.f);
//            make.bottom.equalTo(self).offset(-0.f);
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
    }
    
}

int my_device_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {
    
    Device *d = [[Device alloc] init];
    QRResultCell *ctx = (__bridge QRResultCell *)context;

    if (type == CLOUD_CB_STATE) {
        cloud_device_state_t state = *((cloud_device_state_t *)param);
        dispatch_async(dispatch_get_main_queue(), ^{
            [ctx updateNvr:handle withState:state];
        });
    }
    
    else if (type == CLOUD_CB_VIDEO || type == CLOUD_CB_AUDIO ){
        [ctx.nvrModel.delegate device:ctx.nvrModel sendData:param dataType:type];
    }
    
    else if (type == CLOUD_CB_RECORD_LIST) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ctx.nvrModel.delegate device:ctx.nvrModel sendData:param dataType:type];
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
        _statusLabel = [UILabel labelWithText:@"Getting Device Status" withFont:[UIFont systemFontOfSize:20.f] color:[UIColor whiteColor] aligment:NSTextAlignmentCenter];
    }
    return _statusLabel;
}
- (RTSpinKitView *)spinner {
    if (!_spinner) {
        _spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce color:[UIColor whiteColor] spinnerSize:25.f];
        [_spinner setHidesWhenStopped:YES];
        [_spinner startAnimating];
    }
    
    return _spinner;
   
}
@end
