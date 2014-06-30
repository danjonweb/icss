//
//  BackgroundViewController.m
//  iCSS
//
//  Created by Daniel Weber on 6/29/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "BackgroundViewController.h"
#import "NSColor+HTMLColors.h"
#import "ColorTextField.h"
#import "Document.h"
#import "RegexKitLite.h"
#import <WebKit/WebKit.h>

@interface BackgroundViewController ()
@property (nonatomic) BOOL reloadBackgroundSelection;
@property (nonatomic, strong) NSMutableArray *backgrounds;
@end

@implementation BackgroundViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - Control Changed

- (void)saveColor {
    NSArray *recentColors = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentColors"];
    NSMutableArray *newRecentColors = [NSMutableArray array];
    if (recentColors) {
        [newRecentColors addObjectsFromArray:recentColors];
    }
    [newRecentColors addObject:self.bgColorControl.color.formattedString];
    if (newRecentColors.count > 5) {
        [newRecentColors removeObjectAtIndex:0];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newRecentColors forKey:@"recentColors"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.bgColorTextControl reload];
}

- (IBAction)controlChanged:(id)sender {
    DOMCSSStyleRule *styleRule = [self.document currentStyleRule];
    DOMCSSStyleDeclaration *style = styleRule.style;
    
    if (sender == self.bgColorControl) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(saveColor) withObject:nil afterDelay:5.0];
        //[self.document replaceProperty:@"background-color" value:self.bgColorControl.color.formattedString inStyle:YES];
    }
    if (sender == self.bgColorTextControl) {
        if (self.bgColorTextControl.stringValue.length == 0) {
            [self.document removeProperty:@"background-color" fromStyle:YES];
        } else {
            NSColor *color = [NSColor colorWithCSS:self.bgColorTextControl.stringValue];
            if (color) {
                //[self.document replaceProperty:@"background-color" value:color.formattedString inStyle:YES];
                self.bgColorControl.color = color;
            } else {
                return;
            }
        }
    }
    
    if (sender == self.bgImageAddAndRemoveButtons) {
        [self.bgImageURLControl.window makeFirstResponder:nil];
        NSInteger selectedSegment = self.bgImageAddAndRemoveButtons.selectedSegment;
        if (selectedSegment == 1) {
            // Remove background image
            if (self.bgImageControl.indexOfSelectedItem == -1 || self.bgImageControl.indexOfSelectedItem >= self.backgrounds.count)
                return;
            [self.backgrounds removeObjectAtIndex:self.bgImageControl.indexOfSelectedItem];
        } else if (selectedSegment == 0) {
            // Add a new background image
            [NSMenu popUpContextMenu:self.bgAddImageMenu withEvent:[[NSApplication sharedApplication] currentEvent] forView:self.bgImageAddAndRemoveButtons];
            // Wait to be called by menu item to reload style
            return;
        }
    }
    if (sender == self.bgAddImageMenuItem) {
        NSMutableDictionary *bgDict = [NSMutableDictionary dictionary];
        bgDict[@"image"] = @"url(background.png)";
        [self.backgrounds addObject:bgDict];
    } else if (sender == self.bgAddLinearGradientMenuItem) {
        NSMutableDictionary *bgDict = [NSMutableDictionary dictionary];
        bgDict[@"image"] = @"linear-gradient(green, yellow)";
        [self.backgrounds addObject:bgDict];
    } else if (sender == self.bgAddRadialGradientMenuItem) {
        NSMutableDictionary *bgDict = [NSMutableDictionary dictionary];
        bgDict[@"image"] = @"radial-gradient(blue, orange)";
        [self.backgrounds addObject:bgDict];
    }
    
    [self.document removeProperty:@"background" fromStyle:YES];
    [self.document removeProperty:@"background-image" fromStyle:YES];
    [self.document removeProperty:@"background-position" fromStyle:YES];
    [self.document removeProperty:@"background-size" fromStyle:YES];
    [self.document removeProperty:@"background-repeat" fromStyle:YES];
    [self.document removeProperty:@"background-attachment" fromStyle:YES];
    [self.document removeProperty:@"background-color" fromStyle:YES];
    
    NSMutableString *backgrounds = [NSMutableString string];
    for (NSDictionary *bgDict in self.backgrounds) {
        NSMutableString *bg = [NSMutableString string];
        if (bgDict[@"image"]) {
            [bg appendString:bgDict[@"image"]];
        }
        if (bgDict[@"position"]) {
            NSArray *array = bgDict[@"position"];
            for (NSString *x in array) {
                [bg appendFormat:@" %@", x];
            }
        }
        if (bgDict[@"size"]) {
            [bg appendString:@" /"];
            NSArray *array = bgDict[@"size"];
            for (NSString *x in array) {
                [bg appendFormat:@" %@", x];
            }
        }
        if (bgDict[@"repeat"]) {
            NSArray *array = bgDict[@"repeat"];
            for (NSString *x in array) {
                [bg appendFormat:@" %@", x];
            }
        }
        if (bgDict[@"attachment"]) {
            [bg appendFormat:@" %@", bgDict[@"attachment"]];
        }
        bg = [bg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].mutableCopy;
        [bg appendString:@", "];
        [backgrounds appendString:bg];
    }
    backgrounds = [backgrounds stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]].mutableCopy;
    if (self.bgColorTextControl.stringValue.length > 0) {
        [backgrounds appendFormat:@" %@", self.bgColorTextControl.stringValue.formattedString];
    }
    
    [self.document replaceProperty:@"background" value:backgrounds inStyle:YES];
    
    
    self.reloadBackgroundSelection = YES;
    
    [self loadStyleRule:styleRule];
    
    self.reloadBackgroundSelection = NO;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id sender = [notification object];
    
    if (sender == self.bgColorTextControl) {
        if (self.bgColorTextControl.stringValue.length == 0) {
            [self.bgColorControl setColor:[NSColor whiteColor]];
        }
    }
    if (sender == self.bgImageDirectionControl) {
        if (self.bgImageDirectionUnitsControl.indexOfSelectedItem < 11) {
            [self.bgImageDirectionUnitsControl selectItemWithTitle:@"deg"];
        }
        if (self.bgImageDirectionControl.stringValue.length == 0) {
            [self.bgImageDirectionUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.bgImagePositionXControl) {
        if (self.bgImagePositionYControl.stringValue.length == 0) {
            self.bgImagePositionYControl.stringValue = @"50";
            [self.bgImagePositionYUnitsControl selectItemWithTitle:@"%"];
        }
        if (self.bgImagePositionXUnitsControl.indexOfSelectedItem == 0) {
            [self.bgImagePositionXUnitsControl selectItemWithTitle:@"%"];
        }
        if (self.bgImagePositionXControl.stringValue.length == 0) {
            [self.bgImagePositionXUnitsControl selectItemWithTitle:@"unchanged"];
            self.bgImagePositionYControl.stringValue = @"";
            [self.bgImagePositionYUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.bgImagePositionYControl) {
        if (self.bgImagePositionXControl.stringValue.length == 0) {
            self.bgImagePositionXControl.stringValue = @"50";
            [self.bgImagePositionXUnitsControl selectItemWithTitle:@"%"];
        }
        if (self.bgImagePositionYUnitsControl.indexOfSelectedItem == 0) {
            [self.bgImagePositionYUnitsControl selectItemWithTitle:@"%"];
        }
        if (self.bgImagePositionYControl.stringValue.length == 0) {
            [self.bgImagePositionYUnitsControl selectItemWithTitle:@"unchanged"];
            self.bgImagePositionXControl.stringValue = @"";
            [self.bgImagePositionXUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.bgImageSizeXControl) {
        if (self.bgImageSizeXUnitsControl.indexOfSelectedItem == 0) {
            [self.bgImageSizeXUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.bgImageSizeXControl.stringValue.length == 0) {
            [self.bgImageSizeXUnitsControl selectItemWithTitle:@"unchanged"];
        } else {
            [self.bgImageExtentControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.bgImageSizeYControl) {
        if (self.bgImageSizeXControl.stringValue.length == 0) {
            self.bgImageSizeXControl.stringValue = @"0";
            [self.bgImageSizeXUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.bgImageSizeYUnitsControl.indexOfSelectedItem == 0) {
            [self.bgImageSizeYUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.bgImageSizeYControl.stringValue.length == 0) {
            [self.bgImageSizeYUnitsControl selectItemWithTitle:@"unchanged"];
        } else {
            [self.bgImageExtentControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.bgPositionXControl) {
        // Follows the same logic as background image control above
        if (self.bgPositionYControl.stringValue.length == 0) {
            self.bgPositionYControl.stringValue = @"50";
            [self.bgPositionYUnitsControl selectItemWithTitle:@"%"];
        }
        if (self.bgPositionXUnitsControl.indexOfSelectedItem == 0) {
            [self.bgPositionXUnitsControl selectItemWithTitle:@"%"];
        }
        if (self.bgPositionXControl.stringValue.length == 0) {
            [self.bgPositionXUnitsControl selectItemWithTitle:@"unchanged"];
            self.bgPositionYControl.stringValue = @"";
            [self.bgPositionYUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.bgPositionYControl) {
        // If x pos is empty, set it 50%
        if (self.bgPositionXControl.stringValue.length == 0) {
            self.bgPositionXControl.stringValue = @"50";
            [self.bgPositionXUnitsControl selectItemWithTitle:@"%"];
        }
        // If y units is "unchanged", set it %
        if (self.bgPositionYUnitsControl.indexOfSelectedItem == 0) {
            [self.bgPositionYUnitsControl selectItemWithTitle:@"%"];
        }
        // If y pos is empty, set it default 50%
        if (self.bgPositionYControl.stringValue.length == 0) {
            self.bgPositionYControl.stringValue = @"50";
            [self.bgPositionYUnitsControl selectItemWithTitle:@"%"];
        }
    }
    
    [self controlChanged:sender];
}

#pragma mark - Clear Controls

- (void)clearControls {
    [self.bgColorControl setColor:[NSColor whiteColor]];
    [self.document clearIfNotFirstResponder:self.bgColorTextControl];
    
    [self.bgImageControl removeAllItems];
    [self resetBackgroundImage];
    
    [self.document clearIfNotFirstResponder:self.bgPositionXControl];
    [self.bgPositionXUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.bgPositionYControl];
    [self.bgPositionYUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.bgWidthControl];
    [self.bgWidthUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.bgHeightControl];
    [self.bgHeightUnitsControl selectItemWithTitle:@"unchanged"];
    [self.bgRepeatControl setSelected:NO forSegment:0];
    [self.bgRepeatControl setSelected:NO forSegment:1];
    [self.bgRepeatControl setSelected:NO forSegment:2];
    [self.bgRepeatControl setSelected:NO forSegment:3];
    [self.bgAttachmentControl setSelected:NO forSegment:0];
    [self.bgAttachmentControl setSelected:NO forSegment:1];
}

- (void)resetBackgroundImage {
    [self.document clearIfNotFirstResponder:self.bgImageURLControl];
    [self.bgImageGradientEditor setGradient:[[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor whiteColor]]];
    [self.document clearIfNotFirstResponder:self.bgImageDirectionControl];
    [self.bgImageDirectionUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.bgImagePositionXControl];
    [self.bgImagePositionXUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.bgImagePositionYControl];
    [self.bgImagePositionYUnitsControl selectItemWithTitle:@"unchanged"];
    [self.bgImageShapeControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.bgImageSizeXControl];
    [self.bgImageSizeXUnitsControl selectItemWithTitle:@"unchanged"];
    [self.document clearIfNotFirstResponder:self.bgImageSizeYControl];
    [self.bgImageSizeYUnitsControl selectItemWithTitle:@"unchanged"];
    [self.bgImageExtentControl selectItemWithTitle:@"unchanged"];
    
    [self.document disableIfNotFirstResponder:self.bgImageURLControl];
    [self.bgImageURLLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self.bgImageGradientEditor setEditable:NO];
    [self.bgImageGradientLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self.document disableIfNotFirstResponder:self.bgImageDirectionControl];
    [self.bgImageDirectionUnitsControl setEnabled:NO];
    [self.bgImageDirectionLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self.document disableIfNotFirstResponder:self.bgImagePositionXControl];
    [self.bgImagePositionXUnitsControl setEnabled:NO];
    [self.bgImagePositionXLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self.document disableIfNotFirstResponder:self.bgImagePositionYControl];
    [self.bgImagePositionYUnitsControl setEnabled:NO];
    [self.bgImagePositionYLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self.bgImageShapeControl setEnabled:NO];
    [self.bgImageShapeLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self.document disableIfNotFirstResponder:self.bgImageSizeXControl];
    [self.bgImageSizeXUnitsControl setEnabled:NO];
    [self.bgImageSizeXLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self.document disableIfNotFirstResponder:self.bgImageSizeYControl];
    [self.bgImageSizeYUnitsControl setEnabled:NO];
    [self.bgImageSizeYLabel setTextColor:[NSColor disabledControlTextColor]];
    
    [self.bgImageExtentControl setEnabled:NO];
    [self.bgImageExtentLabel setTextColor:[NSColor disabledControlTextColor]];
}

#pragma mark - Load Style

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule {
    DOMCSSStyleDeclaration *style = styleRule.style;
    
    NSInteger selectedBackgroundImageIndex = self.bgImageControl.indexOfSelectedItem;
    
    [self clearControls];
    
    // Load recent colors
    [self.bgColorTextControl reload];
    
    // Load background color
    if (style.backgroundColor.length > 0) {
        NSColor *color = [NSColor colorWithCSS:style.backgroundColor];
        if (color) {
            self.bgColorControl.color = color;
            self.bgColorTextControl.stringValue = color.rgbStringValue;
        }
    }
    
    if (![style.background isEqualToString:style.backgroundColor]) {
        // Divide up the background property into individual backgrounds
        NSArray *backgroundArray = [self parseBackgrounds:style.background];
        
        // Parse each background into image, position, size, repeat, and attachment
        self.backgrounds = [NSMutableArray array];
        for (NSString *background in backgroundArray) {
            NSDictionary *bgDict = [self parseBackground:background];
            [self.backgrounds addObject:bgDict];
        }
        
        // Populate image popup menu
        for (NSDictionary *bgDict in self.backgrounds) {
            NSMutableString *space = [NSMutableString stringWithString:@""];
            if (bgDict[@"image"]) {
                [self.bgImageControl addItemWithTitle:bgDict[@"image"]];
                if ([bgDict[@"image"] hasPrefix:@"url"]) {
                    [self.bgImageControl.lastItem setImage:[NSImage imageNamed:@"image"]];
                } else if ([bgDict[@"image"] hasPrefix:@"linear"]) {
                    [self.bgImageControl.lastItem setImage:[NSImage imageNamed:@"gradientLinear"]];
                } else if ([bgDict[@"image"] hasPrefix:@"radial"]) {
                    [self.bgImageControl.lastItem setImage:[NSImage imageNamed:@"gradientRadial"]];
                }
            } else {
                [self.bgImageControl addItemWithTitle:[NSString stringWithFormat:@"(no image)%@", space]];
                [space appendString:@" "];
            }
        }
        
        if (self.reloadBackgroundSelection) {
            // Reload background selection after loading the style
            [self.bgImageControl selectItemAtIndex:selectedBackgroundImageIndex];
        }
        
        if (self.bgImageControl.indexOfSelectedItem != -1) {
            NSDictionary *bgDict = self.backgrounds[self.bgImageControl.indexOfSelectedItem];
            NSLog(@"%@", bgDict);
            
            // Load the background image -- either a url or gradient
            NSString *backgroundImage = bgDict[@"image"];
            [self enableOrDisableControlsForBackgroundImage:backgroundImage];
            if ([backgroundImage hasPrefix:@"url"]) {
                self.bgImageURLControl.stringValue = [backgroundImage substringWithRange:NSMakeRange(4, backgroundImage.length - 5)];
            } else if ([backgroundImage hasPrefix:@"linear-gradient"] || [backgroundImage hasPrefix:@"radial-gradient"]) {
                [self loadGradient:backgroundImage];
            }
            
            // Load the position, size, repeat, and attachment
            if (bgDict[@"position"]) {
                NSArray *position = bgDict[@"position"];
                [self.document loadValue:position[0] textControl:self.bgPositionXControl unitsControl:self.bgPositionXUnitsControl keywords:@[]];
                [self.document loadValue:position[1] textControl:self.bgPositionYControl unitsControl:self.bgPositionYUnitsControl keywords:@[]];
            }
            
            if (bgDict[@"size"]) {
                NSArray *size = bgDict[@"size"];
                if (size.count == 1) {
                    [self.document loadValue:size[0] textControl:self.bgWidthControl unitsControl:self.bgWidthUnitsControl keywords:@[@"auto", @"cover", @"contain"]];
                    [self.document loadValue:size[0] textControl:self.bgHeightControl unitsControl:self.bgHeightUnitsControl keywords:@[@"auto", @"cover", @"contain"]];
                } else if (size.count == 2) {
                    [self.document loadValue:size[0] textControl:self.bgWidthControl unitsControl:self.bgWidthUnitsControl keywords:@[@"auto", @"cover", @"contain"]];
                    [self.document loadValue:size[1] textControl:self.bgHeightControl unitsControl:self.bgHeightUnitsControl keywords:@[@"auto", @"cover", @"contain"]];
                }
            }
            
            if (bgDict[@"repeat"]) {
                NSArray *repeatArray = bgDict[@"repeat"];
                NSString *repeat = repeatArray[0];
                if ([repeat isEqualToString:@"repeat"]) {
                    [self.bgRepeatControl setSelectedSegment:0];
                } else if ([repeat isEqualToString:@"repeat-y"]) {
                    [self.bgRepeatControl setSelectedSegment:1];
                } else if ([repeat isEqualToString:@"repeat-x"]) {
                    [self.bgRepeatControl setSelectedSegment:2];
                } else if ([repeat isEqualToString:@"no-repeat"]) {
                    [self.bgRepeatControl setSelectedSegment:3];
                }
            }
            
            if (bgDict[@"attachment"]) {
                NSString *attachment = bgDict[@"attachment"];
                if ([attachment isEqualToString:@"scroll"]) {
                    [self.bgAttachmentControl setSelectedSegment:0];
                } else if ([attachment isEqualToString:@"fixed"]) {
                    [self.bgAttachmentControl setSelectedSegment:1];
                }
            }
            
        }
    }
    
}

#pragma mark - ACTGradientDelegate Methods

- (void)gradientDidChange:(ACTGradientEditor *)gradientEditor {
    [self controlChanged:self.bgImageGradientEditor];
}

#pragma mark - Utilities

- (NSMutableArray *)parseBackgrounds:(NSString *)s {
    NSMutableArray *backgrounds = [NSMutableArray array];
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
            NSString *background = [s substringWithRange:NSMakeRange(start, end-start)];
            background = [background stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            background = [background stringByReplacingOccurrencesOfRegex:@"applewebdata:\\/\\/[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}\\/" withString:@""];
            [backgrounds addObject:background];
            start = i+1;
        }
    }
    return backgrounds;
}

- (NSMutableDictionary *)parseBackground:(NSString *)s {
    NSMutableDictionary *bgDict = [NSMutableDictionary dictionary];
    NSMutableArray *openExpr = [NSMutableArray array];
    NSInteger start = 0;
    BOOL isSize = NO;
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
            start = i+1;
            if ([chunk isEqualToString:@"/"]) {
                isSize = YES;
            }
            if ([chunk hasPrefix:@"url"]) {
                bgDict[@"image"] = chunk;
            } else if ([chunk hasPrefix:@"linear-gradient"]) {
                bgDict[@"image"] = chunk;
            } else if ([chunk hasPrefix:@"radial-gradient"]) {
                bgDict[@"image"] = chunk;
            }
            NSArray *repeats = @[@"repeat-x", @"repeat-y", @"repeat", @"space", @"round", @"no-repeat"];
            if ([repeats containsObject:chunk]) {
                NSMutableArray *repeat = bgDict[@"repeat"];
                if (!repeat) {
                    repeat = [NSMutableArray array];
                }
                [repeat addObject:chunk];
                bgDict[@"repeat"] = repeat;
            }
            NSArray *attachments = @[@"scroll", @"fixed", @"local"];
            if ([attachments containsObject:chunk]) {
                bgDict[@"attachment"] = chunk;
            }
            
            NSArray *unitsArray = @[@"rem", @"em", @"ex", @"ch", @"vw", @"vh", @"vmin", @"vmax", @"cm", @"mm", @"in", @"px", @"pt", @"pc", @"%"];
            for (NSString *units in unitsArray) {
                if ([chunk hasSuffix:units]) {
                    if (!isSize) {
                        // Slash not encountered yet, this is a position
                        NSMutableArray *position = bgDict[@"position"];
                        if (!position) {
                            position = [NSMutableArray array];
                        }
                        [position addObject:chunk];
                        bgDict[@"position"] = position;
                    } else {
                        NSMutableArray *size = bgDict[@"size"];
                        if (!size) {
                            size = [NSMutableArray array];
                        }
                        [size addObject:chunk];
                        bgDict[@"size"] = size;
                    }
                    break;
                }
            }
            
            NSArray *size = @[@"auto", @"cover", @"contain"];
            if ([size containsObject:chunk]) {
                NSMutableArray *size = bgDict[@"size"];
                if (!size) {
                    size = [NSMutableArray array];
                }
                [size addObject:chunk];
                bgDict[@"size"] = size;
            }
        }
    }
    
    return bgDict;
}

- (void)loadGradient:(NSString *)string {
    NSMutableArray *colors = [NSMutableArray array];
    NSMutableArray *colorStops = [NSMutableArray array];
    NSMutableArray *openExpr = [NSMutableArray array];
    NSInteger start = 0;
    for (NSInteger i = 0; i < string.length; i++) {
        unichar c = [string characterAtIndex:i];
        if (c == '(') {
            // We use the start var to extract chunks within a gradient expression. The first one will come right after the open parens.
            if (openExpr.count == 0 && i+1 < string.length) {
                start = i+1;
            }
            [openExpr addObject:@(i)];
        } else if (c == ')') {
            [openExpr removeLastObject];
        } else if (c == '"') {
            // Skip quotes
            do {
                if (i + 1 < string.length) i++; else break;
            } while (!([string characterAtIndex:i] == '"'));
        } else if (c == '\'') {
            // Skip single quotes
            do {
                if (i+1 < string.length) i++; else break;
            } while (!([string characterAtIndex:i] == '\''));
        } else if (c == '/' && i+1 < string.length && [string characterAtIndex:i+1] == '*') {
            // Skip comments
            do {
                if (i+1 < string.length) i++; else break;
            } while (!([string characterAtIndex:i] == '*' && i+1 < string.length && [string characterAtIndex:i+1] == '/'));
        }
        if ((c == ',' && openExpr.count == 1) || i == string.length-1) {
            // We are inside a gradient expression. We just got to "," and need to extract the chunk.
            NSInteger end = i;
            NSString *chunk = [string substringWithRange:NSMakeRange(start, end-start)];
            chunk = [chunk stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // Check if the chunk is a color: either a hex string, rgb(a) string, hsl(a) string, "transparent", or a named color.
            BOOL isColor = NO;
            NSString *color = @"";
            NSString *colorStop;
            if ([chunk hasPrefix:@"#"]) {
                color = chunk;
                isColor = YES;
            } else if ([chunk hasPrefix:@"rgb"]) {
                color = [chunk stringByMatching:@"rgba?\\(.*?\\)" options:RKLCaseless inRange:NSMakeRange(0, chunk.length) capture:0 error:nil];
                isColor = YES;
            } else if ([chunk hasPrefix:@"hsl"]) {
                color = [chunk stringByMatching:@"hsla?\\(.*?\\)" options:RKLCaseless inRange:NSMakeRange(0, chunk.length) capture:0 error:nil];
                isColor = YES;
            } else if ([chunk hasPrefix:@"transparent"]) {
                color = @"transparent";
                isColor = YES;
            } else {
                for (NSString *c in [NSColor W3CColorNames]) {
                    if ([chunk.lowercaseString hasPrefix:c.lowercaseString]) {
                        color = c;
                        isColor = YES;
                        break;
                    }
                }
            }
            
            if (isColor == NO) {
                if ([string hasPrefix:@"linear-gradient"]) {
                    BOOL isAngle = NO;
                    NSArray *units = @[@"deg", @"grad", @"rad", @"turn"];
                    for (NSString *u in units) {
                        if ([chunk hasSuffix:u]) {
                            chunk = [chunk stringByReplacingOccurrencesOfString:u withString:@""];
                            [self.document setIfNotFirstResponder:self.bgImageDirectionControl string:chunk];
                            [self.bgImageDirectionUnitsControl selectItemWithTitle:u];
                            isAngle = YES;
                            break;
                        }
                    }
                    if (isAngle == NO) {
                        // Must be a named direction: "to right", "to left", etc.
                        [self.bgImageDirectionUnitsControl selectItemWithTitle:chunk];
                    }
                } else if ([string hasPrefix:@"radial-gradient"]) {
                    NSString *shape = @"";
                    NSString *extent = @"";
                    NSMutableArray *size = [NSMutableArray array];
                    NSMutableArray *pos = [NSMutableArray array];
                    NSArray *chunks = [chunk componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    BOOL foundAtKeyword = NO;
                    for (NSString *c in chunks) {
                        if ([c isEqualToString:@"circle"]) {
                            shape = @"circle";
                        } else if ([c isEqualToString:@"ellipse"]) {
                            shape = @"ellipse";
                        } else if ([c isEqualToString:@"closest-side"] ||
                                   [c isEqualToString:@"closest-corner"] ||
                                   [c isEqualToString:@"farthest-side"] ||
                                   [c isEqualToString:@"farthest-corner"]) {
                            extent = c;
                        } else if ([c isEqualToString:@"at"]) {
                            foundAtKeyword = YES;
                        } else {
                            if (foundAtKeyword) {
                                [pos addObject:c];
                            } else {
                                [size addObject:c];
                            }
                        }
                    }
                    if (shape.length == 0) {
                        // Infer shape
                        if (size.count == 0) {
                            shape = @"ellipse";
                        } else if (size.count == 1) {
                            shape = @"circle";
                        } else if (size.count == 2) {
                            shape = @"ellipse";
                        }
                    }
                    [self.bgImageShapeControl selectItemWithTitle:shape];
                    
                    if (size.count == 0 && extent.length == 0) {
                        [self.bgImageExtentControl selectItemWithTitle:@"farthest-corner"];
                    } else if (extent.length > 0) {
                        [self.bgImageExtentControl selectItemWithTitle:extent];
                    } else if (size.count > 0) {
                        [self.bgImageExtentControl selectItemWithTitle:@"unchanged"];
                        NSArray *units = @[@"rem", @"em", @"ex", @"ch", @"vh", @"vw", @"vmin", @"vmax", @"px", @"mm", @"cm", @"in", @"pt", @"pc", @"%"];
                        NSString *sizeH = size[0];
                        for (NSString *u in units) {
                            if ([sizeH hasSuffix:u]) {
                                self.bgImageSizeXControl.stringValue = [sizeH stringByReplacingOccurrencesOfString:u withString:@""];
                                [self.bgImageSizeXUnitsControl selectItemWithTitle:u];
                                break;
                            }
                        }
                        if (size.count == 2) {
                            NSString *sizeV = size[1];
                            for (NSString *u in units) {
                                if ([sizeV hasSuffix:u]) {
                                    self.bgImageSizeYControl.stringValue = [sizeV stringByReplacingOccurrencesOfString:u withString:@""];
                                    [self.bgImageSizeYUnitsControl selectItemWithTitle:u];
                                    break;
                                }
                            }
                        }
                    }
                    
                    if (pos.count == 2) {
                        NSArray *units = @[@"rem", @"em", @"ex", @"ch", @"vh", @"vw", @"vmin", @"vmax", @"px", @"mm", @"cm", @"in", @"pt", @"pc", @"%"];
                        NSString *posX = pos[0];
                        for (NSString *u in units) {
                            if ([posX hasSuffix:u]) {
                                self.bgImagePositionXControl.stringValue = [posX stringByReplacingOccurrencesOfString:u withString:@""];
                                [self.bgImagePositionXUnitsControl selectItemWithTitle:u];
                                break;
                            }
                        }
                        NSString *posY = pos[1];
                        for (NSString *u in units) {
                            if ([posY hasSuffix:u]) {
                                self.bgImagePositionYControl.stringValue = [posY stringByReplacingOccurrencesOfString:u withString:@""];
                                [self.bgImagePositionYUnitsControl selectItemWithTitle:u];
                                break;
                            }
                        }
                    }
                }
            } else if (isColor == YES && color.length > 0) {
                NSColor *colorObj = [NSColor colorWithCSS:color];
                if (colorObj) {
                    [colors addObject:colorObj];
                } else {
                    [colors addObject:[NSColor whiteColor]];
                }
                colorStop = [[chunk stringByReplacingOccurrencesOfString:color withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, chunk.length)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([colorStop hasSuffix:@"%"]) {
                    colorStop = [NSString stringWithFormat:@"%f", [[colorStop stringByReplacingOccurrencesOfString:@"%" withString:@""] doubleValue]/100.0];
                    
                } else {
                    NSArray *units = @[@"rem", @"em", @"ex", @"ch", @"vh", @"vw", @"vmin", @"vmax", @"px", @"mm", @"cm", @"in", @"pt", @"pc"];
                    for (NSString *u in units) {
                        if ([colorStop hasSuffix:u]) {
                            colorStop = [NSString stringWithFormat:@"%f", [[colorStop stringByReplacingOccurrencesOfString:u withString:@""] doubleValue]/NSWidth(self.bgImageGradientEditor.frame)];
                            break;
                        }
                    }
                }
                if (colorStop.length > 0) {
                    [colorStops addObject:colorStop];
                } else {
                    [colorStops addObject:@""];
                }
            }
            start = i+1;
        }
    }
    
    CGFloat currentStop = 0.0;
    CGFloat delta = (100.0/(colorStops.count-1))/100.0;
    for (NSInteger i = 0; i < colorStops.count; i++) {
        if ([colorStops[i] length] == 0) {
            [colorStops replaceObjectAtIndex:i withObject:@(currentStop)];
        } else {
            [colorStops replaceObjectAtIndex:i withObject:@([colorStops[i] floatValue])];
        }
        currentStop += delta;
    }
    
    CGFloat locs[colorStops.count];
    for (NSInteger i = 0; i < colorStops.count; i++) {
        locs[i] = [colorStops[i] doubleValue];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    
    NSGradient *gradient = [[NSGradient alloc] initWithColors:colors atLocations:&locs colorSpace:[NSColorSpace genericRGBColorSpace]];
    
#pragma clang diagnostic pop
    
    self.bgImageGradientEditor.gradient = gradient;
}

- (void)enableOrDisableControlsForBackgroundImage:(NSString *)backgroundImage {
    if ([backgroundImage hasPrefix:@"url"]) {
        [self.bgImageURLControl setEnabled:YES];
        self.bgImageURLLabel.textColor = [NSColor controlTextColor];
    } else if ([backgroundImage hasPrefix:@"linear-gradient"]) {
        [self.bgImageGradientEditor setEditable:YES];
        self.bgImageGradientLabel.textColor = [NSColor controlTextColor];
        [self.bgImageDirectionControl setEnabled:YES];
        [self.bgImageDirectionUnitsControl setEnabled:YES];
        self.bgImageDirectionLabel.textColor = [NSColor controlTextColor];
    } else if ([backgroundImage hasPrefix:@"radial-gradient"]) {
        [self.bgImageGradientEditor setEditable:YES];
        self.bgImageGradientLabel.textColor = [NSColor controlTextColor];
        [self.bgImagePositionXControl setEnabled:YES];
        [self.bgImagePositionXUnitsControl setEnabled:YES];
        [self.bgImagePositionYControl setEnabled:YES];
        [self.bgImagePositionYUnitsControl setEnabled:YES];
        [self.bgImageShapeControl setEnabled:YES];
        [self.bgImageSizeXControl setEnabled:YES];
        [self.bgImageSizeXUnitsControl setEnabled:YES];
        [self.bgImageSizeYControl setEnabled:YES];
        [self.bgImageSizeYUnitsControl setEnabled:YES];
        [self.bgImageExtentControl setEnabled:YES];
        self.bgImagePositionXLabel.textColor = [NSColor controlTextColor];
        self.bgImagePositionYLabel.textColor = [NSColor controlTextColor];
        self.bgImageShapeLabel.textColor = [NSColor controlTextColor];
        self.bgImageSizeXLabel.textColor = [NSColor controlTextColor];
        self.bgImageSizeYLabel.textColor = [NSColor controlTextColor];
        self.bgImageExtentLabel.textColor = [NSColor controlTextColor];
        
        // Select the defaults
        [self.bgImageShapeControl selectItemWithTitle:@"ellipse"];
        [self.bgImageExtentControl selectItemWithTitle:@"farthest-corner"];
    }
}

@end
