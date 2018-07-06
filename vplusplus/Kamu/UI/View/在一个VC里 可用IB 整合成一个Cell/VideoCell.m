//
//  VideoCell.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/11.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "VideoCell.h"



@interface VideoCell()



@property (nonatomic, strong) RLMNotificationToken *cam_token;
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

#pragma mark - setter
- (void)setCam:(Cam *)cam {
    
    
    ///check cam pointer is a new cam ?  (maybe cam_id better!)
    if (cam  && cam != _cam ) {
        
        _cam = cam;
        self.cam_token = [cam addNotificationBlock:^(BOOL deleted, NSArray<RLMPropertyChange *> * _Nullable changes, NSError * _Nullable error) {
            if (deleted) {
                NSLog(@"Cam已经删除!");
                [MBProgressHUD showSuccess:@"Cam已经删除!"];
            }else {
                
                for (RLMPropertyChange *property in changes) {
                    if ([property.name isEqualToString:@"cam_name"] ) {
                        [self.camLabel setText:property.value];
                    }
                    
                    else if ([property.name isEqualToString:@"cam_cover"]) {
                        [self.playableView setImage:[UIImage imageWithData:property.value]];
                    }
                    
                    
                }
  
            }
        }];
        

        self.camLabel.text = cam.cam_name ? [cam.cam_name uppercaseString] :[cam.cam_id uppercaseString];
        [self.playableView setImage:[UIImage imageWithData:cam.cam_cover]];
        [self.contentView addSubview:self.playableView];
        [self setupConstraints];
        
        
    }
    
    else if (!cam) {
        [self.playableView removeFromSuperview];
    }
    
    
}
#pragma mark - 设置约束
- (void)setupConstraints {
    
    [self.playableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.leading.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
        if (self.cam.nvrs.count == 1) {
            
            Device *d = self.cam.nvrs.firstObject;
            if (d.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
                make.height.equalTo(@201);
            }else if (d.nvr_type == CLOUD_DEVICE_TYPE_GW) {
                make.height.equalTo(@100);
            }
            
        }
    }];
    
    [self.camLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(0);
        make.height.equalTo(@30);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playableView);
        
        if (self.cam.nvrs.count == 1) {
            
            
            Device *d = self.cam.nvrs.firstObject;
            if (d.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
                make.size.mas_equalTo(CGSizeMake(80.0f ,80.0f));
            }else if (d.nvr_type == CLOUD_DEVICE_TYPE_GW) {
                make.size.mas_equalTo(CGSizeMake(40.0f ,40.0f));

            }
            
            
            
        }
    }];
}


#pragma mark - Required!!
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
        [_playableView addSubview:self.playBtn];
        [_playableView addSubview:self.camLabel];
    }
    return _playableView;
}

- (UILabel *)camLabel {
    if (!_camLabel) {
        _camLabel = [UILabel labelWithText:@"" withFont:[UIFont systemFontOfSize:14] color:[UIColor colorWithHex:@"#fcfcfc"] aligment:NSTextAlignmentCenter];
    }
    return _camLabel;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"mp_play_center"] forState:UIControlStateNormal];//mp_play_center  youtube_play_center
        [_playBtn setHidden:YES];
    }
    return _playBtn;
}
@end
