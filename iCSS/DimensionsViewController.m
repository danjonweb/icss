//
//  DimensionsViewController.m
//  iCSS
//
//  Created by Daniel Weber on 6/28/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "DimensionsViewController.h"
#import "Document.h"
#import <WebKit/WebKit.h>

@implementation DimensionsViewController

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
    
    if (sender == self.dimensionsWidthControl || sender == self.dimensionsWidthUnitsControl) {
#pragma mark width
        NSTextField *textField = self.dimensionsWidthControl;
        NSPopUpButton *popUpButton = self.dimensionsWidthUnitsControl;
        NSString *property = @"width";
        NSArray *keywords = @[@"auto"];
        
        if ([popUpButton.titleOfSelectedItem isEqualToString:@"unchanged"]) {
            [self.document removeProperty:property fromStyle:YES];
        } else {
            NSString *value;
            if ([keywords containsObject:popUpButton.titleOfSelectedItem]) {
                value = popUpButton.titleOfSelectedItem;
                textField.stringValue = @"";
            } else {
                if (textField.stringValue.length == 0) {
                    textField.stringValue = @"0";
                }
                value = [NSString stringWithFormat:@"%@%@", textField.stringValue, popUpButton.titleOfSelectedItem];
            }
            [self.document replaceProperty:property value:value inStyle:YES];
        }
    } else if (sender == self.dimensionsHeightControl || sender == self.dimensionsHeightUnitsControl) {
#pragma mark height
        NSTextField *textField = self.dimensionsHeightControl;
        NSPopUpButton *popUpButton = self.dimensionsHeightUnitsControl;
        NSString *property = @"height";
        NSArray *keywords = @[@"auto"];
        
        if ([popUpButton.titleOfSelectedItem isEqualToString:@"unchanged"]) {
            [self.document removeProperty:property fromStyle:YES];
        } else {
            NSString *value;
            if ([keywords containsObject:popUpButton.titleOfSelectedItem]) {
                value = popUpButton.titleOfSelectedItem;
                textField.stringValue = @"";
            } else {
                if (textField.stringValue.length == 0) {
                    textField.stringValue = @"0";
                }
                value = [NSString stringWithFormat:@"%@%@", textField.stringValue, popUpButton.titleOfSelectedItem];
            }
            [self.document replaceProperty:property value:value inStyle:YES];
        }
    } else if (sender == self.dimensionsMarginAllControl || sender == self.dimensionsMarginAllUnitsControl ||
               sender == self.dimensionsMarginTopControl || sender == self.dimensionsMarginTopUnitsControl ||
               sender == self.dimensionsMarginRightControl || sender == self.dimensionsMarginRightUnitsControl ||
               sender == self.dimensionsMarginBottomControl || sender == self.dimensionsMarginBottomUnitsControl ||
               sender == self.dimensionsMarginLeftControl || sender == self.dimensionsMarginLeftUnitsControl) {
#pragma mark margins
        if (sender == self.dimensionsMarginAllControl || sender == self.dimensionsMarginAllUnitsControl) {
            if (self.dimensionsMarginAllControl.stringValue.length == 0) {
                [self.document removeProperty:@"margin" fromStyle:YES];
            } else {
                [self.document removeProperty:@"margin-top" fromStyle:NO];
                [self.document removeProperty:@"margin-right" fromStyle:NO];
                [self.document removeProperty:@"margin-bottom" fromStyle:NO];
                [self.document removeProperty:@"margin-left" fromStyle:NO];
                [self.document replaceProperty:@"margin" value:[NSString stringWithFormat:@"%@%@", self.dimensionsMarginAllControl.stringValue, self.dimensionsMarginAllUnitsControl.titleOfSelectedItem] inStyle:YES];
            }
        } else {
            if (self.dimensionsMarginTopControl.stringValue.length > 0 &&
                self.dimensionsMarginRightControl.stringValue.length > 0 &&
                self.dimensionsMarginBottomControl.stringValue.length > 0 &&
                self.dimensionsMarginLeftControl.stringValue.length > 0) {
                // All four values are present -- we can make a shortcut
                [self.document removeProperty:@"margin-top" fromStyle:NO];
                [self.document removeProperty:@"margin-right" fromStyle:NO];
                [self.document removeProperty:@"margin-bottom" fromStyle:NO];
                [self.document removeProperty:@"margin-left" fromStyle:NO];
                
                if ([self.dimensionsMarginTopControl.stringValue isEqualToString:self.dimensionsMarginRightControl.stringValue] && [self.dimensionsMarginRightControl.stringValue isEqualToString:self.dimensionsMarginBottomControl.stringValue] && [self.dimensionsMarginBottomControl.stringValue isEqualToString:self.dimensionsMarginLeftControl.stringValue] && [self.dimensionsMarginTopUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsMarginRightUnitsControl.titleOfSelectedItem] && [self.dimensionsMarginRightUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsMarginBottomUnitsControl.titleOfSelectedItem] && [self.dimensionsMarginBottomUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsMarginLeftUnitsControl.titleOfSelectedItem]) {
                    // 1 value: all four values are the same
                    [self.dimensionsMarginAllControl.window makeFirstResponder:nil];
                    [self.document replaceProperty:@"margin" value:[NSString stringWithFormat:@"%@%@", self.dimensionsMarginTopControl.stringValue, self.dimensionsMarginTopUnitsControl.titleOfSelectedItem] inStyle:YES];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self.dimensionsMarginAllControl.window makeFirstResponder:self.dimensionsMarginAllControl];
                    });
                } else if ([self.dimensionsMarginTopControl.stringValue isEqualToString:self.dimensionsMarginBottomControl.stringValue] && [self.dimensionsMarginTopUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsMarginBottomUnitsControl.titleOfSelectedItem] && [self.dimensionsMarginRightControl.stringValue isEqualToString:self.dimensionsMarginLeftControl.stringValue] && [self.dimensionsMarginRightUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsMarginLeftUnitsControl.titleOfSelectedItem]) {
                    // 2 values: top and bottom, and right and left are the same
                    [self.document replaceProperty:@"margin" value:[NSString stringWithFormat:@"%@%@ %@%@", self.dimensionsMarginTopControl.stringValue, self.dimensionsMarginTopUnitsControl.titleOfSelectedItem, self.dimensionsMarginLeftControl.stringValue, self.dimensionsMarginLeftUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else if ([self.dimensionsMarginLeftControl.stringValue isEqualToString:self.dimensionsMarginRightControl.stringValue] && [self.dimensionsMarginLeftUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsMarginRightUnitsControl.titleOfSelectedItem]) {
                    // 3 values: left and right are the same
                    [self.document replaceProperty:@"margin" value:[NSString stringWithFormat:@"%@%@ %@%@ %@%@", self.dimensionsMarginTopControl.stringValue, self.dimensionsMarginTopUnitsControl.titleOfSelectedItem, self.dimensionsMarginRightControl.stringValue, self.dimensionsMarginRightUnitsControl.titleOfSelectedItem, self.dimensionsMarginBottomControl.stringValue, self.dimensionsMarginBottomUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    // 4 values: all different
                    [self.document replaceProperty:@"margin" value:[NSString stringWithFormat:@"%@%@ %@%@ %@%@ %@%@", self.dimensionsMarginTopControl.stringValue, self.dimensionsMarginTopUnitsControl.titleOfSelectedItem, self.dimensionsMarginRightControl.stringValue, self.dimensionsMarginRightUnitsControl.titleOfSelectedItem, self.dimensionsMarginBottomControl.stringValue, self.dimensionsMarginBottomUnitsControl.titleOfSelectedItem, self.dimensionsMarginLeftControl.stringValue, self.dimensionsMarginLeftUnitsControl.titleOfSelectedItem] inStyle:YES];
                }
            } else {
                [self.document removeProperty:@"margin" fromStyle:NO];
                
                if (self.dimensionsMarginTopControl.stringValue.length > 0) {
                    [self.document replaceProperty:@"margin-top" value:[NSString stringWithFormat:@"%@%@", self.dimensionsMarginTopControl.stringValue, self.dimensionsMarginTopUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    [self.document removeProperty:@"margin-top" fromStyle:YES];
                }
                
                if (self.dimensionsMarginRightControl.stringValue.length > 0) {
                    [self.document replaceProperty:@"margin-right" value:[NSString stringWithFormat:@"%@%@", self.dimensionsMarginRightControl.stringValue, self.dimensionsMarginRightUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    [self.document removeProperty:@"margin-right" fromStyle:YES];
                }
                
                if (self.dimensionsMarginBottomControl.stringValue.length > 0) {
                    [self.document replaceProperty:@"margin-bottom" value:[NSString stringWithFormat:@"%@%@", self.dimensionsMarginBottomControl.stringValue, self.dimensionsMarginBottomUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    [self.document removeProperty:@"margin-bottom" fromStyle:YES];
                }
                
                if (self.dimensionsMarginLeftControl.stringValue.length > 0) {
                    [self.document replaceProperty:@"margin-left" value:[NSString stringWithFormat:@"%@%@", self.dimensionsMarginLeftControl.stringValue, self.dimensionsMarginLeftUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    [self.document removeProperty:@"margin-left" fromStyle:YES];
                }
            }
        }
    } else if (sender == self.dimensionsPaddingAllControl || sender == self.dimensionsPaddingAllUnitsControl ||
               sender == self.dimensionsPaddingTopControl || sender == self.dimensionsPaddingTopUnitsControl ||
               sender == self.dimensionsPaddingRightControl || sender == self.dimensionsPaddingRightUnitsControl ||
               sender == self.dimensionsPaddingBottomControl || sender == self.dimensionsPaddingBottomUnitsControl ||
               sender == self.dimensionsPaddingLeftControl || sender == self.dimensionsPaddingLeftUnitsControl) {
# pragma mark padding
        if (sender == self.dimensionsPaddingAllControl || sender == self.dimensionsPaddingAllUnitsControl) {
            if (self.dimensionsPaddingAllControl.stringValue.length == 0) {
                [self.document removeProperty:@"padding" fromStyle:YES];
            } else {
                [self.document removeProperty:@"padding-top" fromStyle:NO];
                [self.document removeProperty:@"padding-right" fromStyle:NO];
                [self.document removeProperty:@"padding-bottom" fromStyle:NO];
                [self.document removeProperty:@"padding-left" fromStyle:NO];
                [self.document replaceProperty:@"padding" value:[NSString stringWithFormat:@"%@%@", self.dimensionsPaddingAllControl.stringValue, self.dimensionsPaddingAllUnitsControl.titleOfSelectedItem] inStyle:YES];
            }
        } else {
            if (self.dimensionsPaddingTopControl.stringValue.length > 0 &&
                self.dimensionsPaddingRightControl.stringValue.length > 0 &&
                self.dimensionsPaddingBottomControl.stringValue.length > 0 &&
                self.dimensionsPaddingLeftControl.stringValue.length > 0) {
                // All four values are present -- we can make a shortcut
                [self.document removeProperty:@"padding-top" fromStyle:NO];
                [self.document removeProperty:@"padding-right" fromStyle:NO];
                [self.document removeProperty:@"padding-bottom" fromStyle:NO];
                [self.document removeProperty:@"padding-left" fromStyle:NO];
                
                if ([self.dimensionsPaddingTopControl.stringValue isEqualToString:self.dimensionsPaddingRightControl.stringValue] && [self.dimensionsPaddingRightControl.stringValue isEqualToString:self.dimensionsPaddingBottomControl.stringValue] && [self.dimensionsPaddingBottomControl.stringValue isEqualToString:self.dimensionsPaddingLeftControl.stringValue] && [self.dimensionsPaddingTopUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsPaddingRightUnitsControl.titleOfSelectedItem] && [self.dimensionsPaddingRightUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsPaddingBottomUnitsControl.titleOfSelectedItem] && [self.dimensionsPaddingBottomUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsPaddingLeftUnitsControl.titleOfSelectedItem]) {
                    // 1 value: all four values are the same
                    [self.dimensionsPaddingAllControl.window makeFirstResponder:nil];
                    [self.document replaceProperty:@"padding" value:[NSString stringWithFormat:@"%@%@", self.dimensionsPaddingTopControl.stringValue, self.dimensionsPaddingTopUnitsControl.titleOfSelectedItem] inStyle:YES];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self.dimensionsPaddingAllControl.window makeFirstResponder:self.dimensionsPaddingAllControl];
                    });
                } else if ([self.dimensionsPaddingTopControl.stringValue isEqualToString:self.dimensionsPaddingBottomControl.stringValue] && [self.dimensionsPaddingTopUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsPaddingBottomUnitsControl.titleOfSelectedItem] && [self.dimensionsPaddingRightControl.stringValue isEqualToString:self.dimensionsPaddingLeftControl.stringValue] && [self.dimensionsPaddingRightUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsPaddingLeftUnitsControl.titleOfSelectedItem]) {
                    // 2 values: top and bottom, and right and left are the same
                    [self.document replaceProperty:@"padding" value:[NSString stringWithFormat:@"%@%@ %@%@", self.dimensionsPaddingTopControl.stringValue, self.dimensionsPaddingTopUnitsControl.titleOfSelectedItem, self.dimensionsPaddingLeftControl.stringValue, self.dimensionsPaddingLeftUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else if ([self.dimensionsPaddingLeftControl.stringValue isEqualToString:self.dimensionsPaddingRightControl.stringValue] && [self.dimensionsPaddingLeftUnitsControl.titleOfSelectedItem isEqualToString:self.dimensionsPaddingRightUnitsControl.titleOfSelectedItem]) {
                    // 3 values: left and right are the same
                    [self.document replaceProperty:@"padding" value:[NSString stringWithFormat:@"%@%@ %@%@ %@%@", self.dimensionsPaddingTopControl.stringValue, self.dimensionsPaddingTopUnitsControl.titleOfSelectedItem, self.dimensionsPaddingRightControl.stringValue, self.dimensionsPaddingRightUnitsControl.titleOfSelectedItem, self.dimensionsPaddingBottomControl.stringValue, self.dimensionsPaddingBottomUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    // 4 values: all different
                    [self.document replaceProperty:@"padding" value:[NSString stringWithFormat:@"%@%@ %@%@ %@%@ %@%@", self.dimensionsPaddingTopControl.stringValue, self.dimensionsPaddingTopUnitsControl.titleOfSelectedItem, self.dimensionsPaddingRightControl.stringValue, self.dimensionsPaddingRightUnitsControl.titleOfSelectedItem, self.dimensionsPaddingBottomControl.stringValue, self.dimensionsPaddingBottomUnitsControl.titleOfSelectedItem, self.dimensionsPaddingLeftControl.stringValue, self.dimensionsPaddingLeftUnitsControl.titleOfSelectedItem] inStyle:YES];
                }
            } else {
                [self.document removeProperty:@"padding" fromStyle:NO];
                
                if (self.dimensionsPaddingTopControl.stringValue.length > 0) {
                    [self.document replaceProperty:@"padding-top" value:[NSString stringWithFormat:@"%@%@", self.dimensionsPaddingTopControl.stringValue, self.dimensionsPaddingTopUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    [self.document removeProperty:@"padding-top" fromStyle:YES];
                }
                
                if (self.dimensionsPaddingRightControl.stringValue.length > 0) {
                    [self.document replaceProperty:@"padding-right" value:[NSString stringWithFormat:@"%@%@", self.dimensionsPaddingRightControl.stringValue, self.dimensionsPaddingRightUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    [self.document removeProperty:@"padding-right" fromStyle:YES];
                }
                
                if (self.dimensionsPaddingBottomControl.stringValue.length > 0) {
                    [self.document replaceProperty:@"padding-bottom" value:[NSString stringWithFormat:@"%@%@", self.dimensionsPaddingBottomControl.stringValue, self.dimensionsPaddingBottomUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    [self.document removeProperty:@"padding-bottom" fromStyle:YES];
                }
                
                if (self.dimensionsPaddingLeftControl.stringValue.length > 0) {
                    [self.document replaceProperty:@"padding-left" value:[NSString stringWithFormat:@"%@%@", self.dimensionsPaddingLeftControl.stringValue, self.dimensionsPaddingLeftUnitsControl.titleOfSelectedItem] inStyle:YES];
                } else {
                    [self.document removeProperty:@"padding-left" fromStyle:YES];
                }
            }
        }
    }
    
    [self loadStyleRule:styleRule];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id sender = [notification object];
    if (sender == self.dimensionsWidthControl) {
        if (self.dimensionsWidthUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsWidthUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsWidthControl.stringValue.length == 0) {
            [self.dimensionsWidthUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsHeightControl) {
        if (self.dimensionsHeightUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsHeightUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsHeightControl.stringValue.length == 0) {
            [self.dimensionsHeightUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsMarginAllControl) {
        if (self.dimensionsMarginAllUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsMarginAllUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsMarginAllControl.stringValue.length == 0) {
            [self.dimensionsMarginAllUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsMarginTopControl) {
        if (self.dimensionsMarginTopUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsMarginTopUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsMarginTopControl.stringValue.length == 0) {
            [self.dimensionsMarginTopUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsMarginRightControl) {
        if (self.dimensionsMarginRightUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsMarginRightUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsMarginRightControl.stringValue.length == 0) {
            [self.dimensionsMarginRightUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsMarginBottomControl) {
        if (self.dimensionsMarginBottomUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsMarginBottomUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsMarginBottomControl.stringValue.length == 0) {
            [self.dimensionsMarginBottomUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsMarginLeftControl) {
        if (self.dimensionsMarginLeftUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsMarginLeftUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsMarginLeftControl.stringValue.length == 0) {
            [self.dimensionsMarginLeftUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsPaddingAllControl) {
        if (self.dimensionsPaddingAllUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsPaddingAllUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsPaddingAllControl.stringValue.length == 0) {
            [self.dimensionsPaddingAllUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsPaddingTopControl) {
        if (self.dimensionsPaddingTopUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsPaddingTopUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsPaddingTopControl.stringValue.length == 0) {
            [self.dimensionsPaddingTopUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsPaddingRightControl) {
        if (self.dimensionsPaddingRightUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsPaddingRightUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsPaddingRightControl.stringValue.length == 0) {
            [self.dimensionsPaddingRightUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsPaddingBottomControl) {
        if (self.dimensionsPaddingBottomUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsPaddingBottomUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsPaddingBottomControl.stringValue.length == 0) {
            [self.dimensionsPaddingBottomUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.dimensionsPaddingLeftControl) {
        if (self.dimensionsPaddingLeftUnitsControl.indexOfSelectedItem == 0) {
            [self.dimensionsPaddingLeftUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.dimensionsPaddingLeftControl.stringValue.length == 0) {
            [self.dimensionsPaddingLeftUnitsControl selectItemWithTitle:@"unchanged"];
        }
    }
    [self controlChanged:sender];
}

#pragma mark - Clear Controls

- (void)clearControls {
    [self.document clearIfNotFirstResponder:self.dimensionsWidthControl];
    [self.dimensionsWidthUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsHeightControl];
    [self.dimensionsHeightUnitsControl selectItemWithTitle:@"unchanged"];
    
    [self.document clearIfNotFirstResponder:self.dimensionsMarginAllControl];
    [self.dimensionsMarginAllUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsMarginTopControl];
    [self.dimensionsMarginTopUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsMarginRightControl];
    [self.dimensionsMarginRightUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsMarginBottomControl];
    [self.dimensionsMarginBottomUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsMarginLeftControl];
    [self.dimensionsMarginLeftUnitsControl selectItemWithTitle:@"unchanged"];
    
    [self.document clearIfNotFirstResponder:self.dimensionsPaddingAllControl];
    [self.dimensionsPaddingAllUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsPaddingTopControl];
    [self.dimensionsPaddingTopUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsPaddingRightControl];
    [self.dimensionsPaddingRightUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsPaddingBottomControl];
    [self.dimensionsPaddingBottomUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.dimensionsPaddingLeftControl];
    [self.dimensionsPaddingLeftUnitsControl selectItemWithTitle:@"unchanged"];
}

#pragma mark - Load Style

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule {
    DOMCSSStyleDeclaration *style = styleRule.style;
    //NSLog(@"!!!!     Load Dimensions");
    [self clearControls];
    
#pragma mark width
    if (style.width.length > 0) {
        [self.document loadValue:style.width textControl:self.dimensionsWidthControl unitsControl:self.dimensionsWidthUnitsControl keywords:@[@"initial", @"inherit", @"auto"]];
    }
    
#pragma mark height
    if (style.height.length > 0) {
        [self.document loadValue:style.height textControl:self.dimensionsHeightControl unitsControl:self.dimensionsHeightUnitsControl keywords:@[@"initial", @"inherit", @"auto"]];
    }
    
#pragma mark margins
    if ((style.marginTop.length > 0 && style.marginRight.length > 0 && style.marginBottom.length > 0 && style.marginLeft.length > 0) && ([style.marginTop isEqualToString:style.marginRight] && [style.marginRight isEqualToString:style.marginBottom] && [style.marginBottom isEqualToString:style.marginLeft])) {
        // All margins match
        [self.document loadValue:style.marginTop textControl:self.dimensionsMarginAllControl unitsControl:self.dimensionsMarginAllUnitsControl keywords:@[@"auto"]];
    } else {
        if (style.marginTop.length > 0) {
            [self.document loadValue:style.marginTop textControl:self.dimensionsMarginTopControl unitsControl:self.dimensionsMarginTopUnitsControl keywords:@[@"auto"]];
        }
        if (style.marginRight.length > 0) {
            [self.document loadValue:style.marginRight textControl:self.dimensionsMarginRightControl unitsControl:self.dimensionsMarginRightUnitsControl keywords:@[@"auto"]];
        }
        if (style.marginBottom.length > 0) {
            [self.document loadValue:style.marginBottom textControl:self.dimensionsMarginBottomControl unitsControl:self.dimensionsMarginBottomUnitsControl keywords:@[@"auto"]];
        }
        if (style.marginLeft.length > 0) {
            [self.document loadValue:style.marginLeft textControl:self.dimensionsMarginLeftControl unitsControl:self.dimensionsMarginLeftUnitsControl keywords:@[@"auto"]];
        }
    }
    
#pragma mark padding
    if ((style.paddingTop.length > 0 && style.paddingRight.length > 0 && style.paddingBottom.length > 0 && style.paddingLeft.length > 0) && ([style.paddingTop isEqualToString:style.paddingRight] && [style.paddingRight isEqualToString:style.paddingBottom] && [style.paddingBottom isEqualToString:style.paddingLeft])) {
        // All padding matches
        [self.document loadValue:style.paddingTop textControl:self.dimensionsPaddingAllControl unitsControl:self.dimensionsPaddingAllUnitsControl keywords:@[]];
    } else {
        if (style.paddingTop.length > 0) {
            [self.document loadValue:style.paddingTop textControl:self.dimensionsPaddingTopControl unitsControl:self.dimensionsPaddingTopUnitsControl keywords:@[]];
        }
        if (style.paddingRight.length > 0) {
            [self.document loadValue:style.paddingRight textControl:self.dimensionsPaddingRightControl unitsControl:self.dimensionsPaddingRightUnitsControl keywords:@[]];
        }
        if (style.paddingBottom.length > 0) {
            [self.document loadValue:style.paddingBottom textControl:self.dimensionsPaddingBottomControl unitsControl:self.dimensionsPaddingBottomUnitsControl keywords:@[]];
        }
        if (style.paddingLeft.length > 0) {
            [self.document loadValue:style.paddingLeft textControl:self.dimensionsPaddingLeftControl unitsControl:self.dimensionsPaddingLeftUnitsControl keywords:@[]];
        }
    }
}

@end
