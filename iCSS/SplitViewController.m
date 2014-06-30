//
//  SplitViewController.m
//  iCSS
//
//  Created by Daniel Weber on 1/25/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "SplitViewController.h"

@implementation SplitViewController

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return 221;
    }
    return proposedMinimumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return 500;
    }
    return proposedMaximumPosition;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    if (view == [splitView.subviews objectAtIndex:0]) {
        return NO;
    }
    if (view == [splitView.subviews objectAtIndex:1]) {
        return YES;
    }
    if (view == [splitView.subviews objectAtIndex:2]) {
        return NO;
    }
    return NO;
}

- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex {
    if (dividerIndex == 1) {
        return NSZeroRect;
    }
    return proposedEffectiveRect;
}

@end
