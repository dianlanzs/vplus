//
//  LoginViewController.m
//  Kamu
//
//  Created by YGTech on 2017/12/13.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "LoginViewController.h"
#import "ZLPlayerControlView.h"

#import "ZLPlayerView.h"



@interface LoginViewController ()




/** 播放器View的父视图*/
@property (strong, nonatomic)  IBOutlet UIView *playerFatherView;
@property (strong, nonatomic) ZLPlayerView *playerView;
@property (nonatomic, strong) ZLPlayerModel *playerModel;
/** 离开页面时候是否在播放 */
@property (nonatomic, assign) BOOL isPlaying;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.playerFatherView];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 返回值要必须为NO
- (BOOL)shouldAutorotate {
    return NO;
}



#pragma mark - PlayerView  代理方法

- (void)zl_playerBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (UIView *)playerFatherView {
    
    if (!_playerFatherView) {
        
        _playerFatherView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, AM_SCREEN_WIDTH, 200)];
        [_playerFatherView setBackgroundColor:[UIColor darkGrayColor]];
        [_playerFatherView addSubview:self.playerView];
        
        [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_playerFatherView).insets(UIEdgeInsetsZero);
        }];
    }
    
    return _playerFatherView;
}





#pragma mark - Getter

- (ZLPlayerModel *)playerModel {
    
    if (!_playerModel) {
        
        
        _playerModel                  = [[ZLPlayerModel alloc] init];
        _playerModel.title            = @"这里设置视频标题XX";
//        _playerModel.videoURL         = self.videoURL;
        
        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        _playerModel.fatherView       = self.playerFatherView;
        //        _playerModel.resolutionDic = @{@"高清" : self.videoURL.absoluteString,
        //                                       @"标清" : self.videoURL.absoluteString};
    }
    
    
    return _playerModel;
}

- (ZLPlayerView *)playerView {
    
    if (!_playerView) {
        _playerView = [[ZLPlayerView alloc] init];
        [_playerView playerControlView:nil playerModel:self.playerModel];
        
        // 设置代理
//        _playerView.delegate = self;
        
        //（可选设置）可以设置视频的填充模式，内部设置默认（ZLPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = ZLPlayerLayerGravityResize;
        
        // 打开下载功能（默认没有这个功能）
//        _playerView.hasDownload    = YES;
        
        // 打开预览图
//        _playerView.hasPreviewView = YES;
        
        //        _playerView.forcePortrait = YES;
        /// 默认全屏播放
        //        _playerView.fullScreenPlay = YES;
        
    }
    return _playerView;
}
@end
