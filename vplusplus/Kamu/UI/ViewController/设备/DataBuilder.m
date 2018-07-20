//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import <objc/runtime.h>
#import "DataBuilder.h"
#import "QDynamicDataSection.h"
#import "PeriodPickerValueParser.h"
#import "QMapElement.h"
#import "QWebElement.h"
#import "QMailElement.h"
#import "QPickerElement.h"
#import "QFloatElement.h"



static NSString  *rootControllerName = @"NvrSettingsController";

@implementation DataBuilder


#pragma mark - 创建 CAM settings 界面
- (QRootElement *)createForCamSettings:(Cam *)cam {


    QRootElement *camRoot = [[QRootElement alloc] init];
    [camRoot setGrouped:YES];
    camRoot.title =  @"设置CAM";
    
    [camRoot setObject:[NSDictionary dictionaryWithObjectsAndKeys:cam,@"camModel",nil]];
    
    QSection *section0 = [[QSection alloc] initWithTitle:@"CAM_Header"];
    section0.elements = [NSMutableArray arrayWithArray:@[[self changeCamNameElm:cam],[self camSwitchElm],[self batteryWarningElm:cam],[self imageTransformElm:cam],[self motionDetectElm:cam],[self camInfoElm:cam]]];
    
    [camRoot addSection:section0];
    [self  setAppearance:camRoot];
    return camRoot;
    
}

- (QBooleanElement *)camSwitchElm {
    QBooleanElement *camSwitch = [[QBooleanElement alloc] initWithTitle:@"摄像头开关" BoolValue:YES];
    camSwitch.controllerAction = @"camSwitch:";
    return camSwitch;
}

- (QFloatElement *)batteryWarningElm:(Cam *)cam {
    QFloatElement *batteryWarningElm = [[QFloatElement alloc] initWithTitle:@"电量剩余报警" value:0.f];
    [batteryWarningElm setEnabled:NO];
    [batteryWarningElm setKey:@"cam_battery_threshold"];
//    batteryAlert.onValueChanged = ^(NSNumber *value) {
//        batteryAlert set
//    };
    [batteryWarningElm setHeight:80];
    return batteryWarningElm;
}

- (QElement *)changeCamNameElm:(Cam *)cam {
    
    NSString *s = cam.cam_name ? cam.cam_name :cam.cam_id;
    
    
    
    QRootElement *camNameElm = [[QRootElement alloc] init];
    camNameElm.grouped = YES;
    camNameElm.title = @"修改Cam名称";
    [camNameElm setKey:@"changeCamName"];
    camNameElm.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    

    QSection *section0 = [[QSection alloc] initWithTitle:@"CHANGE_CAM_NAME"];
  
    QEntryElement *entryElm = [[QEntryElement alloc] initWithTitle:@"别名" Value:s Placeholder:@"this is holder"];
    [entryElm setKey:@"cam_rename"];
//    [entryElm setTf_endEditing:^(UITextField *tf) {
//        if (tf.text != s ) {
//            [RLM transactionWithBlock:^{
//                [cam setCam_name:tf.text];
//            }];
//        }
//
//    }];
    
    [section0 addElement:entryElm];
    [camNameElm addSection:section0];
    return camNameElm;
}


- (QBooleanElement *)imageTransformElm:(Cam *)cam {
    QBooleanElement *imageTransformElm = [[QBooleanElement alloc] initWithTitle:@"图像旋转" BoolValue:YES];
    [imageTransformElm setEnabled:NO];

    [imageTransformElm setKey:@"cam_rotate"];

    return imageTransformElm;
}

- (QFloatElement *)motionDetectElm:(Cam *)cam {
    QFloatElement *motionDetectElm = [[QFloatElement alloc] initWithTitle:@"移动侦测灵敏度" value:0.f];
    [motionDetectElm setEnabled:NO];
    
    [motionDetectElm setKey:@"cam_pir_sensitivity"];//NSStringFromClass([QFloatElement class])
    [motionDetectElm setHeight:80];
    return motionDetectElm;
}


- (QElement *)camInfoElm:(Cam *)cam {
    QRootElement *camInfoRoot = [[QRootElement alloc] init];
    camInfoRoot.grouped = YES;
    camInfoRoot.title = @"摄像头信息";
    camInfoRoot.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    QSection *infoSection = [[QSection alloc] initWithTitle:@"CAM_INFO"];
    QLabelElement *cid = [[QLabelElement alloc] initWithTitle:@"ID" Value:[cam.cam_id uppercaseString]];
    QLabelElement *version = [[QLabelElement alloc] initWithTitle:@"version" Value:[cam.cam_version uppercaseString]];

    [infoSection addElement:cid];
    [infoSection addElement:version];

    [camInfoRoot addSection:infoSection];
    return camInfoRoot;
}


#pragma mark - 创建 NVR settings 界面

- (QRootElement *)createForNvrSettings:(Device *)device {
    
    
    QRootElement *nvrRoot = [[QRootElement alloc] init];
    nvrRoot.grouped = YES;
    nvrRoot.title = @"设置NVR";
    
    
    //嵌套section
    QSection *section0 = [[QSection alloc] init];
    section0.elements = [NSMutableArray arrayWithArray:@[[self changeNvrNameElm:device],[self recordElm],[self authorityElm],[self infoElm:device]]];
    
    

    [nvrRoot setPreselectedElementIndex:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    
//    [nvrRoot setAppearance:[self customAppearance]];
//    [[self new] setAppearance];//设置外观，add
    [nvrRoot addSection:section0];
//    [self setAppearance];
    [self setAppearance:nvrRoot];

    return nvrRoot;
}

- (QElement *)recordElm {
    QBooleanElement *recordElm = [[QBooleanElement alloc] initWithTitle:@"本地存储" BoolValue:YES];
    recordElm.controllerAction = @"exampleAction:";
    recordElm.key = @"bool1";
    return recordElm;
}
//authority
- (QElement *)authorityElm {
    
    QRootElement *authorityElm = [[QRootElement alloc] init];
    authorityElm.grouped = NO;
    authorityElm.title = @"授权访问";
    authorityElm.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    authorityElm.controllerName = @"ShareCamController"; //表单在 这个控制器里 ，，addFrieds vc
    
    
    QSection *section0 = [[QSection alloc] initWithTitle:@"authorized"];
    UIImageView *noDataHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, AM_SCREEN_WIDTH, AM_SCREEN_HEIGHT - 64)];
    [noDataHeader setImage:[UIImage imageNamed:@"authority"]];
    [noDataHeader setContentMode:UIViewContentModeScaleAspectFill];
    section0.headerView = noDataHeader;
 
    
    [authorityElm addSection:section0];
    NSInteger authrizedNum = [[[NSUserDefaults standardUserDefaults] valueForKey:@"friends"] count];
    authorityElm.value = [NSString stringWithFormat:@"(%zd)",authrizedNum];
    return authorityElm;
}




- (QElement *)changeNvrNameElm:(Device *)device {
    
    NSString *s = device.nvr_name ? device.nvr_name : device.nvr_id;

    
    
    QRootElement *changeNameElm = [[QRootElement alloc] init];
    [changeNameElm setGrouped:YES];
    [changeNameElm setTitle:@"修改中继名称"];
    [changeNameElm setKey:@"changeNvrName"];
    [changeNameElm setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    
    //嵌套section
    QSection *section0 = [[QSection alloc] initWithTitle:@"Modify_NvrName"];
    QEntryElement *entryElm = [[QEntryElement alloc] initWithTitle:@"修改" Value:device.nvr_name Placeholder:@"修改中继名称"];
    [entryElm setKey:@"rename"];
//    entryElm.delegate = self; //0x0000000131d76e10  指针 2个字节 ,此时设置代理 ，view 还没有出现！不会被调用代理方法
    [entryElm setTf_endEditing:^(UITextField *tf) {
        
        if (tf.text == s) {
            return ;
        }
//        [nvrCell.footer.deviceLb setText:tf.text];
        [RLM transactionWithBlock:^{
            device.nvr_name = tf.text;
        }];
    }];
   
    
    
    
    [section0 addElement:entryElm];
    [changeNameElm addSection:section0];
    return changeNameElm;
}

//info
- (QElement *)infoElm:(Device *)device {
    
    QRootElement *infoElm = [[QRootElement alloc] init];
    infoElm.grouped = YES;
    infoElm.title = @"设备信息";
    
    
    QSection *section_0 = [[QSection alloc] initWithTitle:@"Device"];
    
    char version[64];
    cloud_device_get_version((void *)device.nvr_h, version);
    QLabelElement *versionInfo = [[QLabelElement alloc] initWithTitle:@"device_version" Value:[NSString stringWithUTF8String:version]];
    QLabelElement *deviceNum = [[QLabelElement alloc] initWithTitle:@"ID" Value:device.nvr_id];
    section_0.elements = [NSMutableArray arrayWithArray:@[versionInfo,deviceNum]];
    
    
    [infoElm addSection:section_0];
    return infoElm;
    
    
}




#pragma mark - 创建 个人中心 settings 界面
- (QRootElement *)createForUserSettings:(User *)userModel {
    
    
    QRootElement *userRoot = [[QRootElement alloc] init];
    userRoot.grouped = YES;
    userRoot.controllerName = @"PersonalController";
    userRoot.title = @"个人中心";
//    [userRoot setObject:userModel];
    

    QSection *section0 = [[QSection alloc] init];
    section0.elements = [NSMutableArray arrayWithArray:@[[self userNameElm:userModel],[self qNaElm:userModel],[self helpElm:userModel],[self wipeCacheElm:userModel],[self aboutElm:userModel]]];

    
    
    
    [userRoot addSection:section0];
    [self setAppearance:userRoot];
    return userRoot;
    
    
    
}

- (QElement *)userNameElm:(User *)user {
    return [[QTextElement alloc] initWithText:@"Profile"];
}
- (QElement *)helpElm:(User *)person {
    QRootElement *helpElm = [[QRootElement alloc] init];
    helpElm.grouped = NO;
    helpElm.presentationMode = QPresentationModeModalForm;

    helpElm.title = @"help";
    
    QSection *section_0 = [[QSection alloc] initWithTitle:@""];
    QTextElement *text = [[QTextElement alloc] initWithText:@"该图显示的是一副图像输出的情况下，各控制信号和数据信号的输出。图中，VGA=640X480 大小情况下，帧同步信号，行同步信号（HREF 或者 HSYNC,注：HSYNC 在其它场合下使用，CMOS 可以设置，更多时候用HREF 即可）如图："];
    [section_0 addElement:text];
    
    [helpElm addSection:section_0];

    return helpElm;
}
- (QElement *)wipeCacheElm:(User *)user {
    return [[QTextElement alloc] initWithText:@"wipeCache"];
}
- (QElement *)qNaElm:(User *)user {
    return [[QTextElement alloc] initWithText:@"Q&A"];
}
- (QElement *)aboutElm:(User *)user {
    return [[QTextElement alloc] initWithText:@"about"];
}


























//自定义UI
+ (QAppearance *)customAppearance {
    
    QAppearance *appearance = [QElement appearance];//QFlatAppearance ,get  default appearece!
    appearance.labelFont = [UIFont boldSystemFontOfSize:17.f];
    appearance.valueFont = [UIFont systemFontOfSize:17.f];
    appearance.valueColorEnabled = [UIColor lightGrayColor];
    appearance.labelColorEnabled = [UIColor redColor];
    
    appearance.sectionTitleFont = [UIFont systemFontOfSize:17.f];
    appearance.entryFont = [UIFont systemFontOfSize:17.f];
    
    return appearance;
    
}


//instance method
- (void)setAppearance:(QRootElement *)rootElement {
    
    QAppearance *appearance = [rootElement appearance];//QFlatAppearance ,get  default appearece!
    appearance.labelFont = [UIFont boldSystemFontOfSize:17.f];
    appearance.valueFont = [UIFont systemFontOfSize:17.f];
    appearance.valueColorEnabled = [UIColor lightGrayColor];
    appearance.labelColorEnabled = [UIColor blackColor];
    
    appearance.sectionTitleFont = [UIFont systemFontOfSize:17.f];
    appearance.entryFont = [UIFont systemFontOfSize:17.f];
}
@end
