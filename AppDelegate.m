#import "AppDelegate.h"

@implementation AppDelegate
@synthesize window;
@synthesize device;

- (id)init
{
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

    return self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // Window is not resizable
}

- (void)drawInMTKView:(MTKView *)view
{
    // TODO
}

@end
