#import "AppDelegate.h"

@implementation AppDelegate
@synthesize window;

- (id)init
{
    window = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, 640, 480)
        styleMask:NSTitledWindowMask|NSClosableWindowMask
        backing:NSBackingStoreBuffered
        defer:NO];
    [window setBackgroundColor:[NSColor blueColor]];
    [window center];
    [window makeKeyAndOrderFront:NSApp];
    return self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
