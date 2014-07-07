//
//  PositioningViewController.m
//  iCSS
//
//  Created by Daniel Weber on 6/28/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "PositioningViewController.h"
#import "Document.h"
#import <WebKit/WebKit.h>

@implementation PositioningViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - Control Changed

- (IBAction)controlChanged:(id)sender {
    DOMCSSStyleRule *styleRule = [self.document currentStyleRule];
    
    if (sender == self.positionControl) {
        [self.document changeProperty:@"position" popUpControl:self.positionControl];
    }
    if (sender == self.positionTopControl || sender == self.positionTopUnitsControl) {
        [self.document changeProperty:@"top" textControl:self.positionTopControl unitsControl:self.positionTopUnitsControl keywords:@[@"initial", @"inherit", @"auto"]];
    }
    if (sender == self.positionRightControl || sender == self.positionRightUnitsControl) {
        [self.document changeProperty:@"right" textControl:self.positionRightControl unitsControl:self.positionRightUnitsControl keywords:@[@"initial", @"inherit", @"auto"]];
    }
    if (sender == self.positionBottomControl || sender == self.positionBottomUnitsControl) {
        [self.document changeProperty:@"bottom" textControl:self.positionBottomControl unitsControl:self.positionBottomUnitsControl keywords:@[@"initial", @"inherit", @"auto"]];
    }
    if (sender == self.positionLeftControl || sender == self.positionLeftUnitsControl) {
        [self.document changeProperty:@"left" textControl:self.positionLeftControl unitsControl:self.positionLeftUnitsControl keywords:@[@"initial", @"inherit", @"auto"]];
    }
    if (sender == self.displayControl) {
        [self.document changeProperty:@"display" popUpControl:self.displayControl];
    }
    if (sender == self.floatControl) {
        NSString *property = @"float";
        NSSegmentedControl *segmentedControl = sender;
        NSInteger selectedIndex = segmentedControl.selectedSegment;
        for (NSInteger i = 0; i < segmentedControl.segmentCount; i++) {
            [segmentedControl setSelected:NO forSegment:i];
        }
        if (selectedIndex == 0) {
            if ([[styleRule.style getPropertyValue:property] isEqualToString:@"left"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"left" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:selectedIndex];
            }
        } else if (selectedIndex == 1) {
            if ([[styleRule.style getPropertyValue:property] isEqualToString:@"right"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"right" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:selectedIndex];
            }
        } else if (selectedIndex == 2) {
            if ([[styleRule.style getPropertyValue:property] isEqualToString:@"none"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"none" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:selectedIndex];
            }
        }
    }
    if (sender == self.clearControl) {
        NSString *property = @"clear";
        NSSegmentedControl *segmentedControl = sender;
        NSInteger selectedIndex = segmentedControl.selectedSegment;
        for (NSInteger i = 0; i < segmentedControl.segmentCount; i++) {
            [segmentedControl setSelected:NO forSegment:i];
        }
        if (selectedIndex == 0) {
            if ([[styleRule.style getPropertyValue:property] isEqualToString:@"left"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"left" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:selectedIndex];
            }
        } else if (selectedIndex == 1) {
            if ([[styleRule.style getPropertyValue:property] isEqualToString:@"right"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"right" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:selectedIndex];
            }
        } else if (selectedIndex == 2) {
            if ([[styleRule.style getPropertyValue:property] isEqualToString:@"both"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"both" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:selectedIndex];
            }
        } else if (selectedIndex == 3) {
            if ([[styleRule.style getPropertyValue:property] isEqualToString:@"none"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"none" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:selectedIndex];
            }
        }
    }
    if (sender == self.visibilityControl) {
        [self.document changeProperty:@"visibility" popUpControl:self.visibilityControl];
    }
    if (sender == self.overflowControl) {
        [self.document changeProperty:@"overflow" popUpControl:self.overflowControl];
    }
    if (sender == self.zIndexUpDownControl) {
        if (self.zIndexUpDownControl.selectedSegment == 0) {
            NSInteger i = self.zIndexTextControl.integerValue;
            i++;
            [self.document replaceProperty:@"z-index" value:[NSString stringWithFormat:@"%li", (long)i] inStyle:YES];
        } else if (self.zIndexUpDownControl.selectedSegment == 1) {
            NSInteger i = self.zIndexTextControl.integerValue;
            i--;
            [self.document replaceProperty:@"z-index" value:[NSString stringWithFormat:@"%li", (long)i] inStyle:YES];
        }
    }
    if (sender == self.zIndexTextControl) {
        if (self.zIndexTextControl.stringValue.length == 0) {
            [self.document removeProperty:@"z-index" fromStyle:YES];
        } else {
            [self.document replaceProperty:@"z-index" value:self.zIndexTextControl.stringValue inStyle:YES];
        }
    }
    
    [self loadStyleRule:styleRule];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id sender = [notification object];
    
    if (sender == self.positionTopControl) {
        if ([self.positionTopUnitsControl.titleOfSelectedItem isEqualToString:@"unchanged"]) {
            [self.positionTopUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.positionTopControl.stringValue.length == 0) {
            [self.positionTopUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.positionRightControl) {
        if ([self.positionRightUnitsControl.titleOfSelectedItem isEqualToString:@"unchanged"]) {
            [self.positionRightUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.positionRightControl.stringValue.length == 0) {
            [self.positionRightUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.positionBottomControl) {
        if ([self.positionBottomUnitsControl.titleOfSelectedItem isEqualToString:@"unchanged"]) {
            [self.positionBottomUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.positionBottomControl.stringValue.length == 0) {
            [self.positionBottomUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.positionLeftControl) {
        if ([self.positionLeftUnitsControl.titleOfSelectedItem isEqualToString:@"unchanged"]) {
            [self.positionLeftUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.positionLeftControl.stringValue.length == 0) {
            [self.positionLeftUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.zIndexTextControl) {
        
    }
    
    [self controlChanged:sender];
}

#pragma mark - Clear Controls

- (void)clearControls {
    [self.positionControl selectItemWithTitle:@"unchanged"];
    
    [self.document clearIfNotFirstResponder:self.positionTopControl];
    [self.positionTopUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.positionRightControl];
    [self.positionRightUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.positionBottomControl];
    [self.positionBottomUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.positionLeftControl];
    [self.positionLeftUnitsControl selectItemWithTitle:@"unchanged"];
    
    [self.displayControl selectItemWithTitle:@"unchanged"];
    
    [self.floatControl setSelected:NO forSegment:0];
    [self.floatControl setSelected:NO forSegment:1];
    [self.floatControl setSelected:NO forSegment:2];
    
    [self.clearControl setSelected:NO forSegment:0];
    [self.clearControl setSelected:NO forSegment:1];
    [self.clearControl setSelected:NO forSegment:2];
    [self.clearControl setSelected:NO forSegment:3];
    
    [self.visibilityControl selectItemWithTitle:@"unchanged"];
    [self.overflowControl selectItemWithTitle:@"unchanged"];
    [self.zIndexUpDownControl setSelected:NO forSegment:0];
    [self.zIndexUpDownControl setSelected:NO forSegment:1];
    [self.document clearIfNotFirstResponder:self.zIndexTextControl];
}

#pragma mark - Load Style

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule {
    DOMCSSStyleDeclaration *style = styleRule.style;
    [self clearControls];
    
    if (style.position.length > 0) {
        NSArray *itemTitles = [self.positionControl.itemTitles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        if ([itemTitles containsObject:style.position]) {
            [self.positionControl selectItemWithTitle:style.position];
        }
    }
    
    if (style.top.length > 0) {
        [self.document loadValue:style.top textControl:self.positionTopControl unitsControl:self.positionTopUnitsControl];
    }
    
    if (style.right.length > 0) {
        [self.document loadValue:style.right textControl:self.positionRightControl unitsControl:self.positionRightUnitsControl];
    }
    
    if (style.bottom.length > 0) {
        [self.document loadValue:style.bottom textControl:self.positionBottomControl unitsControl:self.positionBottomUnitsControl];
    }
    
    if (style.left.length > 0) {
        [self.document loadValue:style.left textControl:self.positionLeftControl unitsControl:self.positionLeftUnitsControl];
    }
    
    if (style.display.length > 0) {
        NSArray *itemTitles = [self.displayControl.itemTitles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        if ([itemTitles containsObject:style.display]) {
            [self.displayControl selectItemWithTitle:style.display];
        }
    }
    
    NSString *floatValue = [style getPropertyValue:@"float"];
    if (floatValue.length > 0) {
        if ([floatValue isEqualToString:@"left"]) {
            [self.floatControl setSelected:YES forSegment:0];
        } else if ([floatValue isEqualToString:@"right"]) {
            [self.floatControl setSelected:YES forSegment:1];
        } else if ([floatValue isEqualToString:@"none"]) {
            [self.floatControl setSelected:YES forSegment:2];
        }
    }
    
    if (style.clear.length > 0) {
        if ([style.clear isEqualToString:@"left"]) {
            [self.clearControl setSelected:YES forSegment:0];
        } else if ([style.clear isEqualToString:@"right"]) {
            [self.clearControl setSelected:YES forSegment:1];
        } else if ([style.clear isEqualToString:@"both"]) {
            [self.clearControl setSelected:YES forSegment:2];
        } else if ([style.clear isEqualToString:@"none"]) {
            [self.clearControl setSelected:YES forSegment:3];
        }
    }
    
    if (style.visibility.length > 0) {
        NSArray *itemTitles = [self.visibilityControl.itemTitles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        if ([itemTitles containsObject:style.visibility]) {
            [self.visibilityControl selectItemWithTitle:style.visibility];
        }
    }
    
    if (style.overflow.length > 0) {
        NSArray *itemTitles = [self.overflowControl.itemTitles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        if ([itemTitles containsObject:style.overflow]) {
            [self.overflowControl selectItemWithTitle:style.overflow];
        }
    }
    
    if (style.zIndex.length > 0) {
        self.zIndexTextControl.stringValue = style.zIndex;
    }
}

@end
