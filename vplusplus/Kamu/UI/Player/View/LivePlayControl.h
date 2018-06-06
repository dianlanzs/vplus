//
//  LivePlayControl.h
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonPlayerControl.h"







@interface LivePlayControl :CommonPlayerControl


@property (nonatomic, strong) UIButton                *muteBtn;

@property (nonatomic, strong) UIButton          *speakerBtn_horizental;
@property (nonatomic, strong) MRoundedButton          *speakerBtn_vertical;

@property (nonatomic, strong) UIButton                *recordBtn;
@property (nonatomic, strong) UIButton                *captureBtn;



@property (nonatomic, strong) UIButton                *resolutionBtn;
@property (nonatomic, strong) UIView                  *resolutionView;

@property (nonatomic, strong) UIView                  *functionBar;



@end
