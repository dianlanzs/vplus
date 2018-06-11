//
//  Alert.m
//  AlertDemo
//
//  Created by Mark Miscavage on 4/22/15.
//  Copyright (c) 2015 Mark Miscavage. All rights reserved.
//

#import "Alert.h"

BOOL doesBounce = NO;

@interface Alert ()

@property (nonatomic, assign)   AlertOutgoingTransitionType outgoingType;
@property (nonatomic, assign)   AlertIncomingTransitionType incomingType;




@end

@implementation Alert

#pragma mark Instance Types

- (instancetype)initWithTitle:(NSString *)title
                   inidicator:(UIActivityIndicatorView *)indicator
                   rootVc:(UIViewController *)vc{
    
    if (self = [super init] ) {
        
        [self.titleLabel setText:title];
        [self setIndicator:indicator];
        self.vc = vc;
  
    }
    
    return self;
}

#pragma mark Creation Methods




- (UILabel *)titleLabel {
    if (!_titleLabel) {
//        CGRect rect = [self alertRect];
        
//        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, rect.origin.y + 44, rect.size.width - 60, 24)];
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
        [_titleLabel setMinimumScaleFactor:16.0/18.0]; //?? 字体大小是 16 希望收缩 后 最小字体大小为14
        
        CGSize size = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName : _titleLabel.font}];
        [self.alertView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.alertView);
        }];
    }
    
    return _titleLabel;
}

- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        [_alertView setFrame:[self alertRect]];
        [_alertView setBackgroundColor:[UIColor colorWithRed:0.91 green:0.302 blue:0.235 alpha:1] /*#e84d3c*/];
    }
    
    return _alertView;
}

- (void)setIndicator:(UIView *)indicator {
    
    if (indicator != _indicator) {
        _indicator = indicator;
        [self.alertView addSubview:_indicator];
        [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.titleLabel.mas_leading);
            make.centerY.equalTo(self.alertView);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
}



#pragma mark Accessor Methods

- (void)setIncomingTransition:(AlertIncomingTransitionType)incomingTransition {
    _incomingType = incomingTransition;
}

- (void)setOutgoingTransition:(AlertOutgoingTransitionType)outgoingTransition {
    _outgoingType = outgoingTransition;
}

- (void)setAlertType:(AlertType)alertType {
    
    if (alertType == AlertTypeError) {
        [_alertView setBackgroundColor:[UIColor colorWithRed:0.91 green:0.302 blue:0.235 alpha:1] /*#e84d3c*/];
    }
    else if (alertType == AlertTypeSuccess) {
//        [_alertView setBackgroundColor:[UIColor colorWithRed:0.196 green:0.576 blue:0.827 alpha:1] /*#3293d3*/];
        [_alertView setBackgroundColor:[UIColor greenColor] /*#3293d3*/];

    }
    else if (alertType == AlertTypeWarning) {
        [_alertView setBackgroundColor:[UIColor colorWithRed:1 green:0.804 blue:0 alpha:1] /*#ffcd00*/];
    }
    
}

- (void)setBounces:(BOOL)bounces {
    if (bounces) {
        doesBounce = bounces;
    }
}

- (void)setShowStatusBar:(BOOL)showStatusBar {
    if (!showStatusBar) {
        //Set "View controller-based status bar appearance" = NO in info.plist
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (BOOL)prefersStatusBarHidden {
    //Needed for Hiding the status bar
    return YES;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [_alertView setBackgroundColor:backgroundColor];
}

- (void)setTitleColor:(UIColor *)titleColor {
    [_titleLabel setTextColor:titleColor];
}

#pragma mark Show/Dismiss Methods

- (void)showAlert {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
//    [self.vc.view addSubview:self];
    [self addSubview:self.alertView];

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertWillAppear:)]) {
        [self.delegate alertWillAppear:self];
    }
    
    if (_incomingType) {
        [self configureIncomingAnimationFor:_incomingType];
    }
    else {
        [self configureIncomingAnimationFor:AlertIncomingTransitionTypeSlideFromTop];
    }
    [self setShowing:YES];
}

- (void)dismissAlert {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertWillDisappear:)]) {
        [self.delegate alertWillDisappear:self];
    }
    
    if (_outgoingType) {
        [self configureOutgoingAnimationFor:_outgoingType];
    }
    else {
        [self configureOutgoingAnimationFor:AlertOutgoingTransitionTypeSlideToTop];
    }
    
        [self setShowing:NO];
}

#pragma mark Transition Methods

- (void)configureIncomingAnimationFor:(AlertIncomingTransitionType)trannyType {
    
    CGRect rect = [self alertRect];
    
    switch (trannyType) {
        case AlertIncomingTransitionTypeFlip: {
            
            if (doesBounce) {
                rect.origin.y = -90;
                [_alertView setFrame:rect];
                
                [UIView animateWithDuration:0.185 animations:^{
                    [_alertView setFrame:[self alertRect]];
                }];
                
                _alertView.transform = CGAffineTransformMake(1, 0, 0, -0.25, 0, _alertView.transform.ty);
                
                [UIView animateWithDuration:0.35 delay:0.18 usingSpringWithDamping:0.65 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{
                    _alertView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.25 animations:^{
                        _alertView.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished) {
                        [self finishShowing];
                    }];
                }];
                
            }
            else {
                rect.origin.y = -90;
                [_alertView setFrame:rect];
                
                [UIView animateWithDuration:0.185 animations:^{
                    [_alertView setFrame:[self alertRect]];
                }];
                
                _alertView.transform = CGAffineTransformMake(1, 0, 0, -1 , 0, _alertView.transform.ty);
                
                [UIView animateWithDuration:0.25 animations:^{
                    _alertView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self finishShowing];
                }];
            }
            
            break;
        }
        case AlertIncomingTransitionTypeSlideFromTop: {
            rect.origin.y = -90;
            [_alertView setFrame:rect];
            
            if (doesBounce) {
                [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.65 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{
                    [_alertView setFrame:[self alertRect]];
                } completion:^(BOOL finished) {
                    [self finishShowing];
                }];
            }
            else {
                [UIView animateWithDuration:0.125 animations:^{
                    [_alertView setFrame:[self alertRect]];
                } completion:^(BOOL finished) {
                    [self finishShowing];
                }];
            }
            
            break;
        }
        case AlertIncomingTransitionTypeSlideFromLeft: {
            rect.origin.x = -rect.size.width;
            [_alertView setFrame:rect];
            
            if (doesBounce) {
                [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.45 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{
                    [_alertView setFrame:[self alertRect]];
                } completion:^(BOOL finished) {
                    [self finishShowing];
                }];
            }
            else {
                [UIView animateWithDuration:0.125 animations:^{
                    [_alertView setFrame:[self alertRect]];
                } completion:^(BOOL finished) {
                    [self finishShowing];
                }];
            }
            
            break;
        }
        case AlertIncomingTransitionTypeSlideFromRight: {
            rect.origin.x = rect.size.width;
            [_alertView setFrame:rect];
            
            if (doesBounce) {
                [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.45 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{
                    [_alertView setFrame:[self alertRect]];
                } completion:^(BOOL finished) {
                    [self finishShowing];
                }];
            }
            else {
                [UIView animateWithDuration:0.125 animations:^{
                    [_alertView setFrame:[self alertRect]];
                } completion:^(BOOL finished) {
                    [self finishShowing];
                }];
            }
            
            break;
        }
        case AlertIncomingTransitionTypeGrowFromCenter: {
            
            _alertView.transform = CGAffineTransformMakeScale(0.3, 0.3);
            
            [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
                _alertView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [self finishShowing];
            }];
            
            
            break;
        }
        case AlertIncomingTransitionTypeFadeIn: {
            [_alertView setAlpha:0.0];
            
            [UIView animateWithDuration:0.35 animations:^{
                [_alertView setAlpha:1.0];
            } completion:^(BOOL finished) {
                [self finishShowing];
            }];
            
            
            break;
        }
        case AlertIncomingTransitionTypeInYoFace: {
            _alertView.transform = CGAffineTransformMakeScale(0.3, 0.3);
            
            [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.95 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
                _alertView.transform = CGAffineTransformMakeScale(1.25, 1.25);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15 animations:^{
                    _alertView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self finishShowing];
                }];
            }];
            
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)configureOutgoingAnimationFor:(AlertOutgoingTransitionType)trannyType {
    
    CGRect finalRect = [self alertRect];
    
    switch (trannyType) {
        case AlertOutgoingTransitionTypeFlip: {
            
            [UIView animateWithDuration:0.275 animations:^{
                _alertView.transform = CGAffineTransformMake(1, 0, 0, -0.05 , 0, _alertView.transform.ty - 18.5);
            } completion:^(BOOL finished) {
                [self finishDisappearing];
            }];
            
            break;
        }
        case AlertOutgoingTransitionTypeSlideToTop: {
            finalRect.origin.y = -90;
            
            [UIView animateWithDuration:0.15 animations:^{
                [_alertView setFrame:finalRect];
            } completion:^(BOOL finished) {
                [self finishDisappearing];
            }];
            
            break;
        }
        case AlertOutgoingTransitionTypeSlideToLeft: {
            finalRect.origin.x = -finalRect.size.width;
            
            [UIView animateWithDuration:0.15 animations:^{
                [_alertView setFrame:finalRect];
            } completion:^(BOOL finished) {
                [self finishDisappearing];
            }];
            
            break;
        }
        case AlertOutgoingTransitionTypeSlideToRight: {
            finalRect.origin.x = finalRect.size.width;
            
            [UIView animateWithDuration:0.15 animations:^{
                [_alertView setFrame:finalRect];
            } completion:^(BOOL finished) {
                [self finishDisappearing];
            }];
            
            break;
        }
        case AlertOutgoingTransitionTypeShrinkToCenter: {
            
            [UIView animateWithDuration:0.2 animations:^{
                _alertView.transform = CGAffineTransformMakeScale(0.25, 0.25);
            } completion:^(BOOL finished) {
                [self finishDisappearing];
            }];
            
            break;
        }
        case AlertOutgoingTransitionTypeFadeAway: {
            
            [UIView animateWithDuration:0.2 animations:^{
                [_alertView setAlpha:0.0];
            } completion:^(BOOL finished) {
                [self finishDisappearing];
            }];
            
            break;
        }
        case AlertOutgoingTransitionTypeOutYoFace: {
            _alertView.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.95 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
                _alertView.transform = CGAffineTransformMakeScale(1.25, 1.25);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15 animations:^{
                    _alertView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                } completion:^(BOOL finished) {
                    [self finishDisappearing];
                }];
            }];
            
            break;
        }
        default: {
            break;
        }
    }
    
}

#pragma mark Finishing Methods

- (void)finishShowing {
    if ([self.delegate respondsToSelector:@selector(alertDidAppear:)]) {
        [self.delegate alertDidAppear:self];
    }
}

- (void)finishDisappearing {
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertDidDisappear:)]) {
        [self.delegate alertDidDisappear:self];
    }
}

- (CGRect)alertRect {
    UIScreen *mainScreen = [UIScreen mainScreen];
//    return CGRectMake(-20, -10, mainScreen.bounds.size.width + 40, 74);  //2 边 + 20  上   +10
    return CGRectMake(0, 0, mainScreen.bounds.size.width , 64);

}

@end
