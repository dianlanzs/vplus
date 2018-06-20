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

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateNotification:) name:@"CLOUD_DEVICE_STATE" object:nil];

}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CLOUD_DEVICE_STATE" object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self vp]; //config vp UI
    if (self.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
        [MBProgressHUD showStatus:DeviceConnected];
        [self.vp pb_start];
    }
    else if (self.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_UNKNOWN) {
        [MBProgressHUD showStatus:DeviceConnecting];
    }else {
        [MBProgressHUD showStatus:DeviceDisconnected];
    }
 
}

- (void)stateNotification:(NSNotification *)notification {
    
    Device *informedDevice = notification.object;
    if ([informedDevice.nvr_id isEqualToString:self.operatingDevice.nvr_id]) {
        if (informedDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
            [MBProgressHUD showStatus:DeviceConnected];
            self.operatingDevice = informedDevice;
            [self.vp pb_start ];
        }else {
            MBProgressHUD *hud =   [MBProgressHUD showStatus:DeviceDisconnected];
            [hud.actionBtn setHidden:NO];
            [hud.actionBtn addTarget:self action:@selector(reconnect:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

- (void)reconnect:(id)sender {
    cloud_connect_device((void *)self.operatingDevice.nvr_h, "admin", "123");
    [sender setHidden:YES];
    [MBProgressHUD showStatus:DeviceConnecting];
}




- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
        if (self.navigationController && self.vp.functionControl.state != ZLPlayerStateEnd) {
            [self.vp pb_pause];
        } else if (!self.navigationController) {
            [self.vp pb_end];
        }
    }
  
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
