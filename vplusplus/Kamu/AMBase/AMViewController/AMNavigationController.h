//
//  AMNavigationController.h
//  Kamu
//
//  Created by YGTech on 2017/11/20.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AMNavigationController : UINavigationController

@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) NSString *navTitle;


- (void)backPrevious:(id)sender;
@end
