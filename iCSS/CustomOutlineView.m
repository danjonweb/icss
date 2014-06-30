//
//  CustomOutlineView.m
//  Test3
//
//  Created by Daniel Weber on 3/14/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "CustomOutlineView.h"
#import "NSBezierPath+StrokeExtensions.h"

@implementation CustomOutlineView

- (void)awakeFromNib {
    [self setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
}

- (void)drawRow:(NSInteger)row clipRect:(NSRect)clipRect
{
    NSColor* bgColor = nil;
    NSColor *strokeColor = nil;
    
    if (self == [[self window] firstResponder] && [[self window] isMainWindow] && [[self window] isKeyWindow]) {
        bgColor = [NSColor colorWithCalibratedRed:135/255.0 green:166/255.0 blue:203/255.0 alpha:1.0];
        strokeColor = [NSColor colorWithCalibratedRed:127/255.0 green:156/255.0 blue:191/255.0 alpha:1.0];
    } else {
        bgColor = [NSColor colorWithCalibratedWhite:0.800 alpha:1.000];
        strokeColor = [NSColor colorWithCalibratedWhite:0.700 alpha:1.000];
    }
    
    NSIndexSet* selectedRowIndexes = [self selectedRowIndexes];
    if ([selectedRowIndexes containsIndex:row]) {
        [bgColor setFill];
        [strokeColor setStroke];
        NSRect rect = [self rectOfRow:row];
        rect = NSInsetRect(rect, 2, 0);
        [[NSBezierPath bezierPathWithRoundedRect:rect xRadius:3.0 yRadius:3.0] fill];
        [[NSBezierPath bezierPathWithRoundedRect:rect xRadius:3.0 yRadius:3.0] strokeInside];
    }
    [super drawRow:row clipRect:clipRect];
}

@end
