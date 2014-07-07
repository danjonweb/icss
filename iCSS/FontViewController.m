//
//  FontViewController.m
//  iCSS
//
//  Created by Daniel Weber on 7/3/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "FontViewController.h"
#import "Document.h"
#import "ColorTextField.h"
#import "NSColor+HTMLColors.h"
#import <WebKit/WebKit.h>

@interface FontViewController ()
@property (strong) DOMCSSStyleRule *styleRule;
@property (strong) NSMutableArray *fontFamilyDataSource;
@end

@implementation FontViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.fontFamilyDataSource = [NSMutableArray array];
    }
    return self;
}

- (void)awakeFromNib {
    [self.fontWeightAndStyleControl setLabel:@"" forSegment:0];
    [self.fontWeightAndStyleControl setImageScaling:NSImageScaleNone forSegment:0];
    [self.fontWeightAndStyleControl setImage:[self boldFontImage] forSegment:0];
    
    [self.fontWeightAndStyleControl setLabel:@"" forSegment:1];
    [self.fontWeightAndStyleControl setImageScaling:NSImageScaleNone forSegment:1];
    [self.fontWeightAndStyleControl setImage:[self boldAndItalicFontImage] forSegment:1];
    
    [self.fontWeightAndStyleControl setLabel:@"" forSegment:2];
    [self.fontWeightAndStyleControl setImageScaling:NSImageScaleNone forSegment:2];
    [self.fontWeightAndStyleControl setImage:[self italicFontImage] forSegment:2];
    
    [self.fontVariantControl setLabel:@"" forSegment:0];
    [self.fontVariantControl setImage:[self smallCapsImage] forSegment:0];
}

#pragma mark - Control Changed

- (IBAction)controlChanged:(id)sender {
    DOMCSSStyleRule *styleRule = [self.document currentStyleRule];
    
    if (sender == self.fontColorControl) {
        self.fontColorTextControl.stringValue = self.fontColorControl.color.formattedString;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.document saveColor:self.fontColorControl.color reloadControl:self.fontColorTextControl];
    }
    if (sender == self.fontColorTextControl) {
        if (self.fontColorTextControl.stringValue.length == 0) {
            [self.document removeProperty:@"color" fromStyle:YES];
        } else {
            NSColor *color = [NSColor colorWithCSS:self.fontColorTextControl.stringValue];
            if (color) {
                self.fontColorControl.color = color;
            } else {
                return;
            }
        }
    } else if (sender == self.fontSizeControl || sender == self.fontSizeUnitsControl) {
        [self.document changeProperty:@"font-size" textControl:self.fontSizeControl unitsControl:self.fontSizeUnitsControl keywords:@[@"initial", @"inherit", @"smaller", @"larger", @"xx-small", @"x-small", @"small", @"medium", @"large", @"x-large", @"xx-large"]];
    } else if (sender == self.lineHeightControl || sender == self.lineHeightUnitsControl) {
        [self.document changeProperty:@"line-height" textControl:self.lineHeightControl unitsControl:self.lineHeightUnitsControl keywords:@[@"initial", @"inherit", @"normal"]];
    } else if (sender == self.fontWeightAndStyleControl) {
        NSSegmentedControl *segmentedControl = self.fontWeightAndStyleControl;
        NSInteger selectedIndex = segmentedControl.selectedSegment;
        [segmentedControl setSelected:NO forSegment:0];
        [segmentedControl setSelected:NO forSegment:1];
        [segmentedControl setSelected:NO forSegment:2];
        [segmentedControl setSelected:NO forSegment:3];
        if (selectedIndex == 0) {
            if (styleRule.style.font.length > 0) {
                [self.document replaceProperty:@"font-weight" value:@"bold" inStyle:YES];
                [self.document replaceProperty:@"font-style" value:@"normal" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:0];
            } else {
                if ([styleRule.style.fontWeight isEqualToString:@"bold"] && (styleRule.style.fontStyle.length == 0 || [styleRule.style.fontStyle isEqualToString:@"normal"])) {
                    [self.document removeProperty:@"font-weight" fromStyle:YES];
                } else {
                    [self.document removeProperty:@"font-style" fromStyle:YES];
                    [self.document replaceProperty:@"font-weight" value:@"bold" inStyle:YES];
                    [segmentedControl setSelected:YES forSegment:0];
                }
            }
        } else if (selectedIndex == 1) {
            if (styleRule.style.font.length > 0) {
                [self.document replaceProperty:@"font-weight" value:@"bold" inStyle:YES];
                [self.document replaceProperty:@"font-style" value:@"italic" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:1];
            } else {
                if ([styleRule.style.fontWeight isEqualToString:@"bold"] && [styleRule.style.fontStyle isEqualToString:@"italic"]) {
                    [self.document removeProperty:@"font-style" fromStyle:YES];
                    [self.document removeProperty:@"font-weight" fromStyle:YES];
                } else {
                    [self.document replaceProperty:@"font-style" value:@"italic" inStyle:YES];
                    [self.document replaceProperty:@"font-weight" value:@"bold" inStyle:YES];
                    [segmentedControl setSelected:YES forSegment:1];
                }
            }
        } else if (selectedIndex == 2) {
            if (styleRule.style.font.length > 0) {
                [self.document replaceProperty:@"font-style" value:@"italic" inStyle:YES];
                [self.document replaceProperty:@"font-weight" value:@"normal" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:2];
            } else {
                if ([styleRule.style.fontStyle isEqualToString:@"italic"] && (styleRule.style.fontWeight.length == 0 || [styleRule.style.fontWeight isEqualToString:@"normal"])) {
                    [self.document removeProperty:@"font-style" fromStyle:YES];
                } else {
                    [self.document removeProperty:@"font-weight" fromStyle:YES];
                    [self.document replaceProperty:@"font-style" value:@"italic" inStyle:YES];
                    [segmentedControl setSelected:YES forSegment:2];
                }
            }
        } else if (selectedIndex == 3) {
            if (styleRule.style.font.length > 0) {
                [self.document replaceProperty:@"font-style" value:@"normal" inStyle:YES];
                [self.document replaceProperty:@"font-weight" value:@"normal" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:3];
            } else {
                if ([styleRule.style.fontWeight isEqualToString:@"normal"]) {
                    [self.document removeProperty:@"font-style" fromStyle:YES];
                    [self.document removeProperty:@"font-weight" fromStyle:YES];
                } else {
                    [self.document replaceProperty:@"font-style" value:@"normal" inStyle:YES];
                    [self.document replaceProperty:@"font-weight" value:@"normal" inStyle:YES];
                    [segmentedControl setSelected:YES forSegment:3];
                }
            }
        }
    } else if (sender == self.textDecorationControl) {
        NSSegmentedControl *segmentedControl = self.textDecorationControl;
        NSInteger selectedIndex = segmentedControl.selectedSegment;
        [segmentedControl setSelected:NO forSegment:0];
        [segmentedControl setSelected:NO forSegment:1];
        [segmentedControl setSelected:NO forSegment:2];
        [segmentedControl setSelected:NO forSegment:3];
        if (selectedIndex == 0) {
            if ([styleRule.style.textDecoration isEqualToString:@"underline"]) {
                [self.document removeProperty:@"text-decoration" fromStyle:YES];
            } else {
                [self.document replaceProperty:@"text-decoration" value:@"underline" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:0];
            }
        } else if (selectedIndex == 1) {
            if ([styleRule.style.textDecoration isEqualToString:@"line-through"]) {
                [self.document removeProperty:@"text-decoration" fromStyle:YES];
            } else {
                [self.document replaceProperty:@"text-decoration" value:@"line-through" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:1];
            }
        } else if (selectedIndex == 2) {
            if ([styleRule.style.textDecoration isEqualToString:@"overline"]) {
                [self.document removeProperty:@"text-decoration" fromStyle:YES];
            } else {
                [self.document replaceProperty:@"text-decoration" value:@"overline" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:2];
            }
        } else if (selectedIndex == 3) {
            if ([styleRule.style.textDecoration isEqualToString:@"none"]) {
                [self.document removeProperty:@"text-decoration" fromStyle:YES];
            } else {
                [self.document replaceProperty:@"text-decoration" value:@"none" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:3];
            }
        }
    } else if (sender == self.fontVariantControl) {
        NSSegmentedControl *segmentedControl = self.fontVariantControl;
        NSInteger selectedIndex = segmentedControl.selectedSegment;
        [segmentedControl setSelected:NO forSegment:0];
        [segmentedControl setSelected:NO forSegment:1];
        if (selectedIndex == 0) {
            if (styleRule.style.font.length > 0) {
                [self.document replaceProperty:@"font-variant" value:@"small-caps" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:0];
            } else {
                if ([styleRule.style.fontVariant isEqualToString:@"small-caps"]) {
                    [self.document removeProperty:@"font-variant" fromStyle:YES];
                } else {
                    [self.document replaceProperty:@"font-variant" value:@"small-caps" inStyle:YES];
                    [segmentedControl setSelected:YES forSegment:0];
                }
            }
        } else if (selectedIndex == 1) {
            if (styleRule.style.font.length > 0) {
                [self.document replaceProperty:@"font-variant" value:@"normal" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:1];
            } else {
                if ([styleRule.style.fontVariant isEqualToString:@"normal"]) {
                    [self.document removeProperty:@"font-variant" fromStyle:YES];
                } else {
                    [self.document replaceProperty:@"font-variant" value:@"normal" inStyle:YES];
                    [segmentedControl setSelected:YES forSegment:1];
                }
            }
        }
    } else if (sender == self.textTransformControl) {
        NSSegmentedControl *segmentedControl = self.textTransformControl;
        NSInteger selectedIndex = segmentedControl.selectedSegment;
        NSString *property = @"text-transform";
        [segmentedControl setSelected:NO forSegment:0];
        [segmentedControl setSelected:NO forSegment:1];
        [segmentedControl setSelected:NO forSegment:2];
        [segmentedControl setSelected:NO forSegment:3];
        if (selectedIndex == 0) {
            if ([styleRule.style.textTransform isEqualToString:@"capitalize"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"capitalize" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:0];
            }
        } else if (selectedIndex == 1) {
            if ([styleRule.style.textTransform isEqualToString:@"uppercase"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"uppercase" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:1];
            }
        } else if (selectedIndex == 2) {
            if ([styleRule.style.textTransform isEqualToString:@"lowercase"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"lowercase" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:2];
            }
        } else if (selectedIndex == 3) {
            if ([styleRule.style.textTransform isEqualToString:@"none"]) {
                [self.document removeProperty:property fromStyle:YES];
            } else {
                [self.document replaceProperty:property value:@"none" inStyle:YES];
                [segmentedControl setSelected:YES forSegment:3];
            }
        }
    }
    
    if (self.fontColorTextControl.stringValue.length > 0 ) {
        [self.document replaceProperty:@"color" value:self.fontColorTextControl.stringValue inStyle:YES];
    } else {
        [self.document removeProperty:@"color" fromStyle:YES];
    }
    
    [self loadStyleRule:styleRule];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id sender = [notification object];
    
    if (sender == self.fontSizeControl) {
        if (self.fontSizeUnitsControl.indexOfSelectedItem == 0) {
            [self.fontSizeUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.fontSizeControl.stringValue.length == 0) {
            [self.fontSizeUnitsControl selectItemWithTitle:@"unchanged"];
        }
    } else if (sender == self.lineHeightControl) {
        if (self.lineHeightUnitsControl.indexOfSelectedItem == 0) {
            [self.lineHeightUnitsControl selectItemWithTitle:@"px"];
        }
        if (self.lineHeightControl.stringValue.length == 0) {
            [self.lineHeightUnitsControl selectItemWithTitle:@"unchanged"];
        }
        if (self.lineHeightControl.stringValue.length != 0 && [self.lineHeightUnitsControl.titleOfSelectedItem isEqualToString:@"normal"]) {
            [self.lineHeightUnitsControl selectItemWithTitle:@"px"];
        }
    }
    
    [self controlChanged:sender];
}

#pragma mark - Clear Controls

- (void)clearControls {
    [self.fontColorControl setColor:[NSColor whiteColor]];
    [self.document clearIfNotFirstResponder:self.fontColorTextControl];
    
    [self.document clearIfNotFirstResponder:self.fontSizeControl];
    [self.fontSizeUnitsControl selectItemWithTitle:@"unchanged"];
    
    [self.document clearIfNotFirstResponder:self.lineHeightControl];
    [self.lineHeightUnitsControl selectItemWithTitle:@"unchanged"];
    
    [self.fontWeightAndStyleControl setSelected:NO forSegment:0];
    [self.fontWeightAndStyleControl setSelected:NO forSegment:1];
    [self.fontWeightAndStyleControl setSelected:NO forSegment:2];
    [self.fontWeightAndStyleControl setSelected:NO forSegment:3];
    [self.textDecorationControl setSelected:NO forSegment:0];
    [self.textDecorationControl setSelected:NO forSegment:1];
    [self.textDecorationControl setSelected:NO forSegment:2];
    [self.textDecorationControl setSelected:NO forSegment:3];
    [self.fontVariantControl setSelected:NO forSegment:0];
    [self.fontVariantControl setSelected:NO forSegment:1];
    [self.textTransformControl setSelected:NO forSegment:0];
    [self.textTransformControl setSelected:NO forSegment:1];
    [self.textTransformControl setSelected:NO forSegment:2];
    [self.textTransformControl setSelected:NO forSegment:3];
    [self.fontFamilyDataSource removeAllObjects];
    [self.fontFamilyTableView reloadData];
}

#pragma mark - Load Style

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule {
    DOMCSSStyleDeclaration *style = styleRule.style;
    self.styleRule = styleRule.copy;
    [self clearControls];
    [self.fontColorTextControl reload];
    
    if (style.color.length > 0) {
        NSColor *color = [NSColor colorWithCSS:style.color];
        if (color) {
            self.fontColorControl.color = color;
            self.fontColorTextControl.stringValue = color.rgbStringValue;
        }
    }
    
    if (style.fontSize.length > 0) {
        [self.document loadValue:style.fontSize textControl:self.fontSizeControl unitsControl:self.fontSizeUnitsControl];
    }
    
    if (style.lineHeight.length > 0) {
        [self.document loadValue:style.lineHeight textControl:self.lineHeightControl unitsControl:self.lineHeightUnitsControl];
    }
    
    BOOL isBold = NO;
    BOOL isItalic = NO;
    if (style.fontWeight.length > 0) {
        NSArray *boldWords = @[@"bold", @"bolder", @"600", @"700", @"800", @"900"];
        if ([boldWords containsObject:style.fontWeight]) {
            isBold = YES;
        }
    }
    if (style.fontStyle.length > 0) {
        NSArray *italicWords = @[@"italic", @"oblique"];
        if ([italicWords containsObject:style.fontStyle]) {
            isItalic = YES;
        }
    }
    if ([style.fontWeight isEqualToString:@"normal"] && [style.fontStyle isEqualToString:@"normal"]) {
        [self.fontWeightAndStyleControl setSelectedSegment:3];
    } else {
        if (isBold && isItalic) {
            [self.fontWeightAndStyleControl setSelectedSegment:1];
        } else if (isBold) {
            [self.fontWeightAndStyleControl setSelectedSegment:0];
        } else if (isItalic) {
            [self.fontWeightAndStyleControl setSelectedSegment:2];
        }
    }
    
    if (style.textDecoration.length > 0) {
        if ([style.textDecoration isEqualToString:@"underline"]) {
            [self.textDecorationControl setSelectedSegment:0];
        } else if ([style.textDecoration isEqualToString:@"line-through"]) {
            [self.textDecorationControl setSelectedSegment:1];
        } else if ([style.textDecoration isEqualToString:@"overline"]) {
            [self.textDecorationControl setSelectedSegment:2];
        } else if ([style.textDecoration isEqualToString:@"none"]) {
            [self.textDecorationControl setSelectedSegment:3];
        }
    }
    
    if (style.fontVariant.length > 0) {
        if ([style.fontVariant isEqualToString:@"small-caps"]) {
            [self.fontVariantControl setSelectedSegment:0];
        } else if ([style.fontVariant isEqualToString:@"normal"]) {
            [self.fontVariantControl setSelectedSegment:1];
        }
    }
    
    if (style.textTransform.length > 0) {
        if ([style.textTransform isEqualToString:@"capitalize"]) {
            [self.textTransformControl setSelectedSegment:0];
        } else if ([style.textTransform isEqualToString:@"uppercase"]) {
            [self.textTransformControl setSelectedSegment:1];
        } else if ([style.textTransform isEqualToString:@"lowercase"]) {
            [self.textTransformControl setSelectedSegment:2];
        } else if ([style.textTransform isEqualToString:@"none"]) {
            [self.textTransformControl setSelectedSegment:3];
        }
    }
    
    if (style.fontFamily.length > 0) {
        [self.fontFamilyDataSource addObjectsFromArray:[self parseFontFamily:style.fontFamily]];
        [self.fontFamilyTableView reloadData];
    }
}

#pragma mark - Parsing

- (NSMutableArray *)parseFontFamily:(NSString *)s {
    NSMutableArray *families = [NSMutableArray array];
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
            NSString *family = [s substringWithRange:NSMakeRange(start, end-start)];
            family = [family stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            family = [family stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]];
            [families addObject:family];
            start = i+1;
        }
    }
    return families;
}

#pragma mark - Table View

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.fontFamilyDataSource.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < self.fontFamilyDataSource.count) {
        return self.fontFamilyDataSource[row];
    }
    return @"";
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    self.fontFamilyDataSource[row] = object;
    //[self updateFontFamily];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.fontFamilyTableView.selectedRow == -1) {
        [self.fontFamilyControl setEnabled:NO forSegment:1];
    } else {
        [self.fontFamilyControl setEnabled:YES forSegment:1];
    }
}

#pragma mark - Create images

- (NSImage *)boldFontImage {
    const NSString *kImageText = @"B";
    NSDictionary *attrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]};
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:kImageText.copy attributes:attrs];
    NSImage *image = [[NSImage alloc] initWithSize:str.size];
    [image lockFocus];
    [str drawAtPoint:NSZeroPoint];
    [image unlockFocus];
    [image setTemplate:YES];
    return image;
}

- (NSImage *)boldAndItalicFontImage {
    const NSString *kImageText = @"B+i";
    const NSRange kBoldRange = NSMakeRange(0, 3);
    const NSRange kItalicRange = NSMakeRange(2, 1);
    const CGFloat kKernValue = 2.0;
    const NSRange kKernRange = NSMakeRange(0, 3);
    NSDictionary *boldAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]};
    NSDictionary *italicAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]], NSObliquenessAttributeName: [NSNumber numberWithFloat:0.20]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:kImageText.copy];
    [str addAttributes:boldAttrs range:kBoldRange];
    [str addAttributes:italicAttrs range:kItalicRange];
    [str addAttribute:NSKernAttributeName value:@(kKernValue) range:kKernRange];
    NSImage *image = [[NSImage alloc] initWithSize:str.size];
    [image lockFocus];
    [str drawAtPoint:NSZeroPoint];
    [image unlockFocus];
    [image setTemplate:YES];
    return image;
}

- (NSImage *)italicFontImage {
    const NSString *kImageText = @"i";
    // Use oblique instead of italic [string applyFontTraits:NSItalicFontMask range:range];
    NSDictionary *attrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]], NSObliquenessAttributeName: [NSNumber numberWithFloat:0.20]};
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:kImageText.copy attributes:attrs];
    NSImage *image = [[NSImage alloc] initWithSize:str.size];
    [image lockFocus];
    [str drawAtPoint:NSZeroPoint];
    [image unlockFocus];
    [image setTemplate:YES];
    return image;
}

- (NSImage *)smallCapsImage {
    const NSString *kImageText = @"SMALL CAPS";
    const NSRange kSmallTextRange1 = NSMakeRange(1, 4);
    const NSRange kSmallTextRange2 = NSMakeRange(7, 3);
    NSDictionary *bigFontAttrs = @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]};
    NSDictionary *smallFontAttrs = @{NSFontAttributeName: [NSFont systemFontOfSize:0.82 * [NSFont systemFontSizeForControlSize:NSSmallControlSize]]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:kImageText.copy];
    [str addAttributes:bigFontAttrs range:NSMakeRange(0, kImageText.length)];
    [str addAttributes:smallFontAttrs range:kSmallTextRange1];
    [str addAttributes:smallFontAttrs range:kSmallTextRange2];
    NSImage *image = [[NSImage alloc] initWithSize:str.size];
    [image lockFocus];
    [str drawAtPoint:NSZeroPoint];
    [image unlockFocus];
    [image setTemplate:YES];
    return image;
}

@end
