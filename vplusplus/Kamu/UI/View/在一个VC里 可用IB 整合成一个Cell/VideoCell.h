//
//  VideoCell.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/11.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"


@interface VideoCell : UICollectionViewCell

//设置数据 model
@property (nonatomic, strong) Cam *cam;

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIImageView *playableView;
@property (nonatomic, strong) UILabel *camLabel;
//@property (nonatomic, assign) int nvr_status;
@property (nonatomic, strong) UIImageView *bgView;

//@property (nonatomic, copy)   void(^deleteCam)(Cam *cam);

@end
