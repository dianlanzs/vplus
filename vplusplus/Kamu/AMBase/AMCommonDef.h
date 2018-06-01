//
//  AMCommonDef.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//


#pragma mark -
#pragma mark define

#ifdef __OBJC__
#define SAFE_RELEASE(p) [p release]; p = nil;
#define SAFE_AUTORELEASE(p) [p autorelease]; p = nil;
#elif defined(__cplusplus)
#define SAFE_RELEASE(p) if (p) {p->release(); p = NULL;}
#endif

#ifdef DEBUG
#define NSLog(format, ...) NSLog(format, ##__VA_ARGS__)
#else
#define NSLog(format, ...)
#endif

#ifndef LS
#define LS(string) NSLocalizedString(string, nil)
#endif

#ifndef NIB
#define NIB(Class) NSStringFromClass([Class class])
#endif

#ifndef NIBID
#define NIBID(Class) [NSString stringWithFormat:@"%@ID", NSStringFromClass([Class class])]
#endif



#ifndef HexValue
#define HexValue(str) strtoul([str UTF8String], 0, 16)
#endif


// ==================== 颜色 ========================
#ifndef HexColor
#define HexColor(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]
#endif

#ifndef COLOR
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#endif

// 随机颜色
#define UICOLOR_RANDOM  [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1.0]





#ifndef DISTANCE
#define DISTANCE(start, end) [end distanceFromLocation:start]
#endif

#ifndef AMBundleID
#define AMBundleID [[NSBundle mainBundle] bundleIdentifier]
#endif


//屏幕宽度
#ifndef AM_SCREEN_WIDTH
#define AM_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#endif

//屏幕高度
#ifndef AM_SCREEN_HEIGHT
#define AM_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#endif

#ifndef IOS_VERSION
#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
#endif

#ifndef DEVICE_RATIO
#define DEVICE_RATIO    ([[UIScreen mainScreen] bounds].size.width / 320.0)
#endif

#ifndef DEVICE_IS_IPHONE
#define DEVICE_IS_IPHONE    ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#endif

#ifndef DEVICE_IS_IPAD
#define DEVICE_IS_IPAD      ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#endif

#ifndef DEVICE_IS_IPOD
#define DEVICE_IS_IPOD    ([[[UIDevice currentDevice] model] rangeOfString:@"iPod"].location != NSNotFound)
#endif

#ifndef DEVICE_IS_IPHONE4
#define DEVICE_IS_IPHONE4   ([[UIScreen mainScreen] bounds].size.height == 480.0)
#endif

#ifndef DEVICE_IS_IPHONE5
#define DEVICE_IS_IPHONE5   ([[UIScreen mainScreen] bounds].size.height == 568.0)
#endif

#ifndef DEVICE_IS_IPHONE6
#define DEVICE_IS_IPHONE6   ([[UIScreen mainScreen] bounds].size.width == 375.0)
#endif

#ifndef DEVICE_IS_IPHONE6_PLUS
#define DEVICE_IS_IPHONE6_PLUS   ([[UIScreen mainScreen] bounds].size.width == 414.0)
#endif

#ifndef NIBCT
#define NIBCT(string) (DEVICE_IS_IPHONE ? string : [NSString stringWithFormat:@"%@_iPad", string])
#endif



// =============================== Disk Cache ===============================
#ifndef APP_HOME_PATH
#define APP_HOME_PATH   NSHomeDirectory()
#endif



#ifndef APP_DOCUMENTS_PATH
#define APP_DOCUMENTS_PATH  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#endif

#ifndef APP_LIBRARY_PATH
#define APP_LIBRARY_PATH    [NSHomeDirectory() stringByAppendingPathComponent:@"Library"]
#endif

#ifndef APP_TMP_PATH
#define APP_TMP_PATH    [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
#endif

#ifndef APP_CACHE_PATH
#define APP_CACHE_PATH  [NSHomeDirectory() stringByAppendingPathComponent:@"cache"]
#endif

#ifndef AMCheckPhone
#define AMCheckPhone(string) ([string isMatchedByRegex:@""])
#endif




//默认数据库路径
#define RLM [RLMRealm defaultRealm]
//查询 Read
#define RLM_R_CAM(cam_id) [[Cam objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",cam_id]] firstObject];
#define RLM_R_NVR(nvr_id) [[Device objectsWhere:[NSString stringWithFormat:@"nvr_id = '%@'",nvr_id]] firstObject];
#define RLM_R_NVR_STATUS(nvr_status) [Device objectsWhere:[NSString stringWithFormat:@"nvr_status = %d",nvr_status]] ;


//#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
//#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
//#define WO(strongObj)__weak typeof(strongObj) strongObj##weakObj = weakObj;
#define WeakObj(strongObj) __weak typeof(strongObj) weakObj = strongObj;




// 颜色值RGB
#define RGBA(r,g,b,a)                       [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
// 图片路径
#define ZLPlayerSrcName(file)               [@"ZLPlayer.bundle" stringByAppendingPathComponent:file]
#define ZLPlayerFrameworkSrcName(file)      [@"Frameworks/ZLPlayer.framework/ZLPlayer.bundle" stringByAppendingPathComponent:file]
#define ZLPlayerImage(file)                 [UIImage imageNamed:ZLPlayerSrcName(file)] ? :[UIImage imageNamed:ZLPlayerFrameworkSrcName(file)]
#define ZLPlayerOrientationIsLandscape      UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)
#define ZLPlayerOrientationIsPortrait       UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)
#pragma mark -常量

static CGFloat const kTabBarHeight = 49.0;
static CGFloat const AM_BAR_HEIGHT = 50;
static CGFloat const kNavigationbarHeight = 44;
static CGFloat const kTopbarHeight = 64;

static CGFloat const kBottomBtnHeight = 300;
static CGFloat const kBtnH = 40; 
static CGFloat const kTextFieldH = 40;

