//
//  GLDrawController.h
//  Kamu
//
//  Created by YGTech on 2017/12/12.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@interface GLDrawController : GLKViewController {
    
    int W;
    int H;
    
    //条件锁
    NSCondition *m_YUVDataLock;
    GLuint _testTxture[3];
    
}




@property (nonatomic, assign)BOOL m_bHasNewFrame;

- (void)writeY:(Byte *)pY U:(Byte *)pU V:(Byte *)pV width:(int)w height:(int)h;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;



@end
