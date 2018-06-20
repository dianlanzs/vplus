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

@interface PageController ()<ZLNvrDelegate >

//@property (nonatomic, strong) Device *cDevice;
@property (nonatomic, strong) ZLPlayerView *vpTool;

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


//- (NSMutableDictionary *)mDict {
//    if (_mDict) {
//        _mDict = [@{} mutableCopy]; //分配内存 ,且 return mutable 对象
//    }
//    
//    return _mDict;
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ((LibraryController *)self.parentViewController).operatingDevice.nvr_cams.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    RLMArray *medias = [((LibraryController *)self.parentViewController).operatingDevice.nvr_cams[section] cam_medias];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%d > createtime AND createtime > %d",
                       self.start_daySec + 24 * 3600 , self.start_daySec];
    RLMResults *res = [medias objectsWithPredicate:pred];
    return res.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    // 1.  RegisterCell  must use forIndexpath ,   2.if u no register no use indexpath ,   3.stroyBoard use if(!cell)
    MediaLibCell *mediaCell = [tableView dequeueReusableCellWithIdentifier:@"1"];
    mediaCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!mediaCell) {
        // owner can  = nil and = self  ,// If the owner parameter is nil, connections to File's Owner are not permitted.
        mediaCell = [[[UINib nibWithNibName:NIB(MediaLibCell) bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    }
    RLMArray *medias = [((LibraryController *)self.parentViewController).operatingDevice.nvr_cams[indexPath.section] cam_medias];
    RLMResults *res = [medias objectsWhere:[NSString stringWithFormat:@"%d < createtime AND createtime < %d",self.start_daySec,self.start_daySec + 24 *3600]];
    [mediaCell setEntity:res[indexPath.row]];
    
    mediaCell.playcallback = ^(MediaLibCell *cell) {
        
        PlaybackViewController *playbackVc = [[PlaybackViewController alloc] init];
        LibraryController *libVc = (LibraryController *)self.parentViewController;
        [(AMNavigationController *)self.navigationController pushViewController:playbackVc deviceModel:libVc.operatingDevice camModel:libVc.operatingCam];
  
        [playbackVc.operatingCam setCam_id:[libVc.operatingDevice.nvr_cams[indexPath.section] cam_id]];
        [playbackVc setOperatingMedia:cell.entity];
    };
    return  mediaCell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    size_t ,zd
    NSLog(@"didSelectRowAtIndexPath---%zd",indexPath.row);
}
//- (void)device:(Device *)selectedNvr sendListData:(void *)data dataType:(int)type {
//    ;
//}






#pragma mark - getter

- (void)configTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setRowHeight:100];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}



@end
