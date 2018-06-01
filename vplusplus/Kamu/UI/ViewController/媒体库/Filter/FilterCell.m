//
//  FilterCell.m
//  Kamu
//
//  Created by Zhoulei on 2018/5/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "FilterCell.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"



//NSString * const FILTER_NOTIFICATION_NAME_DID_RESET_DATA = @"FILTER_NOTIFICATION_NAME_DID_RESET_DATA";


@implementation FilterCell
#pragma clang diagnostic pop

+ (NSString *)cellReuseIdentifier {
    NSAssert(NO, @"\nERROR: Must realize this function in subClass %s", __func__);
    return nil;
}

+ (instancetype)createCellWithIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"\nERROR: Must realize this function in subClass %s", __func__);
    return nil;
}

- (void)updateCellWithModel:(RegionModel *__autoreleasing *)model
                  indexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"\nERROR: Must realize this function in subClass %s", __func__);
}



- (void)dealloc {
    [self resignNotification];
}

- (void)resetData {
    ;
    //reset data trigger
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name: @"FILTER_NOTIFICATION_NAME_DID_RESET_DATA" object:nil];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self registerNotification];
}
- (void)resignNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
