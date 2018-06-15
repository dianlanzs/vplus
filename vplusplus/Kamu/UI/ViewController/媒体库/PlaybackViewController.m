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

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self vp];

    if (self.operatingDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
          [self.vp pb_start];
    }
 
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
   
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@,%@",self.vp,self.navigationController); //<zlplayerview: 0x1041e3e30>,<AMNavigationController: 0x105033600>

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

- (void)dealloc {
    ;
}
@end
