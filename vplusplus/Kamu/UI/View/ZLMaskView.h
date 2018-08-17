//
//  ZLMaskView.h
//  Kamu
//
//  Created by YGTech on 2018/8/1.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLMaskView : UIView
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) RTSpinKitView *spinner;
@property (strong, nonatomic) UILabel *statusLabel;
@end
