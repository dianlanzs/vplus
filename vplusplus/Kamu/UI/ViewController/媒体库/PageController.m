//
//  PageController.m
//  测试Demo
//
//  Created by YGTech on 2018/3/2.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "PageController.h"
#import "MediaLibCell.h"


#import "ZFPlayer.h"

#import "LibraryController.h"




#define CAMS       [Cam allObjects]

@interface PageController ()<ZFPlayerDelegate,ZLNvrDelegate >

@property (nonatomic, strong) NSMutableArray *medias;

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




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      return self.medias.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    // 1.要用 forIndexpath 注册Register ,   2.不注册 不需要 ,   3.stroyBoard 不需要 if(!cell)
    MediaLibCell *mediaCell = [tableView dequeueReusableCellWithIdentifier:@"1"];
    mediaCell.selectionStyle = UITableViewCellSelectionStyleNone;//点击cell没点击阴影效果
    if (!mediaCell) {
        // owner 可以 = nil 可以填 self  , 但是 填 self 引用了这个你把 就不能在这个类中 即不允许 建立 IBOutlet ,
        mediaCell = [[[UINib nibWithNibName:NIB(MediaLibCell) bundle:nil] instantiateWithOwner:self options:nil] firstObject]; //
    }
    MediaEntity *me = [self.medias objectAtIndex:indexPath.section];
    [mediaCell setEntity:me];
    return  mediaCell;
    
}



- (void)device:(Device *)selectedNvr sendData:(void *)data dataType:(int)type {
    record_filelist_t *info = (record_filelist_t *)data;
    int num = info -> num; //cells
    rec_file_block *b = info -> blocks;
    
    self.medias = [NSMutableArray array];
    
    for (int i = 0; i<num; i++) {
        @autoreleasepool {
            MediaEntity *me = [MediaEntity new];
            me.createtime = (b+i) -> createtime;
            me.fileName = [NSString stringWithUTF8String:(b+i) -> filename];
            me.filelength = (b+i) -> filelength;
            me.recordType = (b+i) -> recordtype;
            me.timelength = (b+i) -> timelength;
            
            [self.medias addObject:me];
        }
    }
    [MBProgressHUD hideHUD];
    [MBProgressHUD hideHUDForView:self.tableView animated:YES]; //data already got
    NSLog(@"pageVC 当前线程: %@",[NSThread currentThread]);
    [self.tableView reloadData];
    
    
    
}




#pragma mark - getter
//- (NSMutableArray *)medias {
//    if (_medias) {
//        _medias = [NSMutableArray array];
//    }
//    return _medias;
//}


- (void)configTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setRowHeight:100];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}


@end
