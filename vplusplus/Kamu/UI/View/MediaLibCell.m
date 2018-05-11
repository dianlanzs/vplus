//
// MediaLibCell.m
//  测试Demo
//
//  Created by YGTech on 2018/3/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "MediaLibCell.h"
@interface MediaLibCell()

@property (weak, nonatomic) IBOutlet UILabel *dateTime;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *triggerMode;
//@property (weak, nonatomic) IBOutlet UIImageView *buttonLogo;
@property (weak, nonatomic) IBOutlet UIImageView *shotImage;

@property (nonatomic, strong) UIButton   *playBtn;



@end

@implementation MediaLibCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"mp_play_center"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playback:) forControlEvents:UIControlEventTouchUpInside];
    [self.shotImage addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.shotImage);
        make.width.height.mas_equalTo(70);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setEntity:(MediaEntity *)entity {
    
    if (_entity != entity ) {
        _entity = entity;
        [self.shotImage setBackgroundColor:[UIColor blueColor]];
        self.triggerMode.text = [NSString stringWithFormat:@"%d", entity.recordType];
        self.dateTime.text = [NSString stringWithFormat:@"%d",entity.createtime];
        self.duration.text = [NSString stringWithFormat:@"%d", entity.timelength];

        }
    
}


- (void)playback:(id)sender{
    ;
}
@end
