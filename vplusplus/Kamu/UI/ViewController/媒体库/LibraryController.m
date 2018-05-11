//
//  LibraryController.m
//  Kamu
//
//  Created by YGTech on 2018/1/9.
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
    [self createSegments];
    
    [self.view addSubview:self.selectedDateLb];
    [self.view addSubview:self.datepicker];
    

    [self setNavgation];
    [self makeConstraints];

    
    
    
    
    self.filter = [[FilterController alloc] initWithSponsor:self resetBlock:^(NSArray *dataList) {
        for (RegionModel *model in dataList) {
            //clear item seleted status & region model owned list
            for (ItemModel *item in model.itemList) {
                [item setSelected:NO];
            }
            [model setSelectedItemList:nil];
        }
    } commitBlock:^(NSArray *regionList) {
        //配送服务
        RegionModel *camRegionModel = regionList[0];  //for 循环
//        NSMutableString *serviceInfoString = [NSMutableString stringWithString:@"\n配送服务ddd:\n"];
        NSMutableArray *selectedCams = [NSMutableArray array];
//        AddressModel *addressModel = [serviceRegionModel.customDict objectForKey:SELECTED_ADDRESS];
//        [serviceInfoString appendFormat:@"选中地址:%@-%@\n", addressModel.addressId, addressModel.addressString];

        for (ItemModel *item in camRegionModel.itemList) {
            if (item.selected) {
                [selectedCams addObject:item];
            }
        }
        
//        [serviceInfoString appendString:[serviceItemSelectedArray componentsJoinedByString:@", "]];
//        NSLog(@"%@", serviceInfoString);
        


    }];
    
    [self.filter setAnimationDuration:.3f];
    [self.filter setLeading:0.15 * AM_SCREEN_WIDTH];
    [self.filter setRegionList:[self setRegionList]];  //RegionModel 数组
    
    
    
    
    
    //contentSize == 0 ,不会走ScrollToRect方法
    //已经标记了？？可以直接调用 setNeedsLayout（标记需要 刷新tag)
    [self.view layoutIfNeeded]; //刷新有标记刷新的视图 ，同步调用layoutSubviews
//    self.automaticallyAdjustsScrollViewInsets = NO;///MARK:针对 根视图第一个添加scrollView vc会自动调整一段 内容 y值 的Inset
 
    [self addListController];//添加子控制器Page vc
//    UIViewController *vc = [self.childViewControllers firstObject];
//    [self.scrollView addSubview:vc.view];
//    vc.view.frame = self.scrollView.bounds;
//    [vc didMoveToParentViewController:self];

    
    
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
        [item setItemName:cloudCam.cam_name];
        [item setSelected:NO];
        [items addObject:item];
    }
    aRegion.itemList = items;
    return aRegion;
}
//- (ZYSideSlipFilterRegionModel *)commonFilterRegionModelWithKeyword:(NSString *)keyword selectionType:(CommonTableViewCellSelectionType)selectionType {
//    ZYSideSlipFilterRegionModel *model = [[ZYSideSlipFilterRegionModel alloc] init];
//    model.containerCellClass = @"SideSlipCommonTableViewCell";
//    model.regionTitle = keyword;
//    model.customDict = @{REGION_SELECTION_TYPE:@(selectionType)};
//    model.itemList = @[[self createItemModelWithTitle:[NSString stringWithFormat:@"%@一", keyword] itemId:@"0000" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@二", keyword] itemId:@"0001" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@三", keyword] itemId:@"0002" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@四", keyword] itemId:@"0003" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@五", keyword] itemId:@"0004" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@六", keyword] itemId:@"0005" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@七", keyword] itemId:@"0006" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@八", keyword] itemId:@"0007" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@九", keyword] itemId:@"0008" selected:NO],
//                       [self createItemModelWithTitle:[NSString stringWithFormat:@"%@十", keyword] itemId:@"0009" selected:NO]
//                       ];
//    return model;
//}
//
//- (CommonItemModel *)createItemModelWithTitle:(NSString *)itemTitle
//                                       itemId:(NSString *)itemId
//                                     selected:(BOOL)selected {
//    CommonItemModel *model = [[CommonItemModel alloc] init];
//    model.itemId = itemId;
//    model.itemName = itemTitle;
//    model.selected = selected;
//    return model;
//}











- (void)makeConstraints {
    //约束：
    [self.selectedDateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
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
     [self.scrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(self.view.frame) * self.segmentedControl.selectedSegmentIndex, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.scrollView.frame)) animated:YES]; //1  index
    [self datepicker:self.datepicker didSelectDate:[NSDate date]];//2 date
   
   
}
- (void)createSegments {
  
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.scrollView];
  
    
//label indicator
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), AM_SCREEN_HEIGHT - 104)];
    [self setApperanceForLabel:label1];
    label1.text = @"SD卡";
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), AM_SCREEN_HEIGHT - 104)];
    [self setApperanceForLabel:label2];
    label2.text = @"中继";
  
    /*
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth * 2, 0, viewWidth, AM_SCREEN_HEIGHT - 104)];
    [self setApperanceForLabel:label3];
    label3.text = @"云存储";
    [self.scrollView addSubview:label3];
    */
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * 3, 0, CGRectGetWidth(self.view.frame), AM_SCREEN_HEIGHT - 104)];
    [self setApperanceForLabel:label4];
    label4.text = @"本地";

    [self.scrollView addSubview:label1];
    [self.scrollView addSubview:label2];
    [self.scrollView addSubview:label4];
    
}


#pragma mark - getter
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake((self.view.bounds.size.width) * 3, 1);
    }
    
    return _scrollView;
}
- (ScrollableDatepicker *)datepicker {
    
    if (!_datepicker) {
        _datepicker = [[ScrollableDatepicker alloc] initWithFrame:CGRectZero];
        [_datepicker setBackgroundColor:[UIColor lightGrayColor]];
        
        NSMutableArray *dateArray = [NSMutableArray array];
        for (int i = -5; i < 10; i++) {
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
        _segmentedControl.sectionTitles = @[@"SD卡", @"中继",@"本地"];
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
    PageController *page = self.childViewControllers[self.segmentedControl.selectedSegmentIndex];
    if (!page.view.superview) {
        [self.scrollView addSubview:page.tableView];
        page.view.frame = scrollView.bounds;
        
    }
    
   
}




#pragma mark -  DatePickerDelegate
- (void)datepicker:(ScrollableDatepicker *)datepicker didSelectDate:(NSDate *)date {
    [self showSelectedDate];
    [self handle:self.childViewControllers[self.segmentedControl.selectedSegmentIndex] sender:self.segmentedControl];

}
//日期格式
- (void)showSelectedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd";//@"dd-MMMM YYYY" yyyy-MM-dd HH:mm:ss ,默认  00:00:00
    self.selectedDateLb.text = [dateFormat stringFromDate:self.datepicker.selectedDate];
    [self.datepicker scrollToSelectedDateWithAnimated:YES];
}

- (void)handle:(PageController *)page sender:(HMSegmentedControl *)sgc {
    
    //if index == base station  & online
    //get status
    NSLog(@"LibViewController 当前线程: %@",[NSThread currentThread]);
    if (sgc.selectedSegmentIndex == 1) {
        int sec = [self.datepicker.selectedDate timeIntervalSince1970];
        
        //test: choose 0
//        Device *coludDevice = [[Device allObjects] objectAtIndex:0];
        self.cloudDevice.delegate = [self.childViewControllers objectAtIndex:sgc.selectedSegmentIndex];//page
        
        //主动获取设备状态
        if (self.cloudDevice.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
            [MBProgressHUD showSpinningWithMessage:@"downloding..." toView:page.tableView];
            RLMThreadSafeReference *deviceRef = [RLMThreadSafeReference
                                                 referenceWithThreadConfined:self.cloudDevice];
         
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                @autoreleasepool {
                    RLMRealm *realm = [RLMRealm realmWithConfiguration:RLM.configuration error:nil];
                    Device *device = [realm resolveThreadSafeReference:deviceRef];
                    if (device) {
                        cloud_device_cam_list_files((void *)device.nvr_h,0,  sec,sec + 24 * 3600,RECORD_TYPE_ALL);
                    }
                }
                
            });
        }else {
            [MBProgressHUD showError:@"Check Device Status"];
        }
        
        
        
    }
}



@end
