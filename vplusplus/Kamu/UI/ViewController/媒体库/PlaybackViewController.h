//
//  PlaybackViewController.h
//  Kamu
//
//  Created by Zhoulei on 2018/5/23.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPlayerView.h"
@interface PlaybackViewController : UIViewController

@property (strong, nonatomic) ZLPlayerView *vp;
@property (nonatomic, strong) ZLPlayerModel *playerModel;
@end
