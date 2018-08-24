//
//  RLMObject+ThreadReslove.h
//  Kamu
//
//  Created by YGTech on 2018/8/10.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import <Realm/Realm.h>

typedef void(^func)(RLMObject *reslovedObj);
@interface RLMObject (ThreadReslove)
- (void)asyncThreadReslove:(func)op;
@end
