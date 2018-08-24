//
//  VideoCell.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/11.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "VideoCell.h"



@interface VideoCell()


//
@property (nonatomic, strong) RLMNotificationToken *cam_token;
@property (nonatomic, strong) Device *cam_owner;
@end



@implementation VideoCell







#pragma mark - 实例化 CollectionView Cell
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundView:self.bgView];
//        [self.layer setCornerRadius:3.f];
//        [self.layer setMasksToBounds:YES];
    }
    return self;
}

///设备状态改变
- (void)stateChanged:(NSNotification *)notification {
    NSNumber *state = notification.object;
    if (!self.playLogo.superview) {
        return;
    }
    if ([state intValue] == CLOUD_DEVICE_STATE_CONNECTED) {
        
        [self.playLogo setHidden:NO];
        ///根视图 刷新
        [self.contentView setNeedsLayout];
        [self.contentView layoutIfNeeded];
        
        
        NSLog(@"%@ 设置播放",self.playLogo);
    }else {
        [self.playLogo setHidden:YES];
    }
}
- (void)dealloc {
    NSLog(@"camToken 释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.cam_token invalidate];
}
#pragma mark - setter
- (void)setCam:(Cam *)cam {
    
    
    ///check cam pointer is a new cam ?  (maybe cam_id better!) ///访问的是 旧的 _cam  cam_id 相同 也有可能是不同对象！！
    
    
//    NSLog(@"%d  -- _cam %@",[cam.cam_id isEqualToString:_cam.cam_id] ,_cam);  ///给 nil 对象发消息 是 nil false   ,给不是nil 发消息 nil ，是 0 false
    
    
    if (cam != _cam) { ///REALM   可以访问 _cam ， 但是不能访问其属性！！！

   
        if (cam ) {
        
            WS(self);
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChanged:) name:@"STATUS" object:nil];
//            if (![cam.cam_id isEqualToString:_cam.cam_id]) {///MARK : cam 和 video cell  一对一 绑定   ,针对 同一个 cam_id  , token 只能设置一次!!
                NSLog(@"设置 Cam Token 💳💳💳💳💳💳💳💳 ");// 0x1701fd90
                _cam_token = [cam addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
                    if (deleted) {
                        NSLog(@"------REALM 监听 %@已经删除!- --------",ws.camLabel.text);
                        [MBProgressHUD showSuccess:[NSString stringWithFormat:@"REALM 监听%@ 已成功删除！",ws.camLabel.text]];
                    }else {
                        for (RLMPropertyChange *property in changes) {
                            NSLog(@"-----------------------CAM%@ CHANGE:%@  ----------------------- ",ws.cam.cam_id, property.name);
                            if ([property.name isEqualToString:@"cam_name"] ) {
                                [ws.camLabel setText:property.value];
                            }
                            else if ([property.name isEqualToString:@"cam_cover"]) {
                                [ws.playableView setImage:[UIImage imageWithData:property.value]];
                                NSLog(@"---------------COVER 字节 %lu",(unsigned long)[(NSData *)property.value length]);
                            }
                        }
                    }
                }];
//            }
  
            _cam = cam;
            self.camLabel.text = cam.cam_name ? [cam.cam_name uppercaseString] :[cam.cam_id uppercaseString];
            [self.playableView setImage:[UIImage imageWithData:cam.cam_cover]];
            [self.contentView addSubview:self.playableView];
            [self.playableView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                if (self.cam.nvrs.count == 1) {
                    if (self.cam_owner.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
                        make.height.mas_equalTo(COLLECTION_VIEW_H);
                    }else if (self.cam_owner.nvr_type == CLOUD_DEVICE_TYPE_GW) {
                        make.height.mas_equalTo(ITEM_H);
                    }
                }
                make.top.leading.trailing.equalTo(self.contentView);
            }];
        }else {
            if (self.playableView.superview) {
                [self.playableView removeFromSuperview];
            }
        }
        
    }
}


#pragma mark - getter

- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        _bgView.backgroundColor = [UIColor lightGrayColor];
        _bgView.image = [UIImage imageNamed:@"icon_add"];
        _bgView.contentMode = UIViewContentModeCenter;
    }
    
    return _bgView;
}


- (UIImageView *)playableView {
    
    if (!_playableView) {
        _playableView = [[UIImageView alloc] init];
        [_playableView setBackgroundColor:[UIColor blackColor]];
        [_playableView addSubview:self.camLabel];
        [self.camLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.equalTo(_playableView);
            make.height.mas_equalTo(LABEL_H);
        }];
        
        [_playableView addSubview:self.playLogo]; ///一定要  先 添加到 playable view  ？
        [self.playLogo mas_makeConstraints:^(MASConstraintMaker *make) {

            if (self.cam.nvrs.count == 1) {
                if (self.cam_owner.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
                    make.size.mas_equalTo(CGSizeMake(BUTTON_H * 2 ,BUTTON_H * 2));
                }else if (self.cam_owner.nvr_type == CLOUD_DEVICE_TYPE_GW) {
                    make.size.mas_equalTo(CGSizeMake(BUTTON_H ,BUTTON_H));
                }
            }
            make.center.equalTo(_playableView);

        }];
        
        
    }
    return _playableView;
}

- (UILabel *)camLabel {
    if (!_camLabel) {
        _camLabel = [UILabel labelWithText:@"" withFont:[UIFont systemFontOfSize:14] color:[UIColor colorWithHex:@"#fcfcfc"] aligment:NSTextAlignmentCenter];
    }
    return _camLabel;
}

- (UIImageView *)playLogo {
    if (!_playLogo) {
        _playLogo = [[UIImageView alloc] init];
        _playLogo.image =[UIImage imageNamed:@"mp_play_center"];
//        [_playLogo setHidden:YES];
    }
    return _playLogo;
}

- (Device *)cam_owner {
    if(!_cam_owner) {
        _cam_owner = self.cam.nvrs.firstObject;
    }
    return _cam_owner;
}
@end
