//
//  QFloatTableViewCell.m
//  QuickDialog
//
//  Created by Bart Vandendriessche on 29/04/13.
//
//

#import "QFloatTableViewCell.h"

@interface QFloatTableViewCell ()

@property (nonatomic, strong, readwrite) UISlider *slider;

@end

@implementation QFloatTableViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithReuseIdentifier:@"QFloatTableViewCell"];
    if (self) {
//        self.slider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectZero];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.tracking_slider];
        


    }
    return self;
}
- (ASValueTrackingSlider *)tracking_slider {
    if (!_tracking_slider) {
        _tracking_slider                       = [[ASValueTrackingSlider alloc] init];
        [_tracking_slider setContinuous:YES];
  
  
   
//        [_tracking_slider setThumbImage:ZLPlayerImage(@"滑动") forState:UIControlStateNormal];
        _tracking_slider.maximumValue          = 1;
        _tracking_slider.minimumValue          = 0;

//        _tracking_slider.minimumTrackTintColor = [UIColor redColor];
//        _tracking_slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterPercentStyle];
        [_tracking_slider setNumberFormatter:formatter];
        _tracking_slider.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:14];
        [_tracking_slider setPopUpViewAnimatedColors:@[[UIColor redColor], [UIColor yellowColor],[UIColor greenColor]]
                                   withPositions:@[@0, @0.21f, @0.31f]];
        _tracking_slider.popUpViewArrowLength = 5;
        _tracking_slider.popUpViewCornerRadius = 0.0;
//        _tracking_slider.popUpViewAlwaysOn = YES;
        [_tracking_slider setContinuous:NO];
        [_tracking_slider showPopUpViewAnimated:YES];
//              _tracking_slider.popUpViewColor = RGBA(19, 19, 9, 1);
        
        
//        [_tracking_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
//        [_tracking_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//        [_tracking_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        //tap  & pan gesture for slider
//        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
//        [_tracking_slider addGestureRecognizer:sliderTap];
//        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
//        panRecognizer.delegate = self;
//        [panRecognizer setMaximumNumberOfTouches:1];
//        [panRecognizer setDelaysTouchesBegan:YES];
//        [panRecognizer setDelaysTouchesEnded:YES];
//        [panRecognizer setCancelsTouchesInView:YES];
//        [_tracking_slider addGestureRecognizer:panRecognizer];
    }
    return _tracking_slider;
}

/*
- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y,   [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName:self.textLabel.font}].width, self.textLabel.frame.size.height);
    CGFloat width = self.textLabel.frame.origin.x + self.textLabel.frame.size.width;

    CGRect remainder, slice;
    CGRectDivide(self.contentView.bounds, &slice, &remainder, width, CGRectMinXEdge);
    CGFloat standardiOSMargin = 10;
    self.slider.frame = CGRectInset(remainder, standardiOSMargin, 0);
}
 
 */



- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y,   [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName:self.textLabel.font}].width, self.textLabel.frame.size.height);
    //        CGFloat width = self.textLabel.frame.origin.x + self.textLabel.frame.size.width;
    //        CGRect remainder, slice;
    //        CGRectDivide(self.contentView.bounds, &slice, &remainder, width, CGRectMinXEdge);
    //        CGFloat standardiOSMargin = 40;
    //         self.tracking_slider.frame = CGRectInset(remainder, standardiOSMargin, 0);
    
    [self.tracking_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.textLabel.mas_trailing).offset(20);
        make.trailing.equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.textLabel).offset(5.f);
        
    }];
}
@end
