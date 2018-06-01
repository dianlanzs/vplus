//
//  ItemModel.h
//  Kamu
//
//  Created by Zhoulei on 2018/5/11.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemModel : NSObject
@property (copy, nonatomic) NSString *itemId;
@property (copy, nonatomic) NSString *itemName;
@property (assign, nonatomic) BOOL selected;

@property (nonatomic, assign) NSString * cam_id;
@end
