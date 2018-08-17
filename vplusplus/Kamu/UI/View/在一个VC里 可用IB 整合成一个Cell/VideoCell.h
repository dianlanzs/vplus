//
//  VideoCell.h
//  Kamu
//
//  Created by Zhoulei on 2017/12/11.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"


#define ITEM_INTER_SPACING 1
#define ITEMS_PER_LINE 2
#define ITEM_W ((AM_SCREEN_WIDTH - ITEM_INTER_SPACING ) / ITEMS_PER_LINE)
#define ITEM_SCALE 0.5625
#define ITEM_H (ITEM_W * ITEM_SCALE)
#define FOOTER_H 40
#define COLLECTION_VIEW_H (ITEM_H * 2 + ITEM_INTER_SPACING)


#define BUTTON_H 40
#define LABEL_H 30

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
