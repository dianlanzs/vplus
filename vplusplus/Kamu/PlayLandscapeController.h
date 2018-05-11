//
//  PlayLandscapeController.h
//  iLnkView
//



#import "Device.h"
#import <UIKit/UIKit.h>



@interface PlayLandscapeController : UIViewController


@property (nonatomic,strong) Device *dataModel;

/**
 *  用来判断是否需要设置声音传输过去
 */
@property (nonatomic) BOOL isMotion;


@property (nonatomic, copy) NSString *retunViewId;


@end
