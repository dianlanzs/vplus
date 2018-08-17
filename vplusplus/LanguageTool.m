//
//  LanguageTool.m
//  Kamu
//
//  Created by YGTech on 2018/8/15.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "LanguageTool.h"
#import "AppDelegate.h"


//#define CNS  @"zh-Hans"
//#define EN  @"en"
#define CURRENT_LANGUAGE  @"langeuageset"





static LanguageTool *tool;

@interface LanguageTool()

@property(nonatomic,strong) NSBundle *bundle;


@end




@implementation LanguageTool






+ (instancetype)sharedInstance {
    @synchronized(self) { //同步线程
        if (!tool) {
            tool = [[LanguageTool alloc] init];
        }
        return tool;
    }
}

- (instancetype)init{
    self = [super init];
    if (self){
        NSString *appLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_LANGUAGE];
        if (!appLanguage) {
            [self setAppLanguage:@"zh-Hans"];//默认是中文
        } else {
            [self setAppLanguage:appLanguage];
        }
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:appLanguage ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
    }
    
    return self;
}








// 切换语言
//NSArray *lans = @[@"en"];
//[[NSUserDefaults standardUserDefaults] setObject:lans forKey:@"AppleLanguages"];

/**
 <#Description#>

 @param key 代码里的 字符
 @param table 本地化的文件名称
 @return 映射的 字符
 */
- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table {
    if (self.bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}

- (void)setNewAppLanguage:(NSString *)appLanguage {
    
    if (![_appLanguage isEqualToString:appLanguage] ) {
        _appLanguage = appLanguage;
        
        ///修改 字体包 路径
        NSString *path = [[NSBundle mainBundle] pathForResource:appLanguage ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
        
        ///存储
        [[NSUserDefaults standardUserDefaults]setObject:appLanguage forKey:CURRENT_LANGUAGE];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        ///refresh root vc
        [self resetRootViewController];

    }
    /*
    else if ([choosedLanguage isEqualToString:@"en"] || [choosedLanguage isEqualToString: @"zh-Hans"]) {
        ///查找字体包
        NSString *path = [[NSBundle mainBundle] pathForResource:choosedLanguage ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
    }
    */
  
    
}

-(void)resetRootViewController {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
/*
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *rootNav = [storyBoard instantiateViewControllerWithIdentifier:@"rootnav"];
    UINavigationController *personNav = [storyBoard instantiateViewControllerWithIdentifier:@"personnav"];
    UITabBarController *tabVC = (UITabBarController*)appDelegate.window.rootViewController;
    tabVC.viewControllers = @[rootNav,personNav];
*/
    UIViewController *root = appDelegate.window.rootViewController;
    
    
//    if (root) {
//        <#statements#>
//    }
    
    
//
    UIViewController *empty_root_vc = [UIViewController new];
////    root_vc =
//    [appDelegate.window setRootViewController:root_vc];
//    root_vc = root;
    [appDelegate setDrawerController:nil];
    [appDelegate.window setRootViewController:appDelegate.drawerController];

//    [appDelegate.window setRootViewController:empty_root_vc];
//    NSLog(@"3 WINDOW -------%@",appDelegate.window.rootViewController);
//
//    [appDelegate.window makeKeyAndVisible];
}





 
@end
