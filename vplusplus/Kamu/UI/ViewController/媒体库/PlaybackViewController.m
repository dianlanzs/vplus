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

@end

@implementation PlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}







- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.vp pb_start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.vp pb_stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.vp setState:ZLPlayerStateStopped];
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
