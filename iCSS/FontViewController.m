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
    
    
    
    [self loadStyleRule:styleRule];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id sender = [notification object];
    
    
    
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
