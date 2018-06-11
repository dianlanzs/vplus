//
//  AMNavigationController.h
//  Kamu
//
//  Created by Zhoulei on 2017/11/20.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AMNavigationController : UINavigationController

@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) NSString *navTitle;
@property (nonatomic, strong) Device *pushedDevice;

- (void)backPrevious:(id)sender;
- (void)pushViewController:(UIViewController *)vc withDevice:(Device *)pushedDevice;
-(void)jumpToViewctroller:(NSDictionary *)remoteNotification;
@end
