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
    camRoot.title =  LS(@"摄像头设置");
    
    [camRoot setObject:[NSDictionary dictionaryWithObjectsAndKeys:cam,@"camModel",nil]];
    
    QSection *section0 = [[QSection alloc] initWithTitle:@"Header Title"];
    section0.elements = [NSMutableArray arrayWithArray:@[[self changeCamNameElm:cam],[self camSwitchElm],[self batteryWarningElm:cam],[self imageTransformElm:cam],[self motionDetectElm:cam],[self videoQulityElm:cam],[self camInfoElm:cam]]];
    
    [camRoot addSection:section0];
    [self  setAppearance:camRoot];
    return camRoot;
    
}

- (QBooleanElement *)camSwitchElm {
    QBooleanElement *camSwitch = [[QBooleanElement alloc] initWithTitle:LS(@"摄像头开关") BoolValue:YES];
    camSwitch.controllerAction = @"camSwitch:";
    return camSwitch;
}

- (QFloatElement *)batteryWarningElm:(Cam *)cam {
    QFloatElement *batteryWarningElm = [[QFloatElement alloc] initWithTitle:LS(@"电量剩余报警") value:cam.cam_battery_threshold];
    [batteryWarningElm setEnabled:NO];
    [batteryWarningElm setKey:@"cam_battery_threshold"];
//    batteryAlert.onValueChanged = ^(NSNumber *value) {
//        batteryAlert set
//    };
    [batteryWarningElm setHeight:80];
    return batteryWarningElm;
}




- (QBooleanElement *)imageTransformElm:(Cam *)cam {
    QBooleanElement *imageTransformElm = [[QBooleanElement alloc] initWithTitle:LS(@"图像旋转") BoolValue:YES];
    [imageTransformElm setEnabled:NO];
    [imageTransformElm setKey:@"cam_rotate"];
    return imageTransformElm;
}

- (QFloatElement *)motionDetectElm:(Cam *)cam {
    QFloatElement *motionDetectElm = [[QFloatElement alloc] initWithTitle:LS(@"移动侦测灵敏度") value:cam.cam_pir_sensitivity];
    [motionDetectElm setEnabled:NO];
    
    [motionDetectElm setKey:@"cam_pir_sensitivity"];//NSStringFromClass([QFloatElement class])
    [motionDetectElm setHeight:80];
    return motionDetectElm;
}
- (QRootElement *)videoQulityElm:(Cam *)cam {
//    QRadioElement *radioElm = [[QRadioElement alloc] initWithItems:@[@"普通",@"标准",@"高清"] selected:0 title:@"视频清晰度"];
    QRootElement *vqRoot = [[QRootElement alloc] init];
    [vqRoot setValue:LS(cam.cam_videoQulity)];
    vqRoot.grouped = YES;
    vqRoot.title = LS(@"视频清晰度设置");
    [vqRoot setKey:@"vqRoot"];

    NSArray *items = [NSArray arrayWithObjects:LS(@"标准"), LS(@"普通"), LS(@"高清"), nil];
     QRadioSection *section0 = [[QRadioSection alloc] initWithItems:items selected:0 title:@"选择视频清晰度"];
    [vqRoot addSection:section0];
    
    
    __weak QRadioSection *_weak_section0 = section0;
    section0.onSelected = ^{
        [vqRoot setValue:items[_weak_section0.selected]];
        [RLM transactionWithBlock:^{
            [cam setCam_videoQulity:items[_weak_section0.selected]];
        }];
    };
    return vqRoot;
}

- (QElement *)camInfoElm:(Cam *)cam {
    QRootElement *camInfoRoot = [[QRootElement alloc] init];
    camInfoRoot.grouped = YES;
    camInfoRoot.title = LS(@"摄像头信息");
    
    QSection *infoSection = [[QSection alloc] initWithTitle:@"CAM_INFO"];
    QLabelElement *cid = [[QLabelElement alloc] initWithTitle:@"ID" Value:[cam.cam_id uppercaseString]];
    QLabelElement *version = [[QLabelElement alloc] initWithTitle:LS(@"版本") Value:[cam.cam_version uppercaseString]];

    [infoSection addElement:cid];
    [infoSection addElement:version];

    [camInfoRoot addSection:infoSection];
    return camInfoRoot;
}

- (QElement *)changeCamNameElm:(Cam *)cam {
    
    NSString *tf_text = cam.cam_name ? cam.cam_name :cam.cam_id;
    
    QRootElement *camNameElm = [[QRootElement alloc] init];
    camNameElm.grouped = YES;
    camNameElm.title = LS(@"摄像头名称");
    [camNameElm setKey:@"changeCamName"];
    camNameElm.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    QSection *section0 = [[QSection alloc] initWithTitle:@"CHANGE_CAM_NAME"];
    QEntryElement *entryElm = [[QEntryElement alloc] initWithTitle:LS(@"重命名") Value:tf_text Placeholder:LS(@"占位文字")];
    [entryElm setKey:@"cam_rename"];
    [section0 addElement:entryElm];
    
    
    
    [entryElm setTf_endEditing:^(UITextField *tf) {
        if (tf.text != tf_text ) {
            ///trigger RLM notification
            [RLM transactionWithBlock:^{
                [cam setCam_name:tf.text];
            }];
        }
        
    }];
    [camNameElm addSection:section0];
    return camNameElm;
}
#pragma mark - 创建 NVR settings 界面

- (QRootElement *)createForNvrSettings:(Device *)device {
    
    QRootElement *nvrRoot = [[QRootElement alloc] init];
    nvrRoot.grouped = YES;
    nvrRoot.title = LS(@"设备设置");
    QSection *section0 = [[QSection alloc] initWithTitle:@""]; ///section must have title  和背景色 有关系 ,  没有 tableview 的背景色 是白色
    
    section0.elements = [NSMutableArray arrayWithArray:@[[self changeNvrNameElm:device],[self recordElm],[self authorityElm],[self infoElm:device]]];
    [nvrRoot setPreselectedElementIndex:[NSIndexPath indexPathForRow:1 inSection:0]];
    [nvrRoot addSection:section0];
    [self setAppearance:nvrRoot];
    return nvrRoot;
}

- (QElement *)recordElm {
    QBooleanElement *recordElm = [[QBooleanElement alloc] initWithTitle:LS(@"本地存储") BoolValue:YES];
    recordElm.controllerAction = @"exampleAction:";
    recordElm.key = @"bool1";
    return recordElm;
}
//authority
- (QElement *)authorityElm {
    
    QRootElement *authorityElm = [[QRootElement alloc] init];
    authorityElm.grouped = NO;
    authorityElm.title = LS(@"授权访问");
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
    NSString *tf_text = device.nvr_name ? device.nvr_name : device.nvr_id;
    
    QRootElement *changeNameElm = [[QRootElement alloc] init];
    [changeNameElm setGrouped:YES];
    [changeNameElm setTitle:LS(@"设备名称")];
    [changeNameElm setKey:@"changeNvrName"];
    [changeNameElm setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    QSection *section0 = [[QSection alloc] initWithTitle:@"Modify_NvrName"];
    QEntryElement *entryElm = [[QEntryElement alloc] initWithTitle:LS(@"重命名") Value:tf_text Placeholder:LS(@"占位文字")];
    [entryElm setKey:@"rename"];
    [section0 addElement:entryElm];
    [entryElm setTf_endEditing:^(UITextField *tf) {
        if (tf.text != tf_text ) {
            [RLM transactionWithBlock:^{
                [device setNvr_name:tf.text];
            }];
        }
        
    }];
    [changeNameElm addSection:section0];
    return changeNameElm;
}

//info
- (QElement *)infoElm:(Device *)device {
    
    QRootElement *infoElm = [[QRootElement alloc] init];
    infoElm.grouped = YES;
    infoElm.title = LS(@"设备信息");
    
    
    QSection *section_0 = [[QSection alloc] initWithTitle:@"Device"];
    
    char version[64];
    cloud_device_get_version((void *)device.nvr_h, version);
    QLabelElement *versionInfo = [[QLabelElement alloc] initWithTitle:LS(@"版本") Value:[NSString stringWithUTF8String:version]];
    QLabelElement *deviceNum = [[QLabelElement alloc] initWithTitle:LS(@"标识" ) Value:device.nvr_id];
    section_0.elements = [NSMutableArray arrayWithArray:@[versionInfo,deviceNum]];
    
    
    [infoElm addSection:section_0];
    return infoElm;
    
    
}

#pragma mark - 创建 个人中心 settings 界面
- (QRootElement *)createForUserSettings:(User *)userModel {
    
    
    QRootElement *userRoot = [[QRootElement alloc] init];
    userRoot.grouped = YES;
    userRoot.controllerName = @"PersonalController";
    userRoot.title = LS(@"个人中心");
//    [userRoot setObject:userModel];
    

    QSection *section0 = [[QSection alloc] init];
    section0.elements = [NSMutableArray arrayWithArray:@[[self userNameElm:userModel],[self qNaElm:userModel],[self helpElm:userModel],[self wipeCacheElm:userModel],[self languageElm:nil],[self aboutElm:userModel]]];

    
    
    
    [userRoot addSection:section0];
    [self setAppearance:userRoot];
    return userRoot;
}

- (QElement *)userNameElm:(User *)user {
    QRootElement *profileElm = [[QRootElement alloc] init];
    profileElm.grouped = YES;
    profileElm.presentationMode = QPresentationModeModalForm;
    profileElm.title = LS(@"个人信息");
    
    QLabelElement *uidElm = [[QLabelElement alloc] initWithTitle:LS(@"用户ID") Value:user.user_id];

    QSection *section_0 = [[QSection alloc] initWithTitle:@"USER_FILE"];
    section_0.elements = [NSMutableArray arrayWithArray:@[uidElm ,[self devicesElm:user.user_devices]]];
    [profileElm addSection:section_0];
    return profileElm;
}
///devices root in profile
- (QRootElement *)devicesElm:(RLMArray *)devices {
    QRootElement *devicesElm = [[QRootElement alloc] init];
    devicesElm.grouped = YES;  ////YES  刚好 ，NO 会使得 section  变大 ， SECtion header 也变得很大！！！！
    devicesElm.presentationMode = QPresentationModeModalForm;
    devicesElm.title = LS(@"持有设备");
    QSection *section_devices_0 = [[QSection alloc] init];
    for (Device *ownedDevice in devices) {
        QLabelElement *ownedDeviceElm = [[QLabelElement alloc] initWithTitle:LS(@"设备ID") Value:ownedDevice.nvr_id];
        [section_devices_0 addElement:ownedDeviceElm];
    }
    [devicesElm addSection:section_devices_0];
    return devicesElm;
}

///语言设置
- (QRootElement *)languageElm:(RLMArray *)devices {
    QRootElement *languageRoot = [[QRootElement alloc] init];
  
   
    languageRoot.grouped = YES;  ////YES  刚好 ，NO 会使得 section  变大 ， SECtion header 也变得很大！！！！
    languageRoot.presentationMode = QPresentationModeModalForm;
    languageRoot.title = LS(@"语言设置");
    QSection *section_0 = [[QSection alloc] init];
    QLabelElement *zh_hansElm = [[QLabelElement alloc] initWithTitle:@"简体中文" Value:@"zh_Hans"];
    QLabelElement *enElm = [[QLabelElement alloc] initWithTitle:@"English" Value:@"en"];
    
    __weak typeof(QLabelElement *) wzh_hansElm = zh_hansElm;
    __weak typeof(QLabelElement *) wenElm = enElm;
    [zh_hansElm setOnSelected:^{
        if (zh_hansElm.accessoryType == UITableViewCellAccessoryCheckmark) {
            [wzh_hansElm setKeepSelected:NO];
            return ;
        }
        [NSBundle setCusLanguage:@"zh-Hans"];
    }];
    [enElm setOnSelected:^{
        if (enElm.accessoryType == UITableViewCellAccessoryCheckmark) {
            [wenElm setKeepSelected:NO];
            return ;
        }
        [NSBundle setCusLanguage:@"en"];
    }];
    
    NSString *nsLang= [[NSUserDefaults standardUserDefaults] valueForKey:AppLanguageKey]; //@"en"
//    NSString *nsLang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"]  objectAtIndex:0]; //、、@"en-CN" 、、@"zh-Hans-CN"
    if ([nsLang isEqualToString:@"en"]) {
        [languageRoot setValue:@"English"];
        [enElm setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else if ([nsLang isEqualToString:@"zh-Hans"]) {
        [languageRoot setValue:@"简体中文"];
        [zh_hansElm setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    

    section_0.elements = [NSMutableArray arrayWithArray:@[enElm,zh_hansElm]];
    [languageRoot addSection:section_0];
    return languageRoot;
}



- (QElement *)helpElm:(User *)person {
    QRootElement *helpElm = [[QRootElement alloc] init];
    helpElm.grouped = YES;
    helpElm.presentationMode = QPresentationModeModalForm;
    helpElm.title = LS(@"帮助");
    
    QSection *section_0 = [[QSection alloc] initWithTitle:@"user_help"]; ///显示大写
    QTextElement *textElm = [[QTextElement alloc] initWithText:@"somthing ....."];
    [section_0 addElement:textElm];
    
    [helpElm addSection:section_0];

    return helpElm;
}




- (QElement *)wipeCacheElm:(User *)user {
    QLabelElement *wipeCacheElm = [[QLabelElement alloc] initWithTitle:LS(@"清理缓存") Value:nil];
    return wipeCacheElm;
}
- (QElement *)qNaElm:(User *)user {
    QLabelElement *qNaElm = [[QLabelElement alloc] initWithTitle:LS(@"常见问题") Value:nil];
    return qNaElm;
}
- (QElement *)aboutElm:(User *)user {
    QLabelElement *aboutElm = [[QLabelElement alloc] initWithTitle:LS(@"关于") Value:nil];
    return aboutElm;
}


























//自定义UI
/*
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
*/

//instance method
- (void)setAppearance:(QRootElement *)rootElement {
    
    QAppearance *appearance = [rootElement appearance];//QFlatAppearance ,get  default appearece!
    appearance.labelFont = [UIFont boldSystemFontOfSize:17.f];
    appearance.valueFont = [UIFont systemFontOfSize:17.f];
    appearance.valueColorEnabled = [UIColor lightGrayColor];
    appearance.labelColorEnabled = [UIColor blackColor];
    appearance.tableGroupedBackgroundColor = [UIColor groupTableViewBackgroundColor];
    appearance.sectionTitleFont = [UIFont systemFontOfSize:17.f];
    appearance.entryFont = [UIFont systemFontOfSize:17.f];
    appearance.defaultHeightForHeader = @(0.f); ///section header == nil
    appearance.defaultHeightForFooter = @(0.f); ///section footer == nil
}
@end

