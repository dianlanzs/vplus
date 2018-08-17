//
//  CommonPlayerControl.h
//  Kamu
//
//  Created by YGTech on 2018/6/1.
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

// 播放器的几种状态
typedef NS_ENUM(NSInteger, ZLPlayerState) {
    
    ZLPlayerStateUnknwon,
    ZLPlayerStateFailed,     // 播放失败
    ZLPlayerStateReplay,     // 重播

    ZLPlayerStateBuffering,  // 缓冲中
    ZLPlayerStatePlaying,    // 播放中
    ZLPlayerStateEnd,    // 停止播放
    ZLPlayerStatePause       // 暂停播放
};
@interface CommonPlayerControl : UIView



@property (nonatomic, assign) ZLPlayerState          state;
@property (nonatomic, strong) RTSpinKitView *spinner;
@property (nonatomic, weak) id<PlayerControlDelegate> delegate;




//
//@property (nonatomic, assign) UIInterfaceOrientation  orientation;




@property (nonatomic, strong) UIButton                *lockBtn;
@property (nonatomic, strong) UIImageView             *topImageView;
@property (nonatomic, strong) UIImageView             *bottomImageView;

@property (nonatomic, strong) UILabel                 *titleLabel;


@property (nonatomic, strong) UIButton                *fullScreenBtn;
@property (nonatomic, strong) UIButton                *backBtn;
@property (nonatomic, strong) UIButton                *failBtn;

@property (nonatomic, assign, getter=isShowing) BOOL  showing;









@property (nonatomic, assign) BOOL                   playerEnd;
@property (nonatomic, assign, getter=isFullScreen) BOOL                   fullScreen;








- (void)autoFadeOutControlView;





- (void)resetControl;

- (void)hideControl;
- (void)showControl;



//playback
- (void)zl_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;
- (void)zl_changeSilderValueWithDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview;
- (void)zl_showSilderValueWithDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image;
- (void)zl_playerDraggedEnd;

@end
