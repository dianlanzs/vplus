//
//  UIView+PlayerControl.h
//  Kamu
//
//  Created by YGTech on 2018/6/4.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerControlDelegate <NSObject>
@optional


//Common Control
- (void)zl_controlView:(UIView *)controlView backAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView fullScreenAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView lockScreenAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView failAction:(UIButton *)sender;






//Live Control
- (void)zl_controlView:(UIView *)controlView muteAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView speakerAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView snapAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView recordVideoAction:(UIButton *)sender;
- (void)recordStart:(UIButton *)sender;
- (void)recordEnd:(UIButton *)sender;
- (void)recordCancel:(UIButton *)sender;


//Playback Control
- (void)zl_controlView:(UIView *)controlView progressSliderTap:(CGFloat)value;
- (void)zl_controlView:(UIView *)controlView progressSliderTouchBegan:(UISlider *)slider;
- (void)zl_controlView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider;
- (void)zl_controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider;

- (void)zl_controlView:(UIView *)controlView playAction:(UIButton *)sender;
- (void)zl_controlView:(UIView *)controlView repeatPlayAction:(UIButton *)sender;

@end



@interface UIView (PlayerControl)
@property (nonatomic, weak) id<PlayerControlDelegate> delegate;





- (void)zl_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;
- (void)zl_playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview;
- (void)zl_playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image;
- (void)zl_playerDraggedEnd;

- (void)resetCommonControl;
- (void)resetFuncControl;
- (void)zl_playEnd;

- (void)hideCommonControl;
- (void)showCommonControl;
@end
