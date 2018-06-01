//

#import "Cam.h"

typedef enum {
    
    ipc = 0,
    nvr = 1,
    
}nvr_type;

@class Device;
@protocol ZLNvrDelegate <NSObject>


@optional
- (void)device:(Device *_Nullable)nvr sendAvData:(void * _Nullable )data dataType:(int)type;
- (void)device:(Device *_Nullable)nvr sendListData:(void * _Nullable )data dataType:(int)type;

@end




RLM_ARRAY_TYPE(Cam)
/* 定义 RLMArray<Cam> 类型 ,RLM_ARRAY_TYPE 宏创建了一个协议，从而允许您使用 RLMArray<Cam> 这种语法。如果这条宏没有放置在模型接口定义的底部，那么这个模型类就必须前置声明。*/

@interface Device : RLMObject

@property (nonatomic, assign) long nvr_h;
@property (nonatomic, assign) void * _Nullable nvr_data;
@property  int nvr_dataType;


@property  NSString * _Nullable nvr_pwd;

@property (nonatomic, weak)  id<ZLNvrDelegate> _Nullable listDelegate;
@property (nonatomic, weak)  id<ZLNvrDelegate> _Nullable avDelegate;


@property  NSString * _Nullable nvr_name;
@property (nonatomic, copy) NSString * _Nonnull nvr_id;

@property  int nvr_type;

@property  int nvr_status;
@property  int alarmShowed;

@property RLMArray<Cam> * _Nullable nvr_cams;
/*RLMArray 属性会确保其内部的插入次序不会被打乱。
注意，目前暂时不支持对包含原始类型的 RLMArray 进行查询。 */

@end

//这个宏表示支持RLMArray<Cam>该属性、、        @throw RLMException(@"Property '%@' requires a protocol defining the contained type - example: RLMArray<Person>.", _name);





