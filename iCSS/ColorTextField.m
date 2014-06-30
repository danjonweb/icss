//
//  ColorTextField.m
//  iCSS
//
//  Created by Daniel Weber on 6/23/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "ColorTextField.h"
#import "NSColor+HTMLColors.h"

@interface ColorTextField ()
@property (nonatomic) NSInteger cursorType;
@end

@implementation ColorTextField

- (void)viewDidMoveToWindow {    
    if (self.popUpButton) {
        [self.popUpButton removeFromSuperview];
        self.popUpButton = nil;
    }
    
    NSPopUpButton *button = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(NSWidth(self.frame)-36, 0, 36, 22)];
    button.bordered = NO;
    button.pullsDown = YES;
    [button.cell setImageScaling:NSImageScaleProportionallyDown];
    [button.cell setImagePosition:NSImageOnly];
    [button addItemWithTitle:@""];
    NSImage *image = [NSImage imageNamed:NSImageNameColorPanel];
    [button.lastItem setImage:image];
    button.autoenablesItems = NO;
    [self addSubview:button];
    self.popUpButton = button;
    [self reload];
    
    if (self.trackingArea) {
        [self removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseMoved | NSTrackingActiveInKeyWindow) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    self.trackingArea = trackingArea;
}

- (void)reload {
    while (self.popUpButton.numberOfItems > 1) {
        [self.popUpButton removeItemAtIndex:1];
    }
    
    NSDictionary *attrs = @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]};
    [self.popUpButton addItemWithTitle:@"unchanged"];
    [self.popUpButton.lastItem setAttributedTitle:[[NSAttributedString alloc] initWithString:self.popUpButton.lastItem.title attributes:attrs]];
    [self.popUpButton.lastItem setTarget:self];
    [self.popUpButton.lastItem setAction:@selector(colorSelected:)];
    [self.popUpButton.menu addItem:[NSMenuItem separatorItem]];
    
    NSArray *recentColors = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentColors"];
    if (recentColors && recentColors.count > 0) {
        [self.popUpButton addItemWithTitle:@"Recent Colors"];
        [self.popUpButton.lastItem setAttributedTitle:[[NSAttributedString alloc] initWithString:self.popUpButton.lastItem.title attributes:attrs]];
        self.popUpButton.lastItem.enabled = NO;
        
        NSMutableString *space = [NSMutableString stringWithString:@" "];
        
        for (NSString *color in recentColors) {
            [self.popUpButton addItemWithTitle:@""];
            self.popUpButton.lastItem.title = [NSString stringWithFormat:@"%@%@", color, space];
            self.popUpButton.lastItem.action = @selector(colorSelected:);
            self.popUpButton.lastItem.target = self;
            NSImage *colorImage = [[NSImage alloc] initWithSize:NSMakeSize(10, 10)];
            [colorImage lockFocus];
            [[NSColor lightGrayColor] set];
            NSRectFill(NSMakeRect(0, 0, 10, 10));
            [[NSColor colorWithCSS:color] set];
            NSRectFill(NSMakeRect(1, 1, 8, 8));
            [colorImage unlockFocus];
            [self.popUpButton.lastItem setAttributedTitle:[[NSAttributedString alloc] initWithString:self.popUpButton.lastItem.title attributes:attrs]];
            [self.popUpButton.lastItem setImage:colorImage];
            [space appendString:@" "];
        }
        
        [self.popUpButton.menu addItem:[NSMenuItem separatorItem]];
    }
    
    [self.popUpButton addItemWithTitle:@"Named Colors"];
    [self.popUpButton.lastItem setAttributedTitle:[[NSAttributedString alloc] initWithString:self.popUpButton.lastItem.title attributes:attrs]];
    self.popUpButton.lastItem.enabled = NO;
    
    NSArray *colors = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"colors" ofType:@"plist"]];
    for (NSString *color in colors) {
        [self.popUpButton addItemWithTitle:color];
        NSImage *colorImage = [[NSImage alloc] initWithSize:NSMakeSize(10, 10)];
        [colorImage lockFocus];
        [[NSColor lightGrayColor] set];
        NSRectFill(NSMakeRect(0, 0, 10, 10));
        [[NSColor colorWithCSS:color] set];
        NSRectFill(NSMakeRect(1, 1, 8, 8));
        [colorImage unlockFocus];
        [self.popUpButton.lastItem setAttributedTitle:[[NSAttributedString alloc] initWithString:self.popUpButton.lastItem.title attributes:attrs]];
        [self.popUpButton.lastItem setImage:colorImage];
        [self.popUpButton.lastItem setTarget:self];
        [self.popUpButton.lastItem setAction:@selector(colorSelected:)];
    }
}

- (void)updateTrackingAreas {
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = nil;
    
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseMoved | NSTrackingActiveInKeyWindow) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    self.trackingArea = trackingArea;
}

- (void)mouseMoved:(NSEvent *)theEvent {
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    if (NSPointInRect(point, self.popUpButton.frame)) {
        [[NSCursor arrowCursor] set];
    } else {
        [[NSCursor IBeamCursor] set];
    }
}

- (void)colorSelected:(id)sender {
    if ([[sender title] isEqualToString:@"unchanged"]) {
        self.stringValue = @"";
    } else {
        self.stringValue = [sender title];
    }
    NSNotification *notification = [[NSNotification alloc] initWithName:NSTextDidChangeNotification object:self userInfo:nil];
    [self.delegate performSelector:@selector(controlTextDidChange:) withObject:notification];
}

- (void)setStringValue:(NSString *)stringValue {
    NSColor *color = [NSColor colorWithCSS:stringValue];
    if (color) {
        if (color.alphaComponent == 1.0) {
            NSDictionary *colorNameDict = [NSColor W3CColors];
            NSString *hexString = color.hexStringValue;
            if ([colorNameDict objectForKey:hexString]) {
                [super setStringValue:colorNameDict[hexString]];
            } else {
                [super setStringValue:color.hexStringValue];
            }
        } else {
            [super setStringValue:color.rgbStringValue];
        }
    } else {
        [super setStringValue:stringValue];
    }
}

@end
