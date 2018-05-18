//
//  Device.m


#import "Device.h"


@implementation Device

+ (NSArray *)ignoredProperties {

    //@"deviceHandle"
    return @[@"nvr_pwd",
             @"alarmShowed",
             @"nvr_data",
             @"delegate"];
}

- (long)nvr_h {
    return (long)cloud_open_device([self.nvr_id UTF8String]);
}
- (void)setNvr_id:(NSString *)nvr_id {
    if (nvr_id != _nvr_id) {
        _nvr_id = nvr_id;
        _nvr_h  = (long)cloud_open_device([nvr_id UTF8String]);
        _nvr_type =  (int) cloud_get_device_type((void *)_nvr_h);
    }
}
@end

