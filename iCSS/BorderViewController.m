//
//  BorderViewController.m
//  iCSS
//
//  Created by Daniel Weber on 6/27/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "BorderViewController.h"
#import "Document.h"
#import "NSColor+HTMLColors.h"
#import "ColorTextField.h"
#import <WebKit/WebKit.h>

@interface BorderViewController ()
@property (nonatomic, assign) BOOL reloadBorderSelection;
@end

@implementation BorderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)controlChanged:(id)sender {
    DOMCSSStyleRule *styleRule = [self.document currentStyleRule];
    DOMCSSStyleDeclaration *style = styleRule.style;
    
    if (sender == self.borderControl) {
        [self.borderControl.window makeFirstResponder:nil];
    }
    
    NSString *borderStyleProperty;
    NSString *borderColorProperty;
    NSString *borderWidthProperty;
    NSString *borderShorthandProperty;
    NSTextField *textField;
    
    if (self.borderControl.selectedSegment == 0) {
        borderStyleProperty = @"border-style";
        borderColorProperty = @"border-color";
        borderWidthProperty = @"border-width";
        borderShorthandProperty = @"border";
        textField = self.borderAllField;
    } else if (self.borderControl.selectedSegment == 1) {
        borderStyleProperty = @"border-top-style";
        borderColorProperty = @"border-top-color";
        borderWidthProperty = @"border-top-width";
        borderShorthandProperty = @"border-top";
        textField = self.borderTopField;
    } else if (self.borderControl.selectedSegment == 2) {
        borderStyleProperty = @"border-right-style";
        borderColorProperty = @"border-right-color";
        borderWidthProperty = @"border-right-width";
        borderShorthandProperty = @"border-right";
        textField = self.borderRightField;
    } else if (self.borderControl.selectedSegment == 3) {
        borderStyleProperty = @"border-bottom-style";
        borderColorProperty = @"border-bottom-color";
        borderWidthProperty = @"border-bottom-width";
        borderShorthandProperty = @"border-bottom";
        textField = self.borderBottomField;
    } else if (self.borderControl.selectedSegment == 4) {
        borderStyleProperty = @"border-left-style";
        borderColorProperty = @"border-left-color";
        borderWidthProperty = @"border-left-width";
        borderShorthandProperty = @"border-left";
        textField = self.borderLeftField;
    }
    
    if (sender == self.borderRemoveControl) {
        if (textField.stringValue.length > 0) {
            if (![self.borderStyleControl.titleOfSelectedItem isEqualToString:@"unchanged"]) {
                [self.document removeProperty:borderStyleProperty fromStyle:YES];
            }
            if (self.borderColorTextControl.stringValue > 0) {
                [self.document removeProperty:borderColorProperty fromStyle:YES];
            }
            if (![self.borderThicknessUnitsControl.titleOfSelectedItem isEqualToString:@"unchanged"]) {
                [self.document removeProperty:borderWidthProperty fromStyle:YES];
            }
        }
    }
    
    if (sender == self.borderStyleControl || sender == self.borderColorControl || sender == self.borderColorTextControl || sender == self.borderThicknessControl || sender == self.borderThicknessUnitsControl || sender == self.borderRemoveControl) {
        
        if (sender == self.borderStyleControl) {
            [self.document changeProperty:borderStyleProperty popUpControl:sender];
        }
        
        if (sender == self.borderColorControl) {
            [self.document saveColor:self.borderColorControl.color reloadControl:self.borderColorTextControl];
            [self.document replaceProperty:borderColorProperty value:self.borderColorControl.color.formattedString inStyle:YES];
        }
        if (sender == self.borderColorTextControl) {
            if (self.borderColorTextControl.stringValue.length == 0) {
                [self.document removeProperty:borderColorProperty fromStyle:YES];
            } else {
                NSColor *color = [NSColor colorWithCSS:self.borderColorTextControl.stringValue];
                if (color) {
                    [self.document replaceProperty:borderColorProperty value:color.formattedString inStyle:YES];
                    self.borderColorControl.color = color;
                } else {
                    return;
                }
            }
        }
        
        if (sender == self.borderThicknessControl || sender == self.borderThicknessUnitsControl) {
            [self.document changeProperty:borderWidthProperty textControl:self.borderThicknessControl unitsControl:self.borderThicknessUnitsControl keywords:@[@"initial", @"inherit", @"thin", @"medium", @"thick"]];
        }
        
        
        [self.document removeProperty:@"border" fromStyle:NO];
        [self.document removeProperty:@"border-style" fromStyle:NO];
        [self.document removeProperty:@"border-color" fromStyle:NO];
        [self.document removeProperty:@"border-width" fromStyle:NO];
        
        [self.document removeProperty:@"border-top" fromStyle:NO];
        [self.document removeProperty:@"border-right" fromStyle:NO];
        [self.document removeProperty:@"border-bottom" fromStyle:NO];
        [self.document removeProperty:@"border-left" fromStyle:NO];
        
        [self.document removeProperty:@"border-top-style" fromStyle:NO];
        [self.document removeProperty:@"border-right-style" fromStyle:NO];
        [self.document removeProperty:@"border-bottom-style" fromStyle:NO];
        [self.document removeProperty:@"border-left-style" fromStyle:NO];
        
        [self.document removeProperty:@"border-top-color" fromStyle:NO];
        [self.document removeProperty:@"border-right-color" fromStyle:NO];
        [self.document removeProperty:@"border-bottom-color" fromStyle:NO];
        [self.document removeProperty:@"border-left-color" fromStyle:NO];
        
        [self.document removeProperty:@"border-top-width" fromStyle:NO];
        [self.document removeProperty:@"border-right-width" fromStyle:NO];
        [self.document removeProperty:@"border-bottom-width" fromStyle:NO];
        [self.document removeProperty:@"border-left-width" fromStyle:NO];
        
        
        NSString *borderValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border" string:style.cssText]];
        
        NSString *borderStyleValue = [self.document valueOfProperty:@"border-style" string:style.cssText];
        NSString *borderColorValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-color" string:style.cssText]];
        NSString *borderWidthValue = [self.document valueOfProperty:@"border-width" string:style.cssText];
        
        NSString *borderTopValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-top" string:style.cssText]];
        NSString *borderRightValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-right" string:style.cssText]];
        NSString *borderBottomValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-bottom" string:style.cssText]];
        NSString *borderLeftValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-left" string:style.cssText]];
        
        NSString *borderTopStyleValue = [self.document valueOfProperty:@"border-top-style" string:style.cssText];
        NSString *borderRightStyleValue = [self.document valueOfProperty:@"border-right-style" string:style.cssText];
        NSString *borderBottomStyleValue = [self.document valueOfProperty:@"border-bottom-style" string:style.cssText];
        NSString *borderLeftStyleValue = [self.document valueOfProperty:@"border-left-style" string:style.cssText];
        
        NSString *borderTopColorValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-top-color" string:style.cssText]];
        NSString *borderRightColorValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-right-color" string:style.cssText]];
        NSString *borderBottomColorValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-bottom-color" string:style.cssText]];
        NSString *borderLeftColorValue = [self.document replaceRGBColorWithHexString:[self.document valueOfProperty:@"border-left-color" string:style.cssText]];
        
        NSString *borderTopWidthValue = [self.document valueOfProperty:@"border-top-width" string:style.cssText];
        NSString *borderRightWidthValue = [self.document valueOfProperty:@"border-right-width" string:style.cssText];
        NSString *borderBottomWidthValue = [self.document valueOfProperty:@"border-bottom-width" string:style.cssText];
        NSString *borderLeftWidthValue = [self.document valueOfProperty:@"border-left-width" string:style.cssText];
        
        if (borderValue) [self.document replaceProperty:@"border" value:borderValue inStyle:NO];
        
        if (borderStyleValue) [self.document replaceProperty:@"border-style" value:borderStyleValue inStyle:NO];
        if (borderColorValue) [self.document replaceProperty:@"border-color" value:borderColorValue inStyle:NO];
        if (borderWidthValue) [self.document replaceProperty:@"border-width" value:borderWidthValue inStyle:NO];
        
        if (borderTopValue) [self.document replaceProperty:@"border-top" value:borderTopValue inStyle:NO];
        if (borderRightValue) [self.document replaceProperty:@"border-right" value:borderRightValue inStyle:NO];
        if (borderBottomValue) [self.document replaceProperty:@"border-bottom" value:borderBottomValue inStyle:NO];
        if (borderLeftValue) [self.document replaceProperty:@"border-left" value:borderLeftValue inStyle:NO];
        
        if (borderTopStyleValue) [self.document replaceProperty:@"border-top-style" value:borderTopStyleValue inStyle:NO];
        if (borderRightStyleValue) [self.document replaceProperty:@"border-right-style" value:borderRightStyleValue inStyle:NO];
        if (borderBottomStyleValue) [self.document replaceProperty:@"border-bottom-style" value:borderBottomStyleValue inStyle:NO];
        if (borderLeftStyleValue) [self.document replaceProperty:@"border-left-style" value:borderLeftStyleValue inStyle:NO];
        
        if (borderTopColorValue) [self.document replaceProperty:@"border-top-color" value:borderTopColorValue inStyle:NO];
        if (borderRightColorValue) [self.document replaceProperty:@"border-right-color" value:borderRightColorValue inStyle:NO];
        if (borderBottomColorValue) [self.document replaceProperty:@"border-bottom-color" value:borderBottomColorValue inStyle:NO];
        if (borderLeftColorValue) [self.document replaceProperty:@"border-left-color" value:borderLeftColorValue inStyle:NO];
        
        if (borderTopWidthValue) [self.document replaceProperty:@"border-top-width" value:borderTopWidthValue inStyle:NO];
        if (borderRightWidthValue) [self.document replaceProperty:@"border-right-width" value:borderRightWidthValue inStyle:NO];
        if (borderBottomWidthValue) [self.document replaceProperty:@"border-bottom-width" value:borderBottomWidthValue inStyle:NO];
        if (borderLeftWidthValue) [self.document replaceProperty:@"border-left-width" value:borderLeftWidthValue inStyle:NO];
        
    }
    
    self.reloadBorderSelection = YES;
    
    [self loadStyleRule:styleRule];
    
    self.reloadBorderSelection = NO;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id sender = [notification object];
    
    if (sender == self.borderThicknessControl) {
        if (self.borderThicknessUnitsControl.indexOfSelectedItem == 0) {
            [self.borderThicknessUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.borderThicknessControl.stringValue.length == 0) {
            [self.borderThicknessUnitsControl selectItemWithTitle:@"unchanged"];
        }
    }
    
    if (sender == self.borderColorTextControl) {
        if (self.borderColorTextControl.stringValue.length == 0) {
            [self.borderColorControl setColor:[NSColor whiteColor]];
        }
    }
    
    [self controlChanged:sender];
}

#pragma mark - Clear Controls

- (void)clearControls {
    [self.borderControl setSelected:YES forSegment:0];
    for (NSInteger i = 1; i < self.borderControl.segmentCount; i++) {
        [self.borderControl setSelected:NO forSegment:i];
    }
    
    self.borderAllField.stringValue = @"";
    self.borderTopField.stringValue = @"";
    self.borderRightField.stringValue = @"";
    self.borderBottomField.stringValue = @"";
    self.borderLeftField.stringValue = @"";
    
    [self.borderStyleControl selectItemWithTitle:@"unchanged"];
    self.borderColorControl.color = [NSColor whiteColor];
    [self.document clearIfNotFirstResponder:self.borderColorTextControl];
    [self.document clearIfNotFirstResponder:self.borderThicknessControl];
    [self.borderThicknessUnitsControl selectItemWithTitle:@"unchanged"];
}

#pragma mark - Load Style

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule {
    DOMCSSStyleDeclaration *style = styleRule.style;
    // Save selected border segment before clearing controls
    NSInteger selectedBorderSegment = self.borderControl.selectedSegment;
    
    [self clearControls];
    
    [self.borderColorTextControl reload];
    
    if (style.borderTopStyle.length > 0 && [style.borderTopStyle isEqualToString:style.borderRightStyle] && [style.borderRightStyle isEqualToString:style.borderBottomStyle] && [style.borderBottomStyle isEqualToString:style.borderLeftStyle]) {
        self.borderAllField.stringValue = @"•";
    } else {
        if (style.borderTopStyle.length > 0) {
            self.borderTopField.stringValue = @"•";
        }
        if (style.borderRightStyle.length) {
            self.borderRightField.stringValue = @"•";
        }
        if (style.borderBottomStyle.length > 0) {
            self.borderBottomField.stringValue = @"•";
        }
        if (style.borderLeftStyle.length > 0 ) {
            self.borderLeftField.stringValue = @"•";
        }
    }
    
    if (style.borderTopColor.length > 0 && [style.borderTopColor isEqualToString:style.borderRightColor] && [style.borderRightColor isEqualToString:style.borderBottomColor] && [style.borderBottomColor isEqualToString:style.borderLeftColor]) {
        self.borderAllField.stringValue = @"•";
    } else {
        if (style.borderTopColor.length > 0) {
            self.borderTopField.stringValue = @"•";
        }
        if (style.borderRightColor.length) {
            self.borderRightField.stringValue = @"•";
        }
        if (style.borderBottomColor.length > 0) {
            self.borderBottomField.stringValue = @"•";
        }
        if (style.borderLeftColor.length > 0 ) {
            self.borderLeftField.stringValue = @"•";
        }
    }
    
    if (style.borderTopWidth.length > 0 && [style.borderTopWidth isEqualToString:style.borderRightWidth] && [style.borderRightWidth isEqualToString:style.borderBottomWidth] && [style.borderBottomWidth isEqualToString:style.borderLeftWidth]) {
        self.borderAllField.stringValue = @"•";
    } else {
        if (style.borderTopWidth.length > 0) {
            self.borderTopField.stringValue = @"•";
        }
        if (style.borderRightWidth.length) {
            self.borderRightField.stringValue = @"•";
        }
        if (style.borderBottomWidth.length > 0) {
            self.borderBottomField.stringValue = @"•";
        }
        if (style.borderLeftWidth.length > 0 ) {
            self.borderLeftField.stringValue = @"•";
        }
    }
    
    if (self.reloadBorderSelection) {
        // Reload border selection after loading the style
        [self.borderControl setSelectedSegment:selectedBorderSegment];
    }
    
    NSString *borderStyle = @"";
    NSString *borderColor = @"";
    NSString *borderWidth = @"";
    if (self.borderControl.selectedSegment == 0 && self.borderAllField.stringValue.length > 0) {
        borderStyle = style.borderStyle;
        borderColor = style.borderColor;
        borderWidth = style.borderWidth;
    } else if (self.borderControl.selectedSegment == 1 && self.borderTopField.stringValue.length > 0) {
        borderStyle = style.borderTopStyle;
        borderColor = style.borderTopColor;
        borderWidth = style.borderTopWidth;
    } else if (self.borderControl.selectedSegment == 2 && self.borderRightField.stringValue.length > 0) {
        borderStyle = style.borderRightStyle;
        borderColor = style.borderRightColor;
        borderWidth = style.borderRightWidth;
    } else if (self.borderControl.selectedSegment == 3 && self.borderBottomField.stringValue.length > 0) {
        borderStyle = style.borderBottomStyle;
        borderColor = style.borderBottomColor;
        borderWidth = style.borderBottomWidth;
    } else if (self.borderControl.selectedSegment == 4 && self.borderLeftField.stringValue.length > 0) {
        borderStyle = style.borderLeftStyle;
        borderColor = style.borderLeftColor;
        borderWidth = style.borderLeftWidth;
    }
    
    BOOL isStyleCombined = [style.borderTopStyle isEqualToString:style.borderRightStyle] && [style.borderRightStyle isEqualToString:style.borderBottomStyle] && [style.borderBottomStyle isEqualToString:style.borderLeftStyle];
    if (borderStyle.length > 0 && ((self.borderControl.selectedSegment == 0 && isStyleCombined) || (self.borderControl.selectedSegment != 0 && !isStyleCombined))) {
        NSArray *itemTitles = [self.borderStyleControl.itemTitles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        if ([itemTitles containsObject:borderStyle]) {
            [self.borderStyleControl selectItemWithTitle:borderStyle];
        }
    } else {
        [self.borderStyleControl selectItemWithTitle:@"unchanged"];
    }
    
    BOOL isColorCombined = [style.borderTopColor isEqualToString:style.borderRightColor] && [style.borderRightColor isEqualToString:style.borderBottomColor] && [style.borderBottomColor isEqualToString:style.borderLeftColor];
    if (borderColor.length > 0 && ((self.borderControl.selectedSegment == 0 && isColorCombined) || (self.borderControl.selectedSegment != 0 && !isColorCombined))) {
        NSColor *color = [NSColor colorWithCSS:borderColor];
        if (color) {
            self.borderColorControl.color = color;
            self.borderColorTextControl.stringValue = color.rgbStringValue;
        }
    } else {
        self.borderColorControl.color = [NSColor whiteColor];
        self.borderColorTextControl.stringValue = @"";
    }
    
    BOOL isWidthCombined = [style.borderTopWidth isEqualToString:style.borderRightWidth] && [style.borderRightWidth isEqualToString:style.borderBottomWidth] && [style.borderBottomWidth isEqualToString:style.borderLeftWidth];
    if (borderWidth.length > 0 && ((self.borderControl.selectedSegment == 0 && isWidthCombined) || (self.borderControl.selectedSegment != 0 && !isWidthCombined))) {
        [self.document loadValue:borderWidth textControl:self.borderThicknessControl unitsControl:self.borderThicknessUnitsControl];
    } else {
        self.borderThicknessControl.stringValue = @"";
        [self.borderThicknessUnitsControl selectItemWithTitle:@"unchanged"];
    }
    
}

@end
