//
//  FilterController.m
//  Kamu
//
//  Created by YGTech on 2018/5/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "FilterController.h"

#import "RegionModel.h"

#import "FilterCell.h"

#import "objc/message.h"
#import "objc/runtime.h"

#define BOTTOM_BUTTON_HEIGHT 0.05 * AM_SCREEN_HEIGHT


//推进来 的 frame
#define SLIP_DISTINATION_FRAME CGRectMake(self.leading, 0, AM_SCREEN_WIDTH - self.leading, AM_SCREEN_HEIGHT)

//Notification
NSString * const FILTER_NOTIFICATION_NAME_DID_RESET_DATA = @"FILTER_NOTIFICATION_NAME_DID_RESET_DATA";
NSString * const FILTER_NOTIFICATION_NAME_DID_COMMIT_DATA = @"FILTER_NOTIFICATION_NAME_DID_COMMIT_DATA2";

const CGFloat ANIMATION_DURATION_DEFAULT = 0.3f;
const CGFloat SIDE_SLIP_LEADING_DEFAULT = 100; //60

NSString * const FILTER_NAVIGATION_CONTROLLER_CLASS = @"UINavigationController";
#define SLIP_ORIGIN_FRAME CGRectMake(AM_SCREEN_WIDTH, 0, AM_SCREEN_WIDTH - self.leading, AM_SCREEN_HEIGHT)

@interface FilterController () <UITableViewDelegate, UITableViewDataSource, FilterCellDelegate>

@property (copy, nonatomic) commit commitBlock;
@property (copy, nonatomic) reset resetBlock;
@property (weak, nonatomic) UINavigationController *filterNavigation;
@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) UIView *backCover;
@property (weak, nonatomic) UIViewController *sponsor;
@property (strong, nonatomic) NSMutableDictionary *templateCellDict;



@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) UIButton *commitBtn;

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation FilterController
- (instancetype)initWithSponsor:(UIViewController *)sponsor
                     resetBlock:(reset)resetBlock
                    commitBlock:(commit)commitBlock {
    self = [super init];
    if (self) {
        NSAssert(sponsor.navigationController, @"ERROR: sponsor must have the navigationController");
        _sponsor = sponsor;
        _resetBlock = resetBlock;
        _commitBlock = commitBlock;
        UINavigationController *filterNavigation = [[NSClassFromString(FILTER_NAVIGATION_CONTROLLER_CLASS) alloc] initWithRootViewController:self];
        [filterNavigation setNavigationBarHidden:YES];
        filterNavigation.navigationBar.translucent = NO;
        [filterNavigation.view setFrame:SLIP_ORIGIN_FRAME]; //Frame
        self.filterNavigation = filterNavigation;
        [self configureStatic];
    
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self.view setBackgroundColor:[UIColor yellowColor]];
}




- (void)configureStatic {
    self.animationDuration = ANIMATION_DURATION_DEFAULT;
//    self.leading = SIDE_SLIP_LEADING_DEFAULT;
}


- (void)show {
    [_sponsor.navigationController.view addSubview:self.backCover];
    [_sponsor.navigationController addChildViewController:self.navigationController];
    [_sponsor.navigationController.view addSubview:self.navigationController.view];
    [self.navigationController didMoveToParentViewController:_sponsor.navigationController];
    
    [_backCover setHidden:YES];
    [UIView animateWithDuration:_animationDuration animations:^{
        [self.navigationController.view setFrame:CGRectMake(self.leading, 0, AM_SCREEN_WIDTH - self.leading, AM_SCREEN_HEIGHT)];
    } completion:^(BOOL finished) {
        [_backCover setHidden:NO];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:_animationDuration animations:^{
        [self.navigationController.view setFrame:SLIP_ORIGIN_FRAME];
    } completion:^(BOOL finished) {
        [_backCover removeFromSuperview];
        [self.navigationController.view removeFromSuperview];
        [self.navigationController removeFromParentViewController];
    }];
}









- (void)clickResetButton:(id)sender {
    self.resetBlock(_regionList);
    [[NSNotificationCenter defaultCenter] postNotificationName:FILTER_NOTIFICATION_NAME_DID_RESET_DATA object:nil];
    [self.mainTableView reloadData];
}

- (void)clickCommitButton:(id)sender {
    self.commitBlock(_regionList);
    [[NSNotificationCenter defaultCenter] postNotificationName:FILTER_NOTIFICATION_NAME_DID_COMMIT_DATA object:nil];
}

- (void)clickBackCover:(id)sender {
    [self dismiss];
}

- (void)reloadData {
    if (self.mainTableView) {
        [self.mainTableView reloadData];
    }
}



//mark

id (*objc_msgSendGetCellIdentifier)(id self, SEL _cmd) = (void *)objc_msgSend;
CGFloat (*objc_msgSendGetCellHeight)(id self, SEL _cmd) = (void *)objc_msgSend;
id (*objc_msgSendCreateCellWithIndexPath)(id self, SEL _cmd, NSIndexPath *) = (void *)objc_msgSend;



#pragma mark - DataSource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;   //1 ---cams
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
     return  self.regionList.count;   //1 ---cams
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    RegionModel *model = self.regionList[indexPath.row];  //1 ----cams
//
//
//
//    Class cellClazz =  NSClassFromString(model.containerCellClass);
//    if ([(id)cellClazz respondsToSelector:@selector(cellHeight)]) {
//        CGFloat cellHeight = objc_msgSendGetCellHeight(cellClazz, NSSelectorFromString(@"cellHeight"));
//        return cellHeight;
//    }
//
//    NSString *identifier = objc_msgSendGetCellIdentifier(cellClazz, NSSelectorFromString(@"cellReuseIdentifier"));
//
//
//    FilterCell *templateCell = [self.templateCellDict objectForKey:identifier];
//    if (!templateCell) {
//        templateCell = objc_msgSendCreateCellWithIndexPath(cellClazz, NSSelectorFromString(@"createCellWithIndexPath:"), indexPath);
//        templateCell.delegate = self;
//        [self.templateCellDict setObject:templateCell forKey:identifier];
//    }
//    //update
//    [templateCell updateCellWithModel:&model indexPath:indexPath];
//    //calculate
//    NSLayoutConstraint *calculateCellConstraint = [NSLayoutConstraint constraintWithItem:templateCell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:self.view.bounds.size.width];
//    [templateCell.contentView addConstraint:calculateCellConstraint];
//    CGSize cellSize = [templateCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    [templateCell.contentView removeConstraint:calculateCellConstraint];
//    return cellSize.height;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegionModel *model = self.regionList[indexPath.row];
    
    
    Class cellClazz =  NSClassFromString(model.containerCellClass);
    //obtain cell
    FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:objc_msgSendGetCellIdentifier(cellClazz, NSSelectorFromString(@"cellReuseIdentifier"))];
    if (!cell) {
        cell = objc_msgSendCreateCellWithIndexPath(cellClazz, NSSelectorFromString(@"createCellWithIndexPath:"), indexPath);
        cell.delegate = self;
    }
    
    [tableView setRowHeight:400.f];
    //update  binding Model
    [cell updateCellWithModel:&model indexPath:indexPath];
    return cell;
}




//refresh
- (void)sideSlipTableViewCellNeedsReload:(NSIndexPath *)indexPath {
    [self.mainTableView reloadData];
}

//push
- (void)sideSlipTableViewCellNeedsPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController pushViewController:viewController animated:animated];
}
//scroll to ..
- (void)sideSlipTableViewCellNeedsScrollToCell:(UITableViewCell *)cell atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    NSIndexPath *indexPath = [self.mainTableView indexPathForRowAtPoint:cell.center];
    [self.mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void)configureUI {
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    
    
    [self.resetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.size.mas_equalTo(CGSizeMake((AM_SCREEN_WIDTH - self.leading) * 0.5, 60.f));//self.view.bounds) *0.5
        //            make.top.bottom.equalTo(_bottomView);
    }];
    
    [self.commitBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.size.mas_equalTo(self.resetBtn);
        //            make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.bounds), 60.f));
        
    }];
    
    [self.bottomView distributeSpacingHorizontallyWith:@[self.resetBtn, self.commitBtn]];

    
    
    
    
    
    
    
    [self.view addSubview:self.mainTableView];
  
//    [_mainTableView setTableFooterView:bottomView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_bottomView.mas_top);
        make.top.leading.trailing.mas_equalTo(self.view);
    }];
    
    

    
////
//    NSDictionary *views = @{@"mainTableView":self.mainTableView, @"bottomView":bottomView};
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:BOTTOM_BUTTON_HEIGHT]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView][bottomView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
}
//reset & commit buttons


- (UIButton *)resetBtn {
    
    if (!_resetBtn) {
        //resetButton
        _resetBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_resetBtn addTarget:self action:@selector(clickResetButton:) forControlEvents:UIControlEventTouchUpInside];
        [_resetBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_resetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //    NSString *resetString = LocalString(@"sZYFilterReset");
        NSString *resetString = @"sZYFilterReset";
        
        if ([resetString isEqualToString:@"sZYFilterReset"]) {
            resetString = @"Reset";
        }
        [_resetBtn setTitle:resetString forState:UIControlStateNormal];
        [_resetBtn setBackgroundColor:[UIColor lightGrayColor]];
    }
    return _resetBtn;
}
- (UIButton *)commitBtn {
    if (!_commitBtn) {
        _commitBtn = [[UIButton alloc] initWithFrame:CGRectZero];
//        [_commitBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_commitBtn addTarget:self action:@selector(clickCommitButton:) forControlEvents:UIControlEventTouchUpInside];
        [_commitBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //    NSString *commitString = LocalString(@"sZYFilterCommit");
        NSString *commitString = @"sZYFilterCommit";
        
        if ([commitString isEqualToString:@"sZYFilterCommit"]) {
            commitString = @"Commit";
        }
        [_commitBtn setTitle:commitString forState:UIControlStateNormal];
        [_commitBtn setBackgroundColor:[UIColor blueColor]];
    }
    
    return _commitBtn;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        //    [bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
       
        [_bottomView addSubview:self.resetBtn];
        [_bottomView addSubview:self.commitBtn];
        
//

  
        
        [_bottomView setBackgroundColor:[UIColor purpleColor]];
        
        //constraints
        //    NSDictionary *views = NSDictionaryOfVariableBindings(resetButton, commitButton);
        //    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[resetButton][commitButton]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        //    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[resetButton]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        //    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[commitButton]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        //    [bottomView addConstraint:[NSLayoutConstraint constraintWithItem:resetButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:commitButton attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    }
    
    return _bottomView;
}

#pragma mark - GetSet
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView setBackgroundColor:[UIColor whiteColor]];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
//        [_mainTableView setRowHeight:400.f];
        
//        if (@available(iOS 11.0, *)) {
//            [_mainTableView setDirectionalLayoutMargins:NSDirectionalEdgeInsetsMake(0, 20, 0, 0)];
//        } else {
//            [_mainTableView setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 0)];
//        }
        //        [_mainTableView setContentInset:UIEdgeInsetsMake(64, 20, 0, 0)];  ///MARK: 不能这样设置，，会导致 左右上下的滑动
        
//        [_mainTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
    }
    return _mainTableView;
}

- (NSMutableDictionary *)templateCellDict {
    if (!_templateCellDict) {
        _templateCellDict = [NSMutableDictionary dictionary];
    }
    return _templateCellDict;
}

- (UIView *)backCover {
    if (!_backCover) {
        _backCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AM_SCREEN_WIDTH, AM_SCREEN_HEIGHT)];
        [_backCover setBackgroundColor:[UIColor colorWithHex:@"000000"]];
        [_backCover setAlpha:.6f];
        [_backCover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackCover:)]];
    }
    return _backCover;
}

- (UINavigationController *)filterNavigation {
    return objc_getAssociatedObject(_sponsor, _cmd);
}

- (void)setFilterNavigation:(UINavigationController *)filterNavigation {
    //让sponsor持有filterNavigation
    objc_setAssociatedObject(_sponsor, @selector(filterNavigation), filterNavigation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setRegionList:(NSArray *)regionList {
    _regionList = [regionList copy];  //NSArray ,NSstring 内部 本来就 固化 了 copy处理  ，不可变对象 用copy属性  /if  引用 的 外界regionList 是一个可变数组 ，那么self.regionList 是很危险 的， 容易数组越界 ，crash ， so use "copy "       ******************   cuz  重写了 set 方法？？  ******************
    if (_mainTableView) {
        [_mainTableView reloadData];
    }
}
@end
