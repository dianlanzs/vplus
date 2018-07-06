//
//  PageController.m
//  测试Demo
//
//  Created by Zhoulei on 2018/3/2.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "PageController.h"
#import "MediaLibCell.h"

#import "ZLPlayerView.h"
#import "ZLPlayerModel.h"
#import "LibraryController.h"
#import "PlaybackViewController.h"

//
#define SEC_00 [self.selectedDate timeIntervalSince1970]
#define SEC_24 SEC_00 + 24 * 3600
#define CAMS       [Cam allObjects]

@interface PageController ()

@property (nonatomic, strong) ZLPlayerView *vpTool;
@property (nonatomic, strong) NSPredicate *predicate_selectedDate;
@end

@implementation PageController






#pragma mark - life circle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)tempCams {
    
    if (!_tempCams) {
        _tempCams = [@[] mutableCopy];
        for (Cam *tempCam in self.parentViewController.navigationController.operatingDevice.nvr_cams) {
            [_tempCams addObject:tempCam];
        }
    }
    return _tempCams;
}


#pragma mark - Table view data source


- (NSMutableArray *)cloudMediasWithIndex:(NSInteger)index {
    return [self.parentViewController.navigationController.operatingDevice.nvr_cams[index] cam_cloudMedias];
}

- (NSPredicate *)predicate_selectedDate {

    return [NSPredicate predicateWithFormat:@"%d > createtime AND createtime > %d",self.zero_seconds + 24 * 3600 , self.zero_seconds];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tempCams.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *cloudMedias =  [self.tempCams[section] cam_cloudMedias];
    NSArray *res = [cloudMedias filteredArrayUsingPredicate:self.predicate_selectedDate];
    return  res.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 1.  RegisterCell  must use forIndexpath ,   2.if u no register no use indexpath ,   3.stroyBoard use if(!cell)
    MediaLibCell *mediaCell = [tableView dequeueReusableCellWithIdentifier:@"1"];
    mediaCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!mediaCell) {
        // owner can  = nil and = self  ,// If the owner parameter is nil, connections to File's Owner are not permitted.
        mediaCell = [[[UINib nibWithNibName:NIB(MediaLibCell) bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    }
    NSMutableArray *cloudMedias =  [self.tempCams[indexPath.section] cam_cloudMedias];
    NSArray *res = [cloudMedias filteredArrayUsingPredicate:self.predicate_selectedDate];
    if (res.count) {
        [mediaCell setEntity:res[indexPath.row]];
        mediaCell.playcallback = ^(MediaLibCell *cell) {
            
            PlaybackViewController *playbackVc = [[PlaybackViewController alloc] init];
            [self.navigationController pushViewController:playbackVc deviceModel:self.parentViewController.navigationController.operatingDevice camModel:self.parentViewController.navigationController.operatingCam];
            
            [self.navigationController.operatingCam setCam_id:[self.navigationController.operatingDevice.nvr_cams[indexPath.section] cam_id]];
            [self.navigationController setOperatingMedia:cell.entity];
        };
    }

    return  mediaCell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    size_t ,zd
    NSLog(@"didSelectRowAtIndexPath---%zd",indexPath.row);
}


#pragma mark - getter

- (void)configTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setRowHeight:100];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
//    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
//        NSInteger remainCount = self.totalMedias.count - self.shortMedias.count;
//       self.shortMedias =  [self.totalMedias subarrayWithRange:NSMakeRange(self.shortMedias.count, remainCount > 20 ? 20 : remainCount)];
//    }];
}

/*
- (NSArray *)shortMedias {
    if (!_shortMedias) {
        _shortMedias = [NSArray array];
    }
    
}
- (NSMutableArray *)totalMedias {
    if (!_totalMedias) {
        _totalMedias = [NSMutableArray array];
    }
    [_totalMedias filteredArrayUsingPredicate:self.predicate_selectedDate];
    return _totalMedias;
}
*/

@end
