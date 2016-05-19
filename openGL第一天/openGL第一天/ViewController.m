//
//  ViewController.m
//  openGL第一天
//
//  Created by __zimu on 16/5/18.
//  Copyright © 2016年 ablecloud. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;

@property (nonatomic , assign) int mCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置当前使用的context使用的api版本
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //设置当前的context
    [EAGLContext setCurrentContext:self.context];
    
    //设置视图的渲染属性
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    //颜色渲染格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    //深度渲染格式
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    
    //初始化视觉管理对象
    self.effect = [[GLKBaseEffect alloc] init];
    //光照效果
    self.effect.light0.enabled = GL_TRUE;
    //设置光照颜色
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    //从左到右, 依次是  顶点X, Y, Z, 法线X, Y, Z, 纹理S, T
    //顶点位置用于确定在什么地方显示，法线用于光照模型计算，纹理则用在贴图中。
    GLfloat squareVertexData[48] = {
        0.5f, 0.5f, -0.9f,      0.0f, 0.0f, 1.0f,       1.0f, 1.0f,
        -0.5f, 0.5f, -0.9f,     0.0f, 0.0f, 1.0f,       0.0f, 1.0f,
        0.5f, -0.5f, -0.9f,     0.0f, 0.0f, 1.0f,       1.0f, 0.0f,
        0.5f, -0.5f, -0.9f,     0.0f, 0.0f, 1.0f,       1.0f, 0.0f,
        -0.5f, 0.5f, -0.9f,     0.0f, 0.0f, 1.0f,       0.0f, 1.0f,
        -0.5f, -0.5f, -0.9f,    0.0f, 0.0f, 1.0f,       0.0f, 0.0f,
    };
    
    
    //声明一个缓冲区的标识（GLuint类型）
    GLuint buffer;
    //让OpenGL自动分配一个缓冲区空间
    glGenBuffers(1, &buffer);
    //绑定这个缓冲区到当前“Context”
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //将我们前面预先定义的顶点数据“squareVertexData”复制进这个缓冲区中。
    //注：参数“GL_STATIC_DRAW”，它表示此缓冲区内容只能被修改一次，但可以无限次读取。
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    //将缓冲区的数据复制进通用顶点属性中
    /**
     GLKVertexAttribPosition,   位置属性
     GLKVertexAttribNormal,     法线属性
     GLKVertexAttribColor,      颜色属性
     GLKVertexAttribTexCoord0,  纹理0
     GLKVertexAttribTexCoord1   纹理1
     */
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    /**
     填充数据, 参数含义分别为:
     
     顶点属性索引（这里是位置/法线/纹理）、
     3个分量的矢量、
     类型是浮点（GL_FLOAT）、
     填充时不需要单位化（GL_FALSE）、
     在数据数组中每行的跨度是32个字节（4*8=32。从预定义的数组中可看出，每行有8个GL_FLOAT浮点值，而GL_FLOAT占4个字节，因此每一行的跨度是4*8）。
     最后一个参数是一个偏移量的指针，用来确定“第一个数据”将从内存数据块的什么地方开始。
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 4*8, (char *)NULL + 0);
    
    //法线
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 4*8, (char *)NULL + 12);
    
    //纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4*8, (char *)NULL + 24);
    //加载纹理内容
    //GLKit加载纹理，默认都是把坐标设置在“左上角”。然而，OpenGL的纹理贴图坐标却是在左下角，这样刚好颠倒。
    NSDictionary *options = @{ GLKTextureLoaderOriginBottomLeft : @YES };
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"222.jpg" ofType:nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textureInfo.name;
    
}

//渲染代码放在这里
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);


}
//场景变化放在这里
- (void)update {
    
    //修改投影矩阵
    //加下面的代码, 是因为如果不加, 默认的屏幕长宽比和openGL的长宽比不一致, 会导致有一个方向被拉伸
    CGSize size = self.view.bounds.size;
    //算出屏幕的纵横比
    float aspect = fabs(size.width / size.height);

    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -1.0f);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
}




















@end