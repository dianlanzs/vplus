//
//  SearchLanViewController.m
//  ilnkDemo
//
//  Created by YGTech on 2017/11/27.
//  Copyright © 2017年 com.ilnkDemo.cme. All rights reserved.
//

#import "SearchLanViewController.h"

#import "ReactiveObjC.h"


#import "Device.h"
#import "OnSearchDoneController.h"

@interface SearchLanViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BButton *searchBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIImageView *bgLanSearch;

@property (strong , nonatomic) NSMutableArray *dataSource;


@end

@implementation SearchLanViewController


#pragma mark -初始化视图
- (void)initView {

    [self addBackgroundView];
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];



}










#pragma mark - 生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self.view addSubview:self.searchBtn];
    [self.view addSubview:self.promptLabel];
    
    self.navigationItem.title = @"局域网添加";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

























//- (void)startSearch {
//    [_dataSource removeAllObjects]; //删除原有源
//        //搜索的结果 返回数组
////        NSArray * deviceArr = [[PPPPManager sharedPPPPManager] NodeSearchCameraResult];
//        //是否搜索到设备
//        if(deviceArr.count > 0){
//            for (int i = 0; i < deviceArr.count; i++) {
//                Device *device = [[Device alloc] init];
//                device.did = [deviceArr[i] valueForKey:@"DID"];
//                //添加设备对象,,,数组没有初始化
//                [self.dataSource addObject:device];
//            }
//
//            //回主队列刷新表格视图数据
//            dispatch_async(dispatch_get_main_queue(), ^{
//                OnSearchDoneController *searchDoneVc = [[OnSearchDoneController alloc] init];
//                searchDoneVc.deviceList = self.dataSource;
//                [MBProgressHUD showSuccess:@"搜索完成"];
//                [self.navigationController  pushViewController:searchDoneVc animated:YES];
//
//            });
//        }
//
//
//}


#pragma mark - Required
//- (BButton *)searchBtn {
//
//    if (!_searchBtn) {
//        _searchBtn = [[BButton alloc] initWithFrame:CGRectMake(15, 550, AM_SCREEN_WIDTH - 30, kBtnH) type:BButtonTypeDefault];
//        [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
//        [_searchBtn setColor:[UIColor orangeColor]];
//
//        [[_searchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//            [MBProgressHUD showSpinningWithMessage:@"正在搜索...."];
//            //NOTE:开始搜索，开启全局队列 ,不然 点击Button  会 阻塞  ，因为要等 SubscriberNext Block 返回 ，就要把  [self startSearch]; 执行完，但是
//            //Lan搜索是耗时操作 ，会比较慢！！
////            [self startSearch];
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
//                [self startSearch];
//            });
//
//
//
//        }];
//
//    }
//
//    return _searchBtn;
//
//}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        
        
        
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 500, AM_SCREEN_WIDTH - 30, 0)];

        [_promptLabel setFont:[UIFont systemFontOfSize:17.0]];
        
        _promptLabel.text  = @"开始搜索之前 ，请将您的手机和采集设备接入同一网络。";
        _promptLabel.textColor = [UIColor blackColor];

        _promptLabel.textAlignment = NSTextAlignmentLeft;
        _promptLabel.numberOfLines = 0;
//        CGSize size = [self getSizeWithStr:promptLabel.text width:AM_SCREEN_WIDTH - 30 fontSize:15];
        
//        CGSize labelSize = [self getSizeWithStr:_promptLabel.text width:AM_SCREEN_WIDTH fontSize:15];

//        _promptLabel.frame = CGRectMake(15, 400, AM_SCREEN_WIDTH - 30, 20);
        
        [_promptLabel sizeToFit];
    }
    
    return _promptLabel;
}



- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}




- (UIImageView *)addBackgroundView {
    
    if (!_bgLanSearch) {
        
        UIImage *image = [UIImage imageNamed:@"bg_lanSearch"];
        _bgLanSearch = [[UIImageView alloc] initWithImage:image];
        
        
        //NOTE: 必须先添加到父View ，再约束！！
        [self.view addSubview:_bgLanSearch];
        [_bgLanSearch mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self.view);
            make.top.equalTo(self.view).offset(100);
            make.left.equalTo(self.view).offset(0);
//            make.right.equalTo(self.view).offset(-15);
//            make.bottom.equalTo(self.view).with.offset(-10);
            make.size.mas_equalTo(image.size);
        }];
    }
    
    return _bgLanSearch;
}



#pragma mark - 固定宽度和字体大小，获取label的frame
- (CGSize) getSizeWithStr:(NSString *) str width:(float)width fontSize:(float)fontSize
{
    NSDictionary * attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize tempSize = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attribute
                                        context:nil].size;
    return tempSize;
}
@end
