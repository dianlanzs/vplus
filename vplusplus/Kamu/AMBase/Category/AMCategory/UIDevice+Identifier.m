//
//  UIDevice+Identifier.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "UIDevice+Identifier.h"

#include <net/if.h>
#include <sys/sysctl.h>
#include <net/if_dl.h>
#import "sys/utsname.h"
#import "NSString+Encode.h"

@implementation UIDevice (Identifier)

- (NSArray *)runningProcesses {
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    size_t size;
    int st = sysctl(mib, (u_int)miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc *process = NULL;
    struct kinfo_proc *newprocess = NULL;
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess) {
            if (process) {
                free(process);
            }
            return nil;
        }
        
        process = newprocess;
        sysctl(mib, (u_int)miblen, process, &size, NULL, 0);
        
    }
    while (st == -1 && errno == ENOMEM);
    
    if (st == 0) {
        if (size % sizeof(struct kinfo_proc) == 0) {
            int nprocess = (int)(size / sizeof(struct kinfo_proc));
            
            if (nprocess) {
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i = nprocess - 1; i >= 0; i--) {
                    NSString *processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString *processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:processID, @"ProcessID", processName, @"ProcessName", nil];
                    
                    [array addObject:dict];
                }
                
                return array;
            }
        }
    }
    free(process);
    return nil;
}

- (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *devicestr = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
	if ([devicestr isEqualToString:@"iPhone1,1"]) {
        return @"iPhone 1G";
    } else if ([devicestr isEqualToString:@"iPhone1,2"]) {
        return @"iPhone 3G";
    } else if ([devicestr isEqualToString:@"iPhone2,1"]) {
        return @"iPhone 3GS";
    } else if ([devicestr hasPrefix:@"iPhone3"]) {
        return @"iPhone 4";
    } else if ([devicestr isEqualToString:@"iPhone4,1"]) {
        return @"iPhone 4S";
    } else if ([devicestr isEqualToString:@"iPhone5,1"] || [devicestr isEqualToString:@"iPhone5,2"]) {
        return @"iPhone 5";
    } else if ([devicestr isEqualToString:@"iPhone5,3"] || [devicestr isEqualToString:@"iPhone5,4"]) {
        return @"iPhone 5C";
    } else if ([devicestr hasPrefix:@"iPhone6"]) {
        return @"iPhone 5S";
    } else if ([devicestr isEqualToString:@"iPhone7,1"]) {
        return @"iPhone 6 Plus";
    } else if ([devicestr isEqualToString:@"iPhone7,2"]) {
        return @"iPhone 6";
    } else if ([devicestr isEqualToString:@"iPhone8,1"]) {
        return @"iPhone 6S";
    } else if ([devicestr isEqualToString:@"iPhone8,2"]) {
        return @"iPhone 6S Plus";
    } else if ([devicestr isEqualToString:@"iPhone8,4"]) {
        return @"iPhone SE";
    } else if ([devicestr isEqualToString:@"iPhone9,1"]) {
        return @"iPhone 7";
    } else if ([devicestr isEqualToString:@"iPhone9,2"]) {
        return @"iPhone 7 Plus";
    }
	//iPod
	else if ([devicestr hasPrefix:@"iPod1,1"]) {
        return @"iPod Touch 1G";
    } else if ([devicestr hasPrefix:@"iPod2,1"]) {
        return @"iPod Touch 2G";
    } else if ([devicestr hasPrefix:@"iPod3,1"]) {
        return @"iPod Touch 3G";
    } else if ([devicestr hasPrefix:@"iPod4,1"]) {
        return @"iPod Touch 4G";
    } else if ([devicestr hasPrefix:@"iPod5,1"]) {
        return @"iPod Touch 5G";
    } else if ([devicestr hasPrefix:@"iPod7,1"]) {
        return @"iPod Touch 6G";
    }
	//iPad
	else if ([devicestr isEqualToString:@"iPad1,1"]) {
        return @"iPad 1";
    } else if ([devicestr isEqualToString:@"iPad1,2"]) {
        return @"iPad 1(3G)";
    } else if ([devicestr isEqualToString:@"iPad2,1"]) {
        return @"iPad 2(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad2,2"]) {
        return @"iPad 2(GSM)";
    } else if ([devicestr isEqualToString:@"iPad2,3"]) {
        return @"iPad 2(CDMA)";
    } else if ([devicestr isEqualToString:@"iPad2,4"]) {
        return @"iPad 2";
    } else if ([devicestr isEqualToString:@"iPad2,5"]) {
        return @"iPad Mini 1(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad2,6"]) {
        return @"iPad Mini 1";
    } else if ([devicestr isEqualToString:@"iPad2,7"]) {
        return @"iPad Mini 1(GSM+CDMA)";
    } else if ([devicestr isEqualToString:@"iPad3,1"]) {
        return @"iPad 3(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad3,2"]) {
        return @"iPad 3";
    } else if ([devicestr isEqualToString:@"iPad3,3"]) {
        return @"iPad 3(GSM+CDMA)";
    } else if ([devicestr isEqualToString:@"iPad3,4"]) {
        return @"iPad 4(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad3,5"]) {
        return @"iPad 4";
    } else if ([devicestr isEqualToString:@"iPad3,6"]) {
        return @"iPad 4(GSM+CDMA)";
    } else if ([devicestr isEqualToString:@"iPad4,1"]) {
        return @"iPad Air(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad4,2"]) {
        return @"iPad Air(Cellular)";
    } else if ([devicestr isEqualToString:@"iPad4,3"]) {
        return @"iPad Air";
    } else if ([devicestr isEqualToString:@"iPad4,4"]) {
        return @"iPad Mini 2(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad4,5"]) {
        return @"iPad Mini 2(Cellular)";
    } else if ([devicestr isEqualToString:@"iPad4,6"]) {
        return @"iPad Mini 2";
    } else if ([devicestr isEqualToString:@"iPad4,7"]) {
        return @"iPad Mini 3(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad4,8"]) {
        return @"iPad mini 3(Cellular)";
    } else if ([devicestr isEqualToString:@"iPad4,9"]) {
        return @"iPad mini 3";
    } else if ([devicestr isEqualToString:@"iPad5,1"]) {
        return @"iPad Mini 4(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad5,2"]) {
        return @"iPad Mini 4(LTE)";
    } else if ([devicestr isEqualToString:@"iPad5,3"]) {
        return @"iPad Air 2(WiFi)";
    } else if ([devicestr isEqualToString:@"iPad5,4"]) {
        return @"iPad Air 2(LTE)";
    } else if ([devicestr isEqualToString:@"iPad6,3"]) {
        return @"iPad Pro 9.7";
    } else if ([devicestr isEqualToString:@"iPad6,4"]) {
        return @"iPad Pro 9.7";
    } else if ([devicestr isEqualToString:@"iPad6,7"]) {
        return @"iPad Pro 12.9";
    } else if ([devicestr isEqualToString:@"iPad6,8"]) {
        return @"iPad Pro 12.9";
    }
	//iSimulator
	else if ([devicestr isEqualToString:@"i386"]) {
        return @"iSimulator 32";
    } else if ([devicestr isEqualToString:@"x86_64"]) {
        return @"iSimulator 64";
	}
    return devicestr;
}

@end
