//
// MediaLibCell.m
//  测试Demo
//
//  Created by Zhoulei on 2018/3/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "MediaLibCell.h"
@interface MediaLibCell()

@property (weak, nonatomic) IBOutlet UILabel *dateTime;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *triggerMode;

@property (weak, nonatomic) IBOutlet UIImageView *shotImage; //pic

@property (nonatomic, strong) IBOutlet UIButton   *playBtn;



@end

@implementation MediaLibCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setEntity:(MediaEntity *)entity {
    
    if (_entity != entity ) {
        _entity = entity;
        
        [self.shotImage setBackgroundColor:[UIColor blueColor]];
        self.triggerMode.text = [NSString stringWithFormat:@"%@",entity.fileName];
        self.dateTime.text = [self transDate:entity.createtime];
        self.duration.text = [self timeFormatted:entity.timelength];
        
//        [self.playBtn setTitle:entity.fileName forState:UIControlStateNormal];
//        [self.playBtn.titleLabel setTextColor:[UIColor whiteColor]];
//        [self.playBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        
        }
    
}

- (IBAction)sender:(id)sender {  //must triggerd  from outlet  not add target selector:()
    self.playcallback(self);
}
- (NSString *)transDate:(int)sec{
    
    NSDate  *transDate = [NSDate dateWithTimeIntervalSince1970:sec - 8 * 3600];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
//    [dateformatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    [dateformatter setDateFormat:@"HH:mm:ss"]; //HH 大写 24小时制

    return [dateformatter stringFromDate:transDate];
    
}

- (NSString *)timeFormatted:(int)t_sec {
    
    int seconds = t_sec % 60;
    int minutes = (t_sec / 60) % 60;
    int hours = t_sec / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
