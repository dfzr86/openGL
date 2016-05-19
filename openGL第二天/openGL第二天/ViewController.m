//
//  ViewController.m
//  openGL第二天
//
//  Created by __zimu on 16/5/19.
//  Copyright © 2016年 ablecloud. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;

@property (nonatomic, assign) int count;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic , assign) float mDegreeX;
@property (nonatomic , assign) float mDegreeY;
@property (nonatomic , assign) float mDegreeZ;

@property (nonatomic , assign) BOOL mBoolX;
@property (nonatomic , assign) BOOL mBoolY;
@property (nonatomic , assign) BOOL mBoolZ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.context];
    glEnable(GL_DEPTH_TEST);
    
    [self drawPic];
}

- (void)drawPic {
    
    //顶点数据，前三个是顶点坐标， 中间三个是顶点颜色，    最后两个是纹理坐标
    //正八面体
    GLfloat picArr[] = {
        0.5f, 0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 1.0f, //右上
        -0.5f, 0.5f, 0.0f,  0.0f, 0.0f, 1.0f,   0.0f, 1.0f, //左上
        -0.5f, -0.5f, 0.0f, 0.0f, 0.0f, 1.0f,   0.0f, 1.0f, //左下
        0.5f, -0.5f, 0.0f,  0.0f, 0.0f, 1.0f,   0.0f, 1.0f, //右下
        0.0f, 0.0f, 0.7f,   0.0f, 1.0f, 0.0f,   0.0f, 1.0f, //顶点
        0.0f, 0.0f, -0.7f,   1.0f, 0.0f, 0.0f,  0.0f, 1.0f, //对顶点
    };
//    //正方体
//    GLfloat square[] = {
//        0.5f, 0.5f, -0.5f,  1.0f, 0.0f, 0.0f,   0.0f, 1.0f, //右上里
//        0.5f, 0.5f, 0.5f,   0.0f, 1.0f, 0.0f,   0.0f, 1.0f, //右上外
//        -0.5f, 0.5f, -0.5f, 0.0f, 0.0f, 1.0f,   0.0f, 1.0f, //左上里
//        -0.5f, 0.5f, 0.5f,  0.5f, 0.5f, 0.5f,   0.0f, 1.0f, //左上外
//        0.5f, -0.5f, -0.5f, 0.0f, 0.0f, 1.0f,   0.0f, 1.0f, //右下里
//        0.5f, -0.5f, 0.5f,  0.0f, 0.0f, 1.0f,   0.0f, 1.0f, //右下外
//        -0.5f, -0.5f, -0.5f,0.0f, 1.0f, 1.0f,   0.0f, 1.0f, //左下里
//        -0.5f, -0.5f, 0.5f, 0.3f, 0.0f, 1.0f,   0.0f, 1.0f, //左下外
//    };
    
//    GLuint indexxx[] = {
//        5, 6, 4,
//        5, 6, 7,
//        3, 5, 1,
//        3, 5, 7,
//        0, 3, 2,
//        0, 3, 4,
//        2, 4, 6,
//        2, 4, 0,
//        0, 5, 1,
//        0, 5, 4,
//        2, 7, 3,
//        2, 7, 6,
//    };
    
    
    
    
    //顶点索引 -> 每三个顶点构成一个三角形, 作为图形的基本图元
    //正八面体
    GLuint index[] = {
        0, 1, 3,
        2, 1, 3,
        2, 3, 4,
        3, 4, 0,
        0, 1, 4,
        1, 4, 2,
        0, 1, 3,
        2, 1, 3,
        2, 3, 5,
        3, 5, 0,
        0, 1, 5,
        1, 5, 2,
        
    };

    self.count = sizeof(index) / sizeof(GLuint);
    
    
    //设置图形缓冲区
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(picArr), picArr, GL_STATIC_DRAW);
    
    //设置索引缓冲区
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(index), index, GL_STATIC_DRAW);
    
    //把数据加入到缓冲区
    //1. 位置
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);
    //2. 颜色
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 3);
    //3. 纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4 * 8, (GLfloat *)NULL + 6);
    
    //设置纹理图片
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"han.jpg" ofType:nil];
    //统一坐标系
    NSDictionary *options = @{ GLKTextureLoaderOriginBottomLeft : @YES };
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textureInfo.name;
    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    //透视投影
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.effect.transform.modelviewMatrix = modelviewMatrix;
    
    //定时器
    double delayInSecond = 0.1;
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, delayInSecond * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(self.timer, ^{
        self.mDegreeX += 0.1 * self.mBoolX;
        self.mDegreeY += 0.1 * self.mBoolY;
        self.mDegreeZ += 0.1 * self.mBoolZ;
    });
    
    dispatch_resume(self.timer);
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.mBoolX = !_mBoolX;
    self.mBoolY = !_mBoolY;
    self.mBoolZ = !_mBoolZ;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
    
}

- (void)update {

    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.mDegreeX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.mDegreeY);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.mDegreeZ);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    
    
}
@end
