#import "AppDelegate.h"
#import <simd/simd.h>

typedef struct {
    matrix_float4x4 rotationMatrix;
} Uniforms;

typedef struct {
    vector_float4 position;
    vector_float4 color;
} VertexIn;

static const VertexIn vertexData[] =
{
    { { 0.5, -0.5, 0.0, 1.0}, {1.0, 0.0, 0.0, 1.0} },
    { {-0.5, -0.5, 0.0, 1.0}, {0.0, 1.0, 0.0, 1.0} },
    { {-0.5,  0.5, 0.0, 1.0}, {0.0, 0.0, 1.0, 1.0} },
    { { 0.5,  0.5, 0.0, 1.0}, {1.0, 1.0, 0.0, 1.0} },
    { { 0.5, -0.5, 0.0, 1.0}, {1.0, 0.0, 0.0, 1.0} },
    { {-0.5,  0.5, 0.0, 1.0}, {0.0, 0.0, 1.0, 1.0} }
};

static matrix_float4x4 rotationMatrix2D(float radians)
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

- (id)init
{
    NSError* error;

    /*
     * Window and view setup
     */
    NSRect frame = NSMakeRect(0, 0, 640, 480);

    _window = [[NSWindow alloc] initWithContentRect:frame
        styleMask:NSTitledWindowMask|NSClosableWindowMask
        backing:NSBackingStoreBuffered
        defer:NO];

    _device = MTLCreateSystemDefaultDevice();

    MTKView* view = [[MTKView alloc] initWithFrame:frame
        device:_device];
    [view setDelegate:self];

    [_window center];
    [_window setContentView:view];
    [_window makeKeyAndOrderFront:NSApp];

    /*
     * Metal setup: Library
     */
    NSString* librarySrc = [NSString stringWithContentsOfFile:@"library.metal" encoding:NSUTF8StringEncoding error:&error];
    if(!librarySrc) {
        [NSException raise:@"Failed to read shaders" format:@"%@", [error localizedDescription]];
    }

    _library = [_device newLibraryWithSource:librarySrc options:nil error:&error];
    if(!_library) {
        [NSException raise:@"Failed to compile shaders" format:@"%@", [error localizedDescription]];
    }

    /*
     * Metal setup: Pipeline
     */
    id<CAMetalDrawable> drawable = [view currentDrawable];

    MTLRenderPipelineDescriptor* pipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDesc.vertexFunction = [_library newFunctionWithName:@"vertexFunction"];
    pipelineDesc.fragmentFunction = [_library newFunctionWithName:@"fragmentFunction"];
    pipelineDesc.colorAttachments[0].pixelFormat = drawable.texture.pixelFormat;

    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];
    if(!_pipelineState) {
        [NSException raise:@"Failed to create pipeline state" format:@"%@", [error localizedDescription]];
    }

    /*
     * Metal setup: Vertices
     */
    _vertexBuffer = [_device newBufferWithBytes:vertexData
        length:sizeof(vertexData)
        options:MTLResourceStorageModePrivate];

    /*
     * Metal setup: Uniforms
     */
    _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms)
        options:MTLResourceCPUCacheModeWriteCombined];

    /*
     * Metal setup: Command queue
     */
    _commandQueue = [_device newCommandQueue];

    return self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication
{
    (void)theApplication;
    return YES;
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    // Window is not resizable
    (void)view;
    (void)size;
}

- (void)drawInMTKView:(MTKView*)view
{
    double rotationAngle = fmod(CACurrentMediaTime(), 2.0 * M_PI);
    void* uniformSrc = &(Uniforms) {
        .rotationMatrix = rotationMatrix2D(rotationAngle)
    };
    void* uniformTgt = [_uniformBuffer contents];
    memcpy(uniformTgt, uniformSrc, sizeof(Uniforms));

    MTLRenderPassDescriptor* passDescriptor = [view currentRenderPassDescriptor];
    id<CAMetalDrawable> drawable = [view currentDrawable];
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];

    [commandEncoder setRenderPipelineState:_pipelineState];
    [commandEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    [commandEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
    [commandEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end
