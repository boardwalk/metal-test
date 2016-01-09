#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, MTKViewDelegate>
@property (retain) NSWindow *window;
@property (retain) id<MTLDevice> device;
@end
