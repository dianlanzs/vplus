//
//  GLDrawController.m
//  Kamu
//
//  Created by YGTech on 2017/12/12.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//




#import "GLDrawController.h"
#import "AppDelegate.h"

#import "ZLPlayerControlView.h"
#import "UIView+ZLCustomControlView.h"
#import "ZLPlayerView.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
// 1.Uniform index.
enum {
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};

GLint uniforms[NUM_UNIFORMS];

// 2.Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface GLDrawController () {
    
    GLuint _program;
    AppDelegate *app;
    
}

@property (strong, nonatomic) EAGLContext *context;



//
//@property (strong, nonatomic) ZLPlayerView *playerView;
//@property (nonatomic, strong) ZLPlayerModel *playerModel;
//
//@property (strong, nonatomic)  IBOutlet UIView *playerFatherView;
@end





@implementation GLDrawController

#pragma mark - 生命周期方法
- (void)viewDidLoad {
    
    
    [super viewDidLoad];
//    [self.view addSubview:self.playerFatherView];


    //关闭内部交互
    [self.view setUserInteractionEnabled:NO];
    //has 新frame == NO
    m_bHasNewFrame = false;
    
    //高度 宽度 = 0
    H = 0;
    W = 0;
    
    //单例 appDelegate
    app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    //m_pYUVData = new Byte[1920*1080 * 3 / 2];
    
    //设置上下文
    m_YUVDataLock = [[NSCondition alloc] init];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        
        NSLog(@"Failed to Create ES context");
    }
    
    
    
    
    //继承 UIViewController ,转换UIView == GLKView
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    //设置深度和颜色格式
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
    
    
    
    //初始化GL
    [self setupGL];
    
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    //DLog(@"vertShaderPathname: %@", vertShaderPathname);
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        
        //if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:@"ShaderTest.vsh"]) {
        NSLog(@"Failed to compile vertex shader");
        return ;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    //DLog(@"fragShaderPathname: %@", fragShaderPathname);
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        
        NSLog(@"Failed to compile fragment shader");
        return ;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Link program.
    if (![self linkProgram:_program]) {
        
        
        NSLog(@"Failed to link program: %d", _program);
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return ;
    }
    
    glEnable(GL_TEXTURE_2D);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(_program);
    glGenTextures(3, _testTxture);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _testTxture[0]);
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 640, 480, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, y);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_MAG_FILTER,  GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_MIN_FILTER,  GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_WRAP_S,      GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_WRAP_T,      GL_CLAMP_TO_EDGE);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _testTxture[1]);
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 320, 240, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, u);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_MAG_FILTER,  GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_MIN_FILTER,  GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_WRAP_S,      GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_WRAP_T,      GL_CLAMP_TO_EDGE);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, _testTxture[2]);
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 320, 240, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, v);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_MAG_FILTER,  GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_MIN_FILTER,  GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_WRAP_S,      GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,   GL_TEXTURE_WRAP_T,      GL_CLAMP_TO_EDGE);
    
    GLuint i;
    
    glActiveTexture(GL_TEXTURE1);
    i = glGetUniformLocation(_program,"Utex");//    glUniform1i(i,1);  /* Bind Utex to texture unit 1 */
    //DLog(@"i: %d", i);
    // glBindTexture(GL_TEXTURE_2D, _textureU);
    glUniform1i(i,1);
    
    /* Select texture unit 2 as the active unit and bind the V texture. */
    glActiveTexture(GL_TEXTURE2);
    i = glGetUniformLocation(_program,"Vtex");
    //DLog(@"i: %d", i);
    //glBindTexture(GL_TEXTURE_2D, _textureV);
    glUniform1i(i,2);  /* Bind Vtext to texture unit 2 */
    
    
    /* Select texture unit 0 as the active unit and bind the Y texture. */
    glActiveTexture(GL_TEXTURE0);
    i = glGetUniformLocation(_program,"Ytex");
    //DLog(@"i: %d", i);
    //glBindTexture(GL_TEXTURE_2D, _textureY);
    glUniform1i(i,0);  /* Bind Ytex to texture unit 0 */
    
    
    //设置背景色
    [self.view setBackgroundColor:[UIColor redColor]];
    
}



//收到内存警告时候 ，系统会调用该方法
- (void)viewDidUnload {
    // iOS6不推荐你将view置为nil的.只回收bitMap 类
    [super viewDidUnload];
    
    [self tearDownGL];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}


- (void)dealloc {
    
    [self tearDownGL];
}


#pragma mark - 绘制 YUV 数据
//- (void)writeY:(Byte *)pY U:(Byte *)pU V:(Byte *)pV width:(int)w height:(int)h {
//
//    [m_YUVDataLock lock];
//
//    W = w;
//    H = h;
//
//    //app.y_data = pY;
//    //app.u_data = pU;
//    //app.v_data = pV;
//    memcpy(app.y_data,pY,w*h);
//    memcpy(app.u_data,pU,w*h/4);
//    memcpy(app.v_data,pV,w*h/4);
//
//    m_bHasNewFrame = YES;
//    //解锁
//    [m_YUVDataLock unlock];
//
//
//}
- (void)writeY:(Byte *)pY U:(Byte *)pU V:(Byte *)pV width:(int)w height:(int)h {

    [m_YUVDataLock lock];

    W = w;
    H = h;

    app.y_data = pY;
    app.u_data = pU;
    app.v_data = pV;

    m_bHasNewFrame = YES;
    //解锁
    [m_YUVDataLock unlock];

}

#pragma mark - 自动旋转手机方向
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//
//    // Return YES for supported orientations
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//    } else {
//        return YES;
//    }
//}


#pragma mark - 核心方法
- (void)setupGL {
    
    [EAGLContext setCurrentContext:self.context];
}
- (void)tearDownGL {
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}


#pragma mark - GLKViewController 代理方法
- (void)update {
    
}

- (BOOL)drawYUV {
    //上锁
    [m_YUVDataLock lock];
    //是否有新Frame
    if (!m_bHasNewFrame) {
        [m_YUVDataLock unlock];        //解锁
        //Steve dbg
        //usleep(10000);
        return false;   
    }
    
    //    Byte *y = app.m_pYUVData;
    //    Byte *u = app.m_pYUVData + H * W;
    //    Byte *v = app.m_pYUVData + H * W * 5 / 4;
    Byte *y = app.y_data;
    Byte *u = app.u_data;
    Byte *v = app.v_data;
    
    glActiveTexture(GL_TEXTURE0);
    //glTexSubImage2D (GL_TEXTURE_2D, 0, 0, 0, m_nWidth, m_nHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, y);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, W, H, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, y);
    
    glActiveTexture(GL_TEXTURE1);
    //glTexSubImage2D (GL_TEXTURE_2D, 0, 0, 0, m_nWidth / 2, m_nHeight / 2, GL_LUMINANCE, GL_UNSIGNED_BYTE, u);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, W / 2, H / 2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, u);
    
    glActiveTexture(GL_TEXTURE2);
    //glTexSubImage2D (GL_TEXTURE_2D, 0, 0, 0, m_nWidth / 2, m_nHeight / 2, GL_LUMINANCE, GL_UNSIGNED_BYTE, v);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, W / 2, H / 2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, v);
    
    m_bHasNewFrame = false;
    [m_YUVDataLock unlock];
    
    return YES;
}



#pragma mark - GLKViewDelegate  代理回调方法
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//    NSLog(@"draw....");
    
    if ([self drawYUV] == NO) {
        return;
    }
   
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat varray[] = {
        
       -1.0f,   1.0f,  0.0f,
       -1.0f,  -1.0f,  0.0f,
        1.0f,  -1.0f,  0.0f,
        1.0f,   1.0f,  0.0f,
       -1.0f,   1.0f,  0.0f
        
    };
    
    GLfloat triangleTexCoords[] = {
        
        // X, Y, Z
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f
    };
    
    
    glEnable(GL_DEPTH_TEST);
    
    GLuint i;
    i = glGetAttribLocation(_program, "vPosition");
    glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), varray);
    
    glEnableVertexAttribArray(i);
    
    i = glGetAttribLocation(_program, "myTexCoord");
    //__android_log_print(ANDROID_LOG_INFO,"TAG","myTexCoord i: %d", i);
    glVertexAttribPointer(i, 2, GL_FLOAT, GL_FALSE,
                          2 * sizeof(float),
                          triangleTexCoords);
    
    glEnableVertexAttribArray(i);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 5);
}


#pragma mark -  OpenGL ES 2 shader compilation

//加载 Shaders!
- (BOOL)loadShaders {
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIB_NORMAL, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}


//编译 Shaders ,File ,类型
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}


//链接 program
- (BOOL)linkProgram:(GLuint)prog {
    
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog {
    
    GLint logLength, status;
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
