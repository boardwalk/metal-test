#import <AppKit/AppKit.h>
#import "AppDelegate.h"

int main() {
    [NSApplication sharedApplication];
    AppDelegate* appDelegate = [[AppDelegate alloc] init];
    [NSApp setDelegate:appDelegate];
    [NSApp run];
    return 0;
}
