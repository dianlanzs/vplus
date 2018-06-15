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




@property (nonatomic, strong) RLMResults<Device *> *results;




//
//
//
//@property (nonatomic, strong) NSString *device_id;
//@property (nonatomic, strong) NSString *cam_id;
//
//
//@property (nonatomic, strong) Device *device;
//@property (nonatomic, strong) Device *cam;

- (void)backPrevious:(id)sender;
//- (void)pushViewController:(UIViewController *)vc withDevice:(Device *)device;



//- (void)pushViewController:(UIViewController *)vc deviceID:(NSString *)deviceID camID:(NSString *)camID;
- (void)pushViewController:(UIViewController *)vc deviceModel:(Device *)deviceModel camModel:(Cam *)camModel;

-(void)jumpToViewctroller:(NSDictionary *)remoteNotification;
@end
