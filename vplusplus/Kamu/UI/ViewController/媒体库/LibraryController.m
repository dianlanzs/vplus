//
//  LibraryController.m
//  Kamu
//
//  Created by Zhoulei on 2018/1/9.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "LibraryController.h"
#import "UIBarButtonItem+Item.h"
#import "PageController.h"

#import "AMNavigationController.h"


#import "FilterController.h"
#import "RegionModel.h"


@interface LibraryController ()<UIScrollViewDelegate,ScrollableDatepickerDelegate>



@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;


@property (nonatomic, strong) UILabel *selectedDateLb;
@property (nonatomic, strong) FilterController *filter;
@end

@implementation LibraryController

#pragma mark - life circle

- (instancetype)initWithDevice:(Device *)cloudDevice {
    self = [super init];
    if (self) {
        [self setCloudDevice:cloudDevice];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.scrollView];
    
    [self.view addSubview:self.selectedDateLb];
    [self.view addSubview:self.datepicker];
    

    [self setNavgation];
    [self makeConstraints];
    
    ///MARK:设置完约束立即 同步调用 更新 为了获取 准确的 已经添加的 scrollview 尺寸！！！
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    
    
    
    
    self.filter = [[FilterController alloc] initWithSponsor:self resetBlock:^(NSArray *dataList) {
        for (RegionModel *model in dataList) {
            
            //clear item seleted status & region model owned list
            for (ItemModel *item in model.itemList) {
                [item setSelected:NO];
            }
            
            [model setSelectedItemList:nil];
        }
    } commitBlock:^(NSArray *regionList) {
        
        for (RegionModel *region in regionList) {

            for (ItemModel *item in region.itemList) {
                if (item.selected == YES && cloud_get_device_status((void *)self.cloudDevice.nvr_h) == CLOUD_DEVICE_STATE_CONNECTED) {
//                    cloud_device_cam_list_files((void *)self.cloudDevice.nvr_h,item.cam_id,SEC_00,SEC_24,RECORD_TYPE_ALL);
                }
            }
        }
        
        [self.filter dismiss];
    }];
    
    [self.filter setAnimationDuration:.3f];
    [self.filter setLeading:0.3 * AM_SCREEN_WIDTH];
    [self.filter setRegionList:[self setRegionList]];  //RegionModel 数组
    
    
    
    
    
    //contentSize == 0 ,不会走ScrollToRect方法
    //已经标记了？？可以直接调用 setNeedsLayout（标记需要 刷新tag)
//    [self.view layoutIfNeeded]; //刷新有标记刷新的视图 ，同步调用layoutSubviews
//    self.automaticallyAdjustsScrollViewInsets = NO;///MARK:针对 根视图第一个添加scrollView vc会自动调整一段 内容 y值 的Inset ，不就是容器嘛
    [self addListController];//添加子控制器Page vc
}

- (NSArray *)setRegionList {
    NSMutableArray *dataArray = [NSMutableArray array];
    [dataArray addObject:[self insertRegion:@"cams" selectionType:1]];
//    [dataArray addObject:[self insertRegion:@"viedoType" selectionType:0]];
    return [dataArray mutableCopy];
}


- (RegionModel *)insertRegion:(NSString *)regionName selectionType:(int)type {
    
    RegionModel *aRegion = [RegionModel new];
    aRegion.containerCellClass = @"RowCell";
    aRegion.regionTitle = @"cams";

    
    NSMutableArray *items = [NSMutableArray array];
    for (Cam *cloudCam in self.cloudDevice.nvr_cams) {
        ItemModel *item = [ItemModel new];
        [item setItemName:cloudCam.cam_name ? [cloudCam.cam_name uppercaseString] : [cloudCam.cam_id uppercaseString]];
        item.cam_id = cloudCam.cam_id;
        [item setSelected:NO];
        [items addObject:item];
    }
    aRegion.itemList = items;
    return aRegion;
}










- (void)setNavgation {

                                               
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithimage:[UIImage imageNamed:@"button_filter_normal"] highImage:[UIImage imageNamed:@"button_filter_normal"] target:self action:@selector(filter:) title:@"筛选"];

}
- (void)addListController {
    for (int i = 0 ; i <  self.segmentedControl.sectionTitles.count ;i++){
        PageController *page = [[PageController alloc] init];
        page.title = self.segmentedControl.sectionTitles[i];
//        page.URL = self.arrayLists[i][@"urlString"];
        [self addChildViewController:page];

        if (!page.tableView.superview) {
            [self.scrollView addSubview:page.tableView];
            page.tableView.frame = CGRectMake(CGRectGetWidth(self.scrollView.bounds) * i, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds)); //scrollview 滚动原理 是改变自身的 bounds
        }
        [page didMoveToParentViewController:self];

    }
}
- (void)filter:(id)sender {
    [self.filter show];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setApperanceForLabel:(UILabel *)label {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:23.0f];
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.segmentedControl setSelectedSegmentIndex:0]; //1. choose 中继
    [self datepicker:self.datepicker didSelectDate:[NSDate date]];//2. choose today
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}



#pragma mark - getter
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        //if < scrollview height no scroll vertial ,& if == 0 no trigger code scroll  must set >0
        _scrollView.contentSize = CGSizeMake((self.view.bounds.size.width) * self.segmentedControl.sectionTitles.count, 1);
    }
    
    return _scrollView;
}
- (ScrollableDatepicker *)datepicker {
    
    if (!_datepicker) {
        _datepicker = [[ScrollableDatepicker alloc] initWithFrame:CGRectZero];
        [_datepicker setBackgroundColor:[UIColor lightGrayColor]];
        
        NSMutableArray *dateArray = [NSMutableArray array];
        for (int i = -14; i < 1; i++) {
            //3600s * 24 = 1 day
            [dateArray addObject:[NSDate dateWithTimeIntervalSinceNow:(i * 3600 * 24)]];
        }
        
        _datepicker.dates = dateArray;
        [_datepicker setSelectedDate:[NSDate date]];
        _datepicker.delegate = self;
        Configuration *configuration = [[Configuration alloc] init];
        configuration.weekendDayStyle.dateTextColor = [UIColor orangeColor];
        configuration.weekendDayStyle.dateTextFont = [UIFont boldSystemFontOfSize:20.f];
        configuration.weekendDayStyle.weekDayTextColor = [UIColor orangeColor];
        // 设置选中日期的 样式
        configuration.selectedDayStyle.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        //        configuration.daySizeCalculation = .numberOfVisibleItems(5)
        _datepicker.configuration = configuration;
    }
    
    return _datepicker;
}
// 选择的日期
- (UILabel *)selectedDateLb {
    
    if (!_selectedDateLb) {
        _selectedDateLb = [[UILabel alloc] init];
        _selectedDateLb.textAlignment = NSTextAlignmentCenter;
    }
    
    return _selectedDateLb;
}
- (HMSegmentedControl *)segmentedControl {
    
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),40)];
        _segmentedControl.sectionTitles = @[@"设备",@"手机"];
        _segmentedControl.backgroundColor = [UIColor blueColor];
        _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor] ,
                                                  NSFontAttributeName :[UIFont fontWithName:@"HelveticaNeue" size:15.f]};
        
        _segmentedControl.selectedTitleTextAttributes = @{
                                                            NSForegroundColorAttributeName : [UIColor whiteColor]};
                                                            _segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
                                                            _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
                                                            _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionStyleTextWidthStripe;
                                                            _segmentedControl.tag = 3;
        
        __weak typeof(self) weakSelf = self;
        [_segmentedControl setIndexChangeBlock:^(NSInteger index) {
            /*可见视图是在这个滚动视图的范围而当前不可见，如果当前已经可见了，那么这个方法将不会做任何事情。*/
            [weakSelf.scrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(weakSelf.view.frame) * index, 0, CGRectGetWidth(weakSelf.view.frame), CGRectGetHeight(weakSelf.scrollView.frame)) animated:YES];
        }];
    }
    return  _segmentedControl;
}



#pragma mark - UIScrollViewDelegate

//manually drag  trigger
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //计算ScrollView 宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
}


//code trigger
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    ;
}

#pragma mark -  DatePickerDelegate
- (void)datepicker:(ScrollableDatepicker *)datepicker didSelectDate:(NSDate *)date {
    int sec = [self showSelectedDate];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
//        PageController *page = [[[self.childViewControllers reverseObjectEnumerator] allObjects] objectAtIndex:0];
        PageController *page = [self.childViewControllers  objectAtIndex:0];

        [page setStart_daySec:sec];
        if (cloud_get_device_status((void *)self.cloudDevice.nvr_h) == CLOUD_DEVICE_STATE_CONNECTED) { //get status
            self.cloudDevice.listDelegate = page;
            
                        [MBProgressHUD showSpinningWithMessage:@"downloding..." toView:page.tableView];
//            [MBProgressHUD showSpinningWithMessage:@"downloding..." ];
            
            cloud_device_cam_list_files((void *)self.cloudDevice.nvr_h,NULL,  sec,sec + 24 * 3600,RECORD_TYPE_ALL);
            
            
            
            
        }else {
            [MBProgressHUD showPromptWithText:@"device offline"];
        }
    }
    
}
//日期格式
- (int)showSelectedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd";//@"dd-MMMM YYYY" yyyy-MM-dd HH:mm:ss ,默认  00:00:00
    self.selectedDateLb.text = [dateFormat stringFromDate:self.datepicker.selectedDate];
    [self.datepicker scrollToSelectedDateWithAnimated:YES];
    
    
    NSDate *datenew = [dateFormat dateFromString:[dateFormat stringFromDate:self.datepicker.selectedDate]];
  int sec =  [datenew timeIntervalSince1970];
    return  sec;
}






- (void)makeConstraints {
    //约束：
    [self.selectedDateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom).offset(10);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        //        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.bounds), 60));
    }];
    [self.datepicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectedDateLb.mas_bottom).offset(10);
        make.leading.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame), 50));
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.datepicker.mas_bottom).offset(10);
        make.leading.equalTo(self.view).offset(0);
        make.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
    }];
}

@end
