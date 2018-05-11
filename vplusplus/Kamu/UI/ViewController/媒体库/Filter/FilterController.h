//
//  FilterController.h
//  Kamu
//
//  Created by YGTech on 2018/5/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^commit)(NSArray *dataList);
typedef void (^reset)(NSArray  *dataList);


@interface FilterController : UIViewController
@property (assign, nonatomic) CGFloat animationDuration;
@property (assign, nonatomic) CGFloat leading;
@property (copy, nonatomic) NSArray *regionList; //dataList  1
- (instancetype)initWithSponsor:(UIViewController *)sponsor
                     resetBlock:(reset)resetBlock
                    commitBlock:(commit)commitBlock;
- (void)show;
- (void)dismiss;
- (void)reloadData;
@end
