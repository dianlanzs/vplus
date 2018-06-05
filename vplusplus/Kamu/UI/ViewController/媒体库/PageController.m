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

@property (nonatomic, strong) Device *cDevice;
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
    return self.cDevice.nvr_cams.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    RLMArray *medias = [self.cDevice.nvr_cams[section] cam_medias];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%d > createtime AND createtime > %d",
                       self.start_daySec + 24 * 3600 , self.start_daySec];
    RLMResults *res = [medias objectsWithPredicate:pred];
    return res.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    // 1.要用 forIndexpath 注册Register ,   2.不注册 不需要 ,   3.stroyBoard 不需要 if(!cell)
    MediaLibCell *mediaCell = [tableView dequeueReusableCellWithIdentifier:@"1"];
    mediaCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!mediaCell) {
        // owner 可以 = nil 可以填 self  ,// If the owner parameter is nil, connections to File's Owner are not permitted.
        mediaCell = [[[UINib nibWithNibName:NIB(MediaLibCell) bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    }
    RLMArray *medias = [self.cDevice.nvr_cams[indexPath.section] cam_medias];
    RLMResults *res = [medias objectsWhere:[NSString stringWithFormat:@"%d < createtime AND createtime < %d",self.start_daySec,self.start_daySec + 24 *3600]];
    [mediaCell setEntity:res[indexPath.row]];
    
    mediaCell.playcallback = ^(MediaLibCell *cell) {
        
        PlaybackViewController *playbackVc = [[PlaybackViewController alloc] init];
        [playbackVc.playerModel setCam_id:[self.cDevice.nvr_cams[indexPath.section] cam_id]];
        [playbackVc.playerModel setNvr_h:self.cDevice.nvr_h];
        [playbackVc.playerModel setCam_entity:cell.entity];

        [playbackVc.playerModel setTitle:[medias[indexPath.row] fileName]];
        [playbackVc.playerModel setNvr_status:self.cDevice.nvr_status];
        [self.cDevice setAvDelegate:playbackVc.vp];
        
        NSLog(@"🙂%zd,%@,%@",playbackVc.playerModel.nvr_h,playbackVc.playerModel.cam_id, [medias[indexPath.row] fileName]);
        [self.navigationController pushViewController:playbackVc animated:YES];
    };
    return  mediaCell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    size_t ,zd
    NSLog(@"didSelectRowAtIndexPath---%zd",indexPath.row);
}
- (void)device:(Device *)selectedNvr sendListData:(void *)data dataType:(int)type {
    record_filelist_t *info = (record_filelist_t *)data;
    int num = info -> num; //cells
    rec_file_block *block = info -> blocks;
    
    for (int i = 0; i < num; i++) {
        
        MediaEntity *media = [MediaEntity new];
        media.createtime = (block+i) -> createtime;
        media.fileName = [NSString stringWithUTF8String:(block+i) -> filename];
        media.filelength = (block+i) -> filelength;
        media.recordType = (block+i) -> recordtype;
        media.timelength = (block+i) -> timelength;
        NSLog(@"create time : %@",[NSString stringWithFormat:@"createtime == %d", (block+i) -> createtime]);
        NSLog(@"filename : %@",[NSString stringWithFormat:@"filename == %s", (block+i) -> filename]);
        Cam *db_cam =  [[selectedNvr.nvr_cams objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",[NSString stringWithUTF8String:(block+i) -> camdid]]] firstObject];
        MediaEntity *db_media = [[db_cam.cam_medias objectsWhere:[NSString stringWithFormat:@"createtime == %d", (block+i) -> createtime]] firstObject];
        if (db_cam && !db_media) {
            [RLM transactionWithBlock:^{
                [db_cam.cam_medias addObject:media];
            }];
        }
    }
    self.cDevice = selectedNvr;
    NSLog(@"pageVC 当前线程: %@",[NSThread currentThread]);
    [MBProgressHUD hideHUDForView:self.view animated:YES]; //data already got
//    [MBProgressHUD hideHUD]; //data already got

    [self.tableView reloadData];
}






#pragma mark - getter

- (void)configTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setRowHeight:100];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}



@end
