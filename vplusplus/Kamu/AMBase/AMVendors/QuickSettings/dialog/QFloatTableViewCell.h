//
//  QFloatTableViewCell.h
//  QuickDialog
//
//  Created by Bart Vandendriessche on 29/04/13.
//
//

#import "QTableViewCell.h"
#import "ASValueTrackingSlider.h"
@interface QFloatTableViewCell : QTableViewCell

//@property (nonatomic, strong, readonly) UISlider *slider;
@property (nonatomic, strong) ASValueTrackingSlider *tracking_slider;


@end
