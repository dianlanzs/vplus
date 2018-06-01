//
//  PlaybackViewController.m
//  Kamu
//
//  Created by Zhoulei on 2018/5/23.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "PlaybackViewController.h"

#import "ZLPlayerModel.h"
@interface PlaybackViewController ()

@end

@implementation PlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}







- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.vp fireTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.vp invalidTimer];
    cloud_device_cam_pb_stop((void *)self.playerModel.nvr_h,[self.playerModel.cam_id UTF8String]);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark - getter
- (ZLPlayerView *)vp {
    if (!_vp) {
        _vp = [[ZLPlayerView alloc] initWithModel:self.playerModel controller:self];
        [_vp.controlView.bottomImageView setHidden:YES];
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
