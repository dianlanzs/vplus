//
//  RegionModel.h
//  Kamu
//
//  Created by Zhoulei on 2018/5/10.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemModel.h"


@interface RegionModel : NSObject  //section
@property (copy, nonatomic) NSString *containerCellClass;

@property (copy, nonatomic) NSString *regionTitle;  //section tiitle
@property (strong, nonatomic) NSArray *itemList;



@property (assign, nonatomic) BOOL isShowAll; //是否展开
@property (strong, nonatomic) NSArray *selectedItemList;//user  choosed  data
@property (strong, nonatomic) NSDictionary *customDict;//附加内容
@end
