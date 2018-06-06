//
//  LivePlayControl.m
//  Kamu
//
//  Created by YGTech on 2018/6/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "LivePlayControl.h"

@implementation LivePlayControl


- (UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordBtn setImage:ZLPlayerImage(@"button_recordScreen") forState:UIControlStateNormal];
        [_recordBtn setImage:ZLPlayerImage(@"button_recording") forState:UIControlStateSelected];
        
        [_recordBtn addTarget:self action:@selector(recordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}
- (void)recordBtnClick:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
//    [self.delegate zl_controlView:self recordVideoAction:sender];
}

- (UIButton *)captureBtn {
    if (!_captureBtn) {
        _captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captureBtn setImage:ZLPlayerImage(@"button_capture") forState:UIControlStateNormal];
        [_captureBtn addTarget:self action:@selector(captureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _captureBtn;
    
}
- (void)captureBtnClick:(UIButton *)sender {
//    [self.delegate zl_controlView:self snapAction:sender]
}

- (UIButton *)muteBtn {
    if (!_muteBtn) {
        
        _muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteBtn setImage:ZLPlayerImage(@"btn_speaker") forState:UIControlStateNormal];
        [_muteBtn setImage:ZLPlayerImage(@"btn_mute") forState:UIControlStateSelected];
        [_muteBtn addTarget:self action:@selector(muteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_muteBtn setSelected:YES];//for mute default
    }
    return _muteBtn;
}

- (void)muteBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.delegate zl_controlView:self muteAction:sender];
}


- (UIButton *)speakerBtn_horizental {
    if (!_speakerBtn_horizental) {
        _speakerBtn_horizental = [UIButton buttonWithType:UIButtonTypeCustom];
        [_speakerBtn_horizental setImage:ZLPlayerImage(@"speaker") forState:UIControlStateNormal];
        [self setActionForSpeaker:(UIButton *)_speakerBtn_horizental];
    }
    return _speakerBtn_horizental;
}
- (MRoundedButton *)speakerBtn_vertical {
    
    if (!_speakerBtn_vertical) {
        _speakerBtn_vertical = [[MRoundedButton alloc] initWithFrame:CGRectZero buttonStyle:MRoundedButtonCentralImage];
        [_speakerBtn_vertical setTag:1001];
        [_speakerBtn_vertical setSelected:NO];
        [_speakerBtn_vertical setBorderColor:[UIColor lightGrayColor]];
        [_speakerBtn_vertical setCornerRadius:FLT_MAX];
        [_speakerBtn_vertical setForegroundColor:[UIColor lightGrayColor]];
        [_speakerBtn_vertical setContentColor:[UIColor whiteColor]];
        [_speakerBtn_vertical setForegroundAnimateToColor:[UIColor blueColor]];
        [_speakerBtn_vertical.imageView setImage:[UIImage imageNamed:@"button_micophone_normal"]];
        [self setActionForSpeaker:(UIButton *)_speakerBtn_vertical];
        
        [_speakerBtn_vertical setRestoreSelectedState:YES];
        [_speakerBtn_vertical setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }
    return _speakerBtn_vertical;
}
- (void)setActionForSpeaker:(UIButton *)sender {
    [sender addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
    [sender addTarget:self action:@selector(recordEnd:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(recordCancel:) forControlEvents:UIControlEventTouchUpOutside];
}
- (void)recordStart:(UIButton *)sender{
    [self.delegate recordStart:sender];
}
- (void)recordEnd:(UIButton *)sender {
    [self.delegate recordEnd:sender];
}
- (void)recordCancel:(UIButton *)sender {
    [self.delegate recordCancel:sender];
}

- (void)remakeConstrints {
    [self.bottomImageView addSubview:self.captureBtn];
    [self.captureBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomImageView);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.bottomImageView addSubview:self.speakerBtn_vertical];
    
    
    [self.bottomImageView addSubview:self.muteBtn];
    [self.muteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomImageView);
        make.width.height.mas_equalTo(30);
    }];
    [self.bottomImageView addSubview:self.recordBtn];
    [self.recordBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomImageView);
        make.width.height.mas_equalTo(30);
    }];
}
- (void)setFullScreen:(BOOL)fullScreen {
    
    [super setFullScreen:fullScreen];
    if (fullScreen) {
        [self remakeConstrints];
        [self.speakerBtn_vertical mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomImageView).offset(0);
            make.height.width.mas_equalTo(60);
        }];
         [self.bottomImageView distributeSpacingHorizontallyWith:@[self.recordBtn,self.captureBtn,self.speakerBtn_vertical,self.muteBtn,self.fullScreenBtn]];
        
       
    }else {
        [self remakeConstrints];
        [self.bottomImageView distributeSpacingHorizontallyWith:@[self.recordBtn,self.captureBtn,self.muteBtn,self.fullScreenBtn]];
        
        
        
        [self.speakerBtn_vertical mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomImageView).offset(260);
            make.centerX.equalTo(self.bottomImageView).offset(0);
            make.height.width.mas_equalTo(60);
        }];
    }
   
     [self showControl];
}


- (void)resetControl {
    [super resetControl];
    [self.muteBtn setSelected:YES];
}

- (void)hideControl {
    
    if (!self.isFullScreen) {
        [self setOtherButtonsAlpha:0];
    }else {
        [super hideControl];
    }
    [self setShowing:NO];
}

- (void)showControl {
    if (!self.isFullScreen) {
        [self setOtherButtonsAlpha:1];
    }else {
         [super showControl];
    }
     [self setShowing:YES];
}




- (void)setOtherButtonsAlpha:(CGFloat)alpha {
    for (UIButton *subButton in self.bottomImageView.subviews) {
        if (subButton.tag != 1001) {
            NSLog(@"%@",subButton);
            [subButton setAlpha:alpha];
        }
    }
}
@end
