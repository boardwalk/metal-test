#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, MTKViewDelegate>
@property (nonatomic) NSWindow *window;
@property (nonatomic) id<MTLDevice> device;
@property (nonatomic) id<MTLLibrary> library;
@property (nonatomic) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic) id<MTLBuffer> uniformBuffer;
@property (nonatomic) id<MTLCommandQueue> commandQueue;
@end
