#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, MTKViewDelegate> {
    NSWindow *_window;
    id<MTLDevice> _device;
    id<MTLLibrary> _library;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _uniformBuffer;
    id<MTLCommandQueue> _commandQueue;
}
@end
