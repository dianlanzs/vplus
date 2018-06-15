//
//  AMViewController.m
//  Kamu
//
//  Created by Zhoulei on 2017/11/16.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "AMViewController.h"


#import "NSObject+RACSelectorSignal.h"
#import "RACSignal.h"

@implementation AMViewController

//+ (instancetype)allocWithZone:(struct _NSZone *)zone {
//
//    //创建base viewController
//    AMViewController *baseVc = [super allocWithZone:zone];
//
//    //订阅 'viewDidLoad' 信号
//    [[baseVc rac_signalForSelector:@selector(viewDidLoad)] subscribeNext:^(RACTuple * _Nullable x) {
//        [baseVc initView];
//        [baseVc initData];
//        [baseVc bindViewModel];
//    }];
//
//
//
//    //订阅 'viewWillAppear' 信号
//    [[baseVc rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(RACTuple * _Nullable x) {
//        [baseVc relayout];
//        [baseVc refreshData];
//    }];
//
//
//
//
//    return baseVc;
//}


- (MediaEntity *)operatingMedia {
    if (!_operatingMedia) {
        _operatingMedia = [MediaEntity new];
    }
    return _operatingMedia;
}

- (Device *)operatingDevice {
    if (!_operatingDevice) {
        _operatingDevice = [Device new];
    }
    return _operatingDevice;
}

- (Cam *)operatingCam {
    if (!_operatingCam) {
        _operatingCam = [Cam new];
    }
    return _operatingCam;
}
@end
