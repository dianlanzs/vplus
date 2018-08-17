//
//  AddCamsViewController.m
//  Kamu
//
//  Created by Zhoulei on 2017/12/25.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "AddCamsViewController.h"
#import "ProbeDoneViewController.h"
@interface AddCamsViewController ()

@property (nonatomic, strong) UIView *specView;



@end

@implementation AddCamsViewController

#pragma mark - 生命周期
//先调用这个方法----> 再调用init方法
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = LS(@"添加摄像头");
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviews];
}
- (void)add:(id)sender {
    [self.navigationController pushViewController:[ProbeDoneViewController new] deviceModel:self.navigationController.operatingDevice camModel:self.navigationController.operatingCam];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 添加子（QR）视图
- (void)addSubviews {
    
    [self.view addSubview:self.specView];
    [self.specView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}
- (UIView *)specView {
    
    if (!_specView) {
        _specView = [[UIView alloc] initWithFrame:CGRectZero];
        UILabel *lb_spec = [UILabel labelWithText:LS(@"按住摄像头上的 Sync 按钮约 2 秒钟,然后松开。(如果同步成功，摄像头上的蓝色 LED 会闪烁 10秒）") withFont:[UIFont systemFontOfSize:15.f] color:[UIColor blackColor] aligment:NSTextAlignmentLeft];
        lb_spec.numberOfLines = 0;
        //        UIImageView *imv_spec = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spec_cam"]];
        UIButton *btn_spec = [[UIButton alloc] initWithFrame:CGRectZero];
        UIButton *btn_addCam = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypePrimary];
        [btn_addCam setTitle:LS(@"探测摄像头") forState:UIControlStateNormal];
        //        [_addBtn setImage:[UIImage imageNamed:@"button_scan_normal"] forState:UIControlStateNormal];
        btn_addCam.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        [btn_addCam addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
        //下划线
        NSString *s = LS(@"蓝色LED指示灯未闪烁？");
        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *underline_s = [[NSMutableAttributedString alloc] initWithString:s attributes:attribtDic];
        [btn_spec setTitle:underline_s.mutableString forState:UIControlStateNormal];
        [btn_spec.titleLabel setAttributedText:underline_s];
        [btn_spec.titleLabel setFont:[UIFont boldSystemFontOfSize:17.f]];
        [btn_spec setTitleColor:[UIColor colorWithHex:@"0066ff"] forState:UIControlStateNormal];
        [_specView addSubview:lb_spec];
        //        [_specView addSubview:imv_spec];
        [_specView addSubview:btn_spec];
        [_specView addSubview:btn_addCam];
        //        [imv_spec mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(_specView).offset(40.f);
        //            make.width.mas_equalTo(AM_SCREEN_WIDTH * 0.6);
        //            make.height.mas_equalTo(imv_spec.mas_width).multipliedBy(1.f);
        //            make.centerX.equalTo(_specView);
        //        }];
        [lb_spec mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.top.equalTo(imv_spec.mas_bottom).offset(20.f);
            make.top.equalTo(_specView).offset(20.f);
            make.leading.equalTo(_specView).offset(15.f);
            make.trailing.equalTo(_specView).offset(-15.f);
            
        }];
        [btn_spec mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lb_spec.mas_bottom).offset(40.f);
            make.leading.equalTo(_specView).offset(20.f);
            make.trailing.equalTo(_specView).offset(-20.f);
            make.height.mas_equalTo(40.f);
        }];
        
        [btn_addCam mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_specView).offset(20.f);
            make.trailing.equalTo(_specView).offset(-20.f);
            make.bottom.equalTo(_specView).offset(-40.f);
            make.height.mas_equalTo(40.f);
        }];
    }
    
    return _specView;
}

@end
