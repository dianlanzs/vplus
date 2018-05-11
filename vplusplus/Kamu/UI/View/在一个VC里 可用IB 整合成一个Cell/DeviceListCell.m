//
//  DeviceListCell.m
//  Kamu
//
//  Created by YGTech on 2017/11/29.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "DeviceListCell.h"
#import "UIView+EqualMargin.h"
@interface DeviceListCell()




//顶部Bar
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *lb_device;
@property (nonatomic, strong) UIImageView *imv_logo;
@property (nonatomic, strong) UILabel *lb_state;


//视频View
@property (strong, nonatomic) UIView *videoContent;
@property (nonatomic, strong) UIButton *playButton;



//底部Bar
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation DeviceListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self.contentView addSubview:self.topView];
        //videoView
        [self.contentView addSubview:self.videoContent];
        [self.videoContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom);
            make.trailing.equalTo(self.contentView).offset(- 12.0f);
            make.leading.equalTo(self.contentView).offset(12.0f);
            make.height.mas_equalTo(120.0f);
        }];
        
        
        [self addButtons];
        
        /// MARK：bottomView 最后添加 ，视图层级 会在最上面，先添加，在 视图层级下面
        [self.contentView addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView);
            make.trailing.equalTo(self.contentView);
            make.top.equalTo(self.videoContent.mas_bottom);
//            make.bottom.equalTo(self.contentView).priorityHigh(750);
            make.height.mas_equalTo(40);
        }];
        

    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




- (void)addButtons  {
    
    //图标数组
    NSArray *iconArray = @[@"lock",@"bell",@"cloud",@"SDCard",@"settings"];
    
    //设置按钮的宽度
    CGFloat btnWidth = 40;
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        
        MRoundedButton *btn = [[MRoundedButton alloc] initWithFrame:CGRectZero buttonStyle:MRoundedButtonCentralImage appearanceIdentifier:@"MRButton_Default"];
        
        //设置 button 图标 ，并且设置 图片渲染模式
        UIImage *btnIcon = [[ UIImage imageNamed:[NSString stringWithFormat:@"button_%@",iconArray[i]] ] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        btn.imageView.image = btnIcon;
        btn.tag =  i;
        
        //先添加 到父视图
        [self.contentView addSubview:btn];
        [buttons addObject:btn];
        
        
        
        ////设置约束！ 修改中间的button的宽度：60
        if (btn.tag == 2) {
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                //约束1： button中心 对其 media底部
                make.centerY.equalTo(self.videoContent.mas_bottom);
                //约束2：设置宽度
                make.width.mas_equalTo(btnWidth * 1.2);
                //约束3： 宽高比例 1：1
                make.height.equalTo(btn.mas_width);
                
                btn.foregroundColor = [UIColor purpleColor];
            }];
        }else{
            
            //其他 button 控件 宽度 ：40
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.equalTo(self.videoContent.mas_bottom).offset(0.f);
                make.width.mas_equalTo(btnWidth);
                make.height.equalTo(btn.mas_width);
                
            }];
            
        }
        
    }
    
    
    //水平方向 平分button布局
    [self distributeSpacingHorizontallyWith:buttons];
    
}




//顶部视图
- (UIView *)topView {
    
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, self.contentView.bounds.size.width - 24, 40.0f)];
        [_topView setBackgroundColor:[UIColor whiteColor]];
        
        [_topView addSubview:self.lb_device];
        [_topView addSubview:self.imv_logo];
        [_topView addSubview:self.lb_state];
        
        //设置约束：
        [self.lb_device mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_topView).offset(12.0f);
            make.centerY.equalTo(_topView);
        }];
        
        
        [self.imv_logo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.lb_state.mas_leading).offset(- 5.0f);
            make.size.mas_equalTo(CGSizeMake(25.0f, 25.0f));
            make.centerY.equalTo(_topView);
        }];
        
        [self.lb_state mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_topView).offset(- 12.0f);
            make.centerY.equalTo(_topView);
        }];
        
    }
    return _topView;
}


- (UILabel *)lb_device {
    
    if (!_lb_device) {
        _lb_device = [[UILabel alloc] init];
        [_lb_device setText:@"IPC90324556"];
        [_lb_device sizeToFit];
    }
    return _lb_device;
}


- (UIImageView *)imv_logo {
    
    if (!_imv_logo) {
        _imv_logo = [[UIImageView alloc ] initWithFrame:CGRectZero];
        [_imv_logo setImage:[UIImage imageNamed:@"icon_camera_normal"]];
        
    }
    return _imv_logo;
}


- (UILabel *)lb_state {
    
    if (!_lb_state) {
        _lb_state = [[UILabel alloc] init];
        [_lb_state setText:@"离线"];
        [_lb_state sizeToFit];
    }
    return _lb_state;
}


//Video 视图 ,创建内部控件 first!
- (UIView *)videoContent {
    
    if (!_videoContent) {
        
        _videoContent = [[UIView alloc] init];
        [_videoContent setBackgroundColor:[UIColor blackColor]];
        
        //添加 子视图
        [_videoContent addSubview:self.playButton];
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_videoContent);
            make.size.mas_equalTo(CGSizeMake(50.0f, 50.0f));
        }];
    }
    
    return _videoContent;
}

- (UIButton *)playButton {
    
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"mp_play_center"] forState:UIControlStateNormal];
    }
    return _playButton;
}

//Botom View
- (UIView *)bottomView {
    
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        [_bottomView setBackgroundColor:[UIColor clearColor]];
    }
    
    return _bottomView;
}


- (void)setDevice:(Device *)ipcModel {
    
    if (_ipcModel != ipcModel) {
        _ipcModel = ipcModel;
    }
    
    self.lb_device.text = ipcModel.nvr_id;
 
}



@end
