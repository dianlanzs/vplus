//
//  PlaybackViewController.m
//  Kamu
//
//  Created by Zhoulei on 2018/5/23.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "PlaybackViewController.h"

#import "ZLPlayerModel.h"


#import "CommonPlayerControl.h"
#import "PlaybackControl.h"
@interface PlaybackViewController ()
@property (nonatomic, strong) Device *device;
@end

@implementation PlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CLOUD_DEVICE_STATE" object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self vp]; //config vp UI
    if (self.navigationController.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
        [self.vp pb_start];
        cloud_set_data_callback((void *)self.navigationController.operatingDevice.nvr_h, device_data_callback, (__bridge void *)self.vp);
    }
}




- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED && self.vp.functionControl.state != ZLPlayerStateEnd) {
        [self.vp pb_pause];
        cloud_set_data_callback((void *)self.navigationController.operatingDevice.nvr_h, nil, nil);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark - getter
- (ZLPlayerView *)vp {
    if (!_vp) {
        _vp = [[ZLPlayerView alloc] initWithModel:self.playerModel control:[PlaybackControl new]  controller:self];
    }
    return _vp;
}

- (ZLPlayerModel *)playerModel {
    if (!_playerModel) {
        _playerModel = [ZLPlayerModel new];
    }
    return _playerModel;
}


@end
