#import <simd/simd.h>
#import "AppDelegate.h"

static const float quadVertexData[] =
{
     0.5, -0.5, 0.0, 1.0,     1.0, 0.0, 0.0, 1.0,
    -0.5, -0.5, 0.0, 1.0,     0.0, 1.0, 0.0, 1.0,
    -0.5,  0.5, 0.0, 1.0,     0.0, 0.0, 1.0, 1.0,

     0.5,  0.5, 0.0, 1.0,     1.0, 1.0, 0.0, 1.0,
     0.5, -0.5, 0.0, 1.0,     1.0, 0.0, 0.0, 1.0,
    -0.5,  0.5, 0.0, 1.0,     0.0, 0.0, 1.0, 1.0,
};

typedef struct {
    matrix_float4x4 rotation_matrix;
} Uniforms;

static matrix_float4x4 rotation_matrix_2d(float radians)
{
    float cos = cosf(radians);
    float sin = sinf(radians);
    return (matrix_float4x4) {
        .columns[0] = {  cos, sin, 0, 0 },
        .columns[1] = { -sin, cos, 0, 0 },
        .columns[2] = {    0,   0, 1, 0 },
        .columns[3] = {    0,   0, 0, 1 }
    };
}

@implementation AppDelegate
@synthesize window;
@synthesize device;
@synthesize library;
@synthesize pipelineState;
@synthesize vertexBuffer;
@synthesize uniformBuffer;
@synthesize commandQueue;

- (id)init
{
    NSError* error;

    /*
     * Window and view setup
     */
    NSRect frame = NSMakeRect(0, 0, 640, 480);

    window = [[NSWindow alloc]
        initWithContentRect:frame
        styleMask:NSTitledWindowMask|NSClosableWindowMask
        backing:NSBackingStoreBuffered
        defer:NO];

    device = MTLCreateSystemDefaultDevice();

    MTKView* view = [[MTKView alloc]
        initWithFrame:frame
        device:device];
    [view setDelegate:self];

    [window center];
    [window setContentView:view];
    [window makeKeyAndOrderFront:NSApp];

    /*
     * Metal setup: Library
     */
    NSString* librarySrc = [NSString stringWithContentsOfFile:@"library.msl" encoding:NSUTF8StringEncoding error:&error];
    if(!librarySrc) {
        [NSException raise:@"Failed to read shaders" format:@"%@", [error localizedDescription]];
    }

    library = [device newLibraryWithSource:librarySrc options:nil error:&error];
    if(!library) {
        [NSException raise:@"Failed to compile shaders" format:@"%@", [error localizedDescription]];
    }

    /*
     * Metal setup: Pipeline
     */
    id<CAMetalDrawable> drawable = [view currentDrawable];

    MTLRenderPipelineDescriptor* pipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDesc.vertexFunction = [library newFunctionWithName:@"vertex_function"];
    pipelineDesc.fragmentFunction = [library newFunctionWithName:@"fragment_function"];
    pipelineDesc.colorAttachments[0].pixelFormat = drawable.texture.pixelFormat;

    pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];
    if(!pipelineState) {
        [NSException raise:@"Failed to create pipeline state" format:@"%@", [error localizedDescription]];
    }

    /*
     * Metal setup: Vertices
     */
    vertexBuffer = [device newBufferWithBytes:quadVertexData
        length:sizeof(quadVertexData)
        options:MTLResourceStorageModePrivate];

    /*
     * Metal setup: Uniforms
     */
    uniformBuffer = [device newBufferWithLength:sizeof(Uniforms)
        options:MTLResourceCPUCacheModeWriteCombined];

    /*
     * Metal setup: Command queue
     */
    commandQueue = [device newCommandQueue];

    return self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    (void)theApplication;
    return YES;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // Window is not resizable
    (void)view;
    (void)size;
}

- (void)drawInMTKView:(MTKView *)view
{
    double rotationAngle = fmod(CACurrentMediaTime(), 2.0 * M_PI);
    Uniforms uniforms = {
        .rotation_matrix = rotation_matrix_2d(rotationAngle)
    };
    void* bufferPtr = [uniformBuffer contents];
    memcpy(bufferPtr, &uniforms, sizeof(Uniforms));

    MTLRenderPassDescriptor* passDescriptor = [view currentRenderPassDescriptor];
    id<CAMetalDrawable> drawable = [view currentDrawable];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];

    [commandEncoder setRenderPipelineState:pipelineState];
    [commandEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
    [commandEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end
