//
//  ColorTextFieldCell.m
//  iCSS
//
//  Created by Daniel Weber on 6/23/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "ColorTextFieldCell.h"

#define RIGHT_MARGIN 28

@implementation ColorTextFieldCell

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    titleFrame.size.width -= RIGHT_MARGIN;
    return titleFrame;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
    aRect.size.width -= RIGHT_MARGIN;
    [super editWithFrame:aRect inView: controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
    aRect.size.width -= RIGHT_MARGIN;
    [super selectWithFrame:aRect inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    cellFrame.size.width -= RIGHT_MARGIN;
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
