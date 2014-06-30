//
//  NSColor+Extensions.m
//  iCSS
//
//  Created by Daniel Weber on 3/11/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "NSColor+Extensions.h"

@implementation NSColor (Extensions)

+ (NSColor *)lightTextBackgroundColor {
    static NSColor *darkPatternColor = nil;
    
    if (darkPatternColor == nil) {
        NSImage *darkImage = [[NSImage alloc] initWithSize:NSMakeSize(8, 8)];
        [darkImage lockFocus];
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.65] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 8, 8)] fill];
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:.15] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 4, 4)] fill];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(4, 4, 4, 4)] fill];
        
        /*[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.6] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 8, 8)] fill];
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:4] set];
        for (int i = 0; i < 8; i=i+2) {
            NSRectFill(NSMakeRect(i, 0, 1, 8));
        }*/
        
        [darkImage unlockFocus];
        darkPatternColor = [NSColor colorWithPatternImage:darkImage];
    }
    return darkPatternColor;
}

@end
