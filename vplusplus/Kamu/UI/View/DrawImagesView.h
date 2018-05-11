//
//  DrawImagesView.h
//  ilnkDemo
//
//  Created by YGTech on 2018/1/15.
//  Copyright © 2018年 com.ilnkDemo.cme. All rights reserved.
//

#import <GLKit/GLKit.h>


@interface DrawImagesView : GLKView {
    
    GLuint testTexture[3];

}


@property (nonatomic, assign) int w;
@property (nonatomic, assign) int h;

@property (nonatomic, strong) NSCondition *m_yuvDataLock;
//@property (nonatomic, assign) GLuint testTexture[3];
@property (nonatomic, assign) BOOL hasNewFrame;





- (void)writeY:(Byte *)pY U:(Byte *)pU V:(Byte *)pV width:(int)w height:(int)h;

//- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

