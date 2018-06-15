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



static NSString  *rootControllerName = @"NvrSettingsController";

@implementation DataBuilder


#pragma mark - 创建 CAM settings 界面
- (QRootElement *)createForCamSettings:(Cam *)cam device:(Device *)device {
    
    QRootElement *camRoot = [[QRootElement alloc] init];
    [camRoot setGrouped:YES];
    camRoot.title =  @"设置CAM";
    
    [camRoot setObject:[NSDictionary dictionaryWithObjectsAndKeys:cam,@"camModel",device,@"deviceModel" ,nil]];
    
    QSection *section0 = [[QSection alloc] initWithTitle:@"CAM_Header"];
    section0.elements = [NSMutableArray arrayWithArray:@[[self changeCamNameElm:cam],[self camSwitchElm],[self remainingBatteryElm],[self videoSettingsElm],[self audioSettingsElm],[self camInfoElm]]];
    
    [camRoot addSection:section0];
    [self  setAppearance];
    return camRoot;
    
}

- (QRootElement *)camSwitchElm {
    QBooleanElement *camSwitch = [[QBooleanElement alloc] initWithTitle:@"摄像头打开/关闭" BoolValue:YES];
    camSwitch.controllerAction = @"camSwitch:";
    return camSwitch;
}

- (QRootElement *)remainingBatteryElm {
    QLabelElement *remainingBattery = [[QLabelElement alloc] initWithTitle:@"电池" Value:@""]; //使用iconFont
    return remainingBattery;
}

- (QElement *)changeCamNameElm:(Cam *)cam {
    
    //prepare data
    NSString *s = cam.cam_name ? cam.cam_name :cam.cam_id;
//    NSIndexPath *path = [nvrCell.QRcv indexPathForCell:videoCell];
    
    
    
    QRootElement *camNameElm = [[QRootElement alloc] init];
    camNameElm.grouped = YES;
    camNameElm.title = @"修改Cam名称";
    [camNameElm setKey:@"changeCamName"];
    camNameElm.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    

    QSection *section0 = [[QSection alloc] initWithTitle:@"Modify_CamName"];
  
    QEntryElement *entryElm = [[QEntryElement alloc] initWithTitle:@"修改" Value:s Placeholder:@"this is holder"];
    [entryElm setKey:@"rename"];
    [entryElm setTf_endEditing:^(UITextField *tf) {
        if (tf.text == s ) {
            return ;
        }
        
//        [cam.cam_name setText:tf.text];
//        cam.cam_name = tf.text;
        [RLM transactionWithBlock:^{
            [cam setCam_name:tf.text];
//            [cam setCam_name:tf.text];  // Cam* Unmanaged!
        }];
    }];
    
    [section0 addElement:entryElm];
    [camNameElm addSection:section0];
    return camNameElm;
}


- (QElement *)videoSettingsElm {
    
    QRootElement *videoRoot = [[QRootElement alloc] init];
    videoRoot.grouped = YES;
    videoRoot.title = @"视频设置";
    videoRoot.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    QSection *section1 = [[QSection alloc] initWithTitle:@"VideoSet"];
    QLabelElement *versionInfo = [[QLabelElement alloc] initWithTitle:@"序列号" Value:@"0302040204"];
    QLabelElement *deviceNum = [[QLabelElement alloc] initWithTitle:@"设备标识" Value:@"attached"];
    
    [section1 addElement:versionInfo];
    [section1 addElement:deviceNum];
    
    [videoRoot addSection:section1];
    
    return videoRoot;
}
- (QElement *)audioSettingsElm {
    
    QRootElement *audioRoot = [[QRootElement alloc] init];
    audioRoot.grouped = YES;
    audioRoot.title = @"音频设置";
    audioRoot.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    QSection *section1 = [[QSection alloc] initWithTitle:@"VideoSet"];
    QLabelElement *versionInfo = [[QLabelElement alloc] initWithTitle:@"序列号" Value:@"0302040204"];
    QLabelElement *deviceNum = [[QLabelElement alloc] initWithTitle:@"设备标识" Value:@"attached"];
    
    [section1 addElement:versionInfo];
    [section1 addElement:deviceNum];
    
    [audioRoot addSection:section1];
    return audioRoot;
}
- (QElement *)camInfoElm {
    QRootElement *deviceInfoRoot = [[QRootElement alloc] init];
    deviceInfoRoot.grouped = YES;
    deviceInfoRoot.title = @"音频设置";
    deviceInfoRoot.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    QSection *section1 = [[QSection alloc] initWithTitle:@"VideoSet"];
    QLabelElement *versionInfo = [[QLabelElement alloc] initWithTitle:@"序列号" Value:@"0302040204"];
    QLabelElement *deviceNum = [[QLabelElement alloc] initWithTitle:@"设备标识" Value:@"attached"];
    
    [section1 addElement:versionInfo];
    [section1 addElement:deviceNum];
    
    [deviceInfoRoot addSection:section1];
    return deviceInfoRoot;
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
    [self setAppearance];

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
    authorityElm.value = [NSString stringWithFormat:@"(%ld)",authrizedNum];
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
    infoElm.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    
    QSection *section_0 = [[QSection alloc] initWithTitle:@"Device"];
    QLabelElement *versionInfo = [[QLabelElement alloc] initWithTitle:@"序列号" Value:@"0.12"];
    QLabelElement *deviceNum = [[QLabelElement alloc] initWithTitle:@"设备标识" Value:device.nvr_id];
    section_0.elements = [NSMutableArray arrayWithArray:@[versionInfo,deviceNum]];
    
    
    [infoElm addSection:section_0];
    return infoElm;
    
    
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
- (void)setAppearance {
    
    QAppearance *appearance = [QElement appearance];//QFlatAppearance ,get  default appearece!
    appearance.labelFont = [UIFont boldSystemFontOfSize:17.f];
    appearance.valueFont = [UIFont systemFontOfSize:17.f];
    appearance.valueColorEnabled = [UIColor lightGrayColor];
    appearance.labelColorEnabled = [UIColor redColor];
    
    appearance.sectionTitleFont = [UIFont systemFontOfSize:17.f];
    appearance.entryFont = [UIFont systemFontOfSize:17.f];
}
@end
