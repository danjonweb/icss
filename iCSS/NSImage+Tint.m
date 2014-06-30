#import "NSImage+Tint.h"

@implementation NSImage (Tint)

- (NSImage *)tintedImageWithColor:(NSColor *)tint {
    NSSize size = [self size];
    NSRect imageBounds = NSMakeRect(0, 0, size.width, size.height);
    
    NSImage *copiedImage = [self copy];
    
    [copiedImage lockFocus];
    
    [tint set];
    NSRectFillUsingOperation(imageBounds, NSCompositeSourceAtop);
    
    [copiedImage unlockFocus];
    
    return [copiedImage autorelease];
}

@end