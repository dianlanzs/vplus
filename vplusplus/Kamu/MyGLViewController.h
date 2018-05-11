//
//  ViewController.h
//  TestOpenGL
//


#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface MyGLViewController : GLKViewController{
    int W;
    int H;
    
//    Byte *m_pYUVData;
    NSCondition *m_YUVDataLock;
    
    GLuint _testTxture[3];
    
    BOOL m_bHasNewFrame;
}

- (void) WriteYUVFrame:(Byte*)pYUV Len:(int)length width:(int)width height:(int)height;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end
