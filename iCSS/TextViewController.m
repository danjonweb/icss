//
//  TextViewController.m
//  iCSS
//
//  Created by Daniel Weber on 7/3/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "TextViewController.h"
#import "Document.h"
#import "NSColor+HTMLColors.h"
#import "ColorTextField.h"
#import <WebKit/WebKit.h>

@interface TextViewController ()
@property (nonatomic) BOOL reloadTextShadowSelection;
@property (nonatomic, strong) NSMutableArray *textShadows;
@end

@implementation TextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.textShadows = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Control Changed

- (IBAction)controlChanged:(id)sender {
    DOMCSSStyleRule *styleRule = [self.document currentStyleRule];
    
    
    self.reloadTextShadowSelection = YES;
    [self loadStyleRule:styleRule];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id sender = [notification object];
    
    
    
    [self controlChanged:sender];
}

#pragma mark - Clear Controls

- (void)clearControls {
    [self.textAlignControl setSelected:NO forSegment:0];
    [self.textAlignControl setSelected:NO forSegment:1];
    [self.textAlignControl setSelected:NO forSegment:2];
    [self.textAlignControl setSelected:NO forSegment:3];
    [self.document clearIfNotFirstResponder:self.textIndentControl];
    [self.textIndentUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.letterSpacingControl];
    [self.letterSpacingUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.wordSpacingControl];
    [self.wordSpacingUnitsControl selectItemWithTitle:@"unchanged"];
    [self.whiteSpaceControl selectItemWithTitle:@"unchanged"];
    [self.textShadowControl removeAllItems];
    [self resetTextShadow];
}

- (void)resetTextShadow {
    // Called when loading style or when new text shadow is selected from popup
    [self.document clearIfNotFirstResponder:self.textShadowXControl];
    [self.textShadowXUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.textShadowYControl];
    [self.textShadowYUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.textShadowBlurControl];
    [self.textShadowBlurUnitsControl selectItemWithTitle:@"unchanged"];
    [self.textShadowColorControl setColor:[NSColor whiteColor]];
    [self.document clearIfNotFirstResponder:self.textShadowColorTextControl];
}

#pragma mark - Load Style

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule {
    DOMCSSStyleDeclaration *style = styleRule.style;
    NSInteger selectedTextShadowIndex = self.textShadowControl.indexOfSelectedItem;
    
    // Load recent colors
    [self.textShadowColorTextControl reload];
    
    [self clearControls];
    
    if (style.textAlign.length > 0) {
        if ([style.textAlign isEqualToString:@"left"]) {
            [self.textAlignControl setSelectedSegment:0];
        } else if ([style.textAlign isEqualToString:@"center"]) {
            [self.textAlignControl setSelectedSegment:1];
        } else if ([style.textAlign isEqualToString:@"right"]) {
            [self.textAlignControl setSelectedSegment:2];
        } else if ([style.textAlign isEqualToString:@"justify"]) {
            [self.textAlignControl setSelectedSegment:3];
        }
    }
    
    if (style.textIndent.length > 0) {
        [self.document loadValue:style.textIndent textControl:self.textIndentControl unitsControl:self.textIndentUnitsControl];
    }
    
    if (style.letterSpacing.length > 0) {
        [self.document loadValue:style.letterSpacing textControl:self.letterSpacingControl unitsControl:self.letterSpacingUnitsControl];
    }
    
    if (style.wordSpacing.length > 0) {
        [self.document loadValue:style.wordSpacing textControl:self.wordSpacingControl unitsControl:self.wordSpacingUnitsControl];
    }
    
    if (style.whiteSpace.length > 0) {
        if ([style.whiteSpace isEqualToString:@"initial"]) {
            [self.whiteSpaceControl selectItemWithTitle:@"initial"];
        } else if ([style.whiteSpace isEqualToString:@"inherit"]) {
            [self.whiteSpaceControl selectItemWithTitle:@"inherit"];
        } else if ([style.whiteSpace isEqualToString:@"normal"]) {
            [self.whiteSpaceControl selectItemWithTitle:@"normal"];
        } else if ([style.whiteSpace isEqualToString:@"nowrap"]) {
            [self.whiteSpaceControl selectItemWithTitle:@"nowrap"];
        } else if ([style.whiteSpace isEqualToString:@"pre"]) {
            [self.whiteSpaceControl selectItemWithTitle:@"pre"];
        } else if ([style.whiteSpace isEqualToString:@"pre-wrap"]) {
            [self.whiteSpaceControl selectItemWithTitle:@"pre-wrap"];
        } else if ([style.whiteSpace isEqualToString:@"pre-line"]) {
            [self.whiteSpaceControl selectItemWithTitle:@"pre-line"];
        }
    }
    
    if (style.textShadow.length > 0) {
        [self.textShadows removeAllObjects];
        [self.textShadows addObjectsFromArray:[self parseTextShadow:style.textShadow]];
        for (NSString *textShadow in self.textShadows) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:textShadow action:nil keyEquivalent:@""];
            [self.textShadowControl.menu addItem:item];
        }
        
        if (self.reloadTextShadowSelection) {
            // Reload text shadow selection after loading the style
            [self.textShadowControl selectItemAtIndex:selectedTextShadowIndex];
            self.reloadTextShadowSelection = NO;
        } else {
            [self.textShadowControl selectItemAtIndex:0];
        }
        
        [self loadSelectedTextShadow];
    }
}

- (void)loadSelectedTextShadow {
    if (self.textShadowControl.indexOfSelectedItem == -1)
        return;
    
    NSString *s = self.textShadows[self.textShadowControl.indexOfSelectedItem];
    NSMutableArray *textShadowTokens = [NSMutableArray array];
    NSMutableArray *openExpr = [NSMutableArray array];
    NSInteger start = 0;
    for (NSInteger i = 0; i < s.length; i++) {
        unichar c = [s characterAtIndex:i];
        if (c == '(') {
            [openExpr addObject:@(i)];
        } else if (c == ')') {
            [openExpr removeLastObject];
        } else if (c == '"') {
            do {
                if (i + 1 < s.length) i++; else break;
            } while (!([s characterAtIndex:i] == '"'));
        } else if (c == '\'') {
            do {
                if (i+1 < s.length) i++; else break;
            } while (!([s characterAtIndex:i] == '\''));
        } else if (c == '/' && i+1 < s.length && [s characterAtIndex:i+1] == '*') {
            do {
                if (i+1 < s.length) i++; else break;
            } while (!([s characterAtIndex:i] == '*' && i+1 < s.length && [s characterAtIndex:i+1] == '/'));
        }
        if ((c == ' ' && openExpr.count == 0) || i == s.length-1) {
            NSInteger end = i == s.length-1 ? i+1 : i;
            NSString *chunk = [s substringWithRange:NSMakeRange(start, end-start)];
            [textShadowTokens addObject:chunk];
            start = i+1;
        }
    }
    
    NSColor *color;
    NSString *offsetX;
    NSString *offsetY;
    NSString *blurRadius;
    NSArray *unitsArray = @[@"rem", @"em", @"ex", @"ch", @"vw", @"vh", @"vmin", @"vmax", @"cm", @"mm", @"in", @"px", @"pt", @"pc"];
    
    if (textShadowTokens.count == 2) {
        offsetX = textShadowTokens[0];
        offsetY = textShadowTokens[1];
    } else if (textShadowTokens.count == 3) {
        BOOL isLength = NO;
        if ([textShadowTokens[0] isEqualToString:@"0"]) {
            isLength = YES;
        }
        for (NSString *units in unitsArray) {
            if ([textShadowTokens[0] hasSuffix:units]) {
                isLength = YES;
                break;
            }
        }
        if (isLength) {
            offsetX = textShadowTokens[0];
            offsetY = textShadowTokens[1];
            blurRadius = textShadowTokens[2];
        } else {
            NSString *colorString = textShadowTokens[0];
            color = [NSColor colorWithCSS:colorString];
            offsetX = textShadowTokens[1];
            offsetY = textShadowTokens[2];
        }
    } else if (textShadowTokens.count == 4) {
        NSString *colorString = textShadowTokens[0];
        color = [NSColor colorWithCSS:colorString];
        offsetX = textShadowTokens[1];
        offsetY = textShadowTokens[2];
        blurRadius = textShadowTokens[3];
    }
    
    if (color) {
        self.textShadowColorControl.color = color;
        [self.document setIfNotFirstResponder:self.textShadowColorTextControl string:color.rgbStringValue];
    }
    if (offsetX) {
        [self.document loadValue:offsetX textControl:self.textShadowXControl unitsControl:self.textShadowXUnitsControl];
    }
    if (offsetY) {
        [self.document loadValue:offsetY textControl:self.textShadowYControl unitsControl:self.textShadowYUnitsControl];
    }
    if (blurRadius) {
        [self.document loadValue:blurRadius textControl:self.textShadowBlurControl unitsControl:self.textShadowBlurUnitsControl];
    }
}

#pragma mark - Parsing

- (NSMutableArray *)parseTextShadow:(NSString *)s {
    NSMutableArray *textShadows = [NSMutableArray array];
    NSMutableArray *openExpr = [NSMutableArray array];
    NSInteger start = 0;
    for (NSInteger i = 0; i < s.length; i++) {
        unichar c = [s characterAtIndex:i];
        if (c == '(') {
            [openExpr addObject:@(i)];
        } else if (c == ')') {
            [openExpr removeLastObject];
        } else if (c == '"') {
            do {
                if (i + 1 < s.length) i++; else break;
            } while (!([s characterAtIndex:i] == '"'));
        } else if (c == '\'') {
            do {
                if (i+1 < s.length) i++; else break;
            } while (!([s characterAtIndex:i] == '\''));
        } else if (c == '/' && i+1 < s.length && [s characterAtIndex:i+1] == '*') {
            do {
                if (i+1 < s.length) i++; else break;
            } while (!([s characterAtIndex:i] == '*' && i+1 < s.length && [s characterAtIndex:i+1] == '/'));
        }
        if ((c == ',' && openExpr.count == 0) || i == s.length-1) {
            NSInteger end = i == s.length-1 ? i+1 : i;
            NSString *textShadow = [s substringWithRange:NSMakeRange(start, end-start)];
            textShadow = [textShadow stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [textShadows addObject:textShadow];
            start = i+1;
        }
    }
    return textShadows;
}

@end
