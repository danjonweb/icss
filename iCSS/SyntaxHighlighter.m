//
//  SyntaxHighlighter.m
//  iCSS
//
//  Created by Daniel Weber on 1/30/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "SyntaxHighlighter.h"
#import "RegexKitLite.h"
#import "NSColor+iOS7Colors.h"

#define CSS_PROPERTY @"property"
#define CSS_VALUE @"value"
#define CSS_SELECTOR @"selector"
#define QUOTE @"quote"

@interface SyntaxHighlighter ()
@property (assign) NSTextView *textView;
@property (strong) NSMutableDictionary *colorsDict;
@property (strong) NSTimer *parseTimer;
@end

@implementation SyntaxHighlighter

+ (SyntaxHighlighter *)syntaxHighlighterForTextView:(NSTextView *)textView {
    SyntaxHighlighter *sh = [[SyntaxHighlighter alloc] init];
    sh.textView = textView;
    sh.colorsDict = [NSMutableDictionary dictionary];
    [sh.colorsDict setObject:[NSColor iOS7darkGrayColor] forKey:QUOTE];
    [sh.colorsDict setObject:[NSColor iOS7lightBlueColor] forKey:CSS_PROPERTY];
    [sh.colorsDict setObject:[NSColor iOS7redColor] forKey:CSS_VALUE];
    [sh.colorsDict setObject:[NSColor iOS7darkBlueColor] forKey:CSS_SELECTOR];
    
    [textView.enclosingScrollView.contentView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:sh selector:@selector(boundDidChange:) name:NSViewBoundsDidChangeNotification object:nil];
    
    return sh;
}

- (void)boundDidChange:(NSNotification *)notification {
    [self.parseTimer invalidate];
    self.parseTimer = nil;
    self.parseTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self selector:@selector(parse:) userInfo:nil repeats:NO];
}

- (void)processEditing {
    [self.parseTimer invalidate];
    self.parseTimer = nil;
    self.parseTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(parse:) userInfo:nil repeats:NO];
}

- (void)parse:(id)sender {
    NSRange glyphRange = [self.textView.layoutManager glyphRangeForBoundingRect:self.textView.enclosingScrollView.documentVisibleRect inTextContainer:self.textView.textContainer];
    NSRange visibleRange = [self.textView.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    
    NSString *string = self.textView.textStorage.string;
    
    NSInteger delta = 2000;
    NSInteger start = visibleRange.location - delta;
    NSInteger length = 0;
    if (start >= 0) {
        visibleRange.location = start;
        length = delta * 2;
    } else {
        visibleRange.location = 0;
        length = delta;
    }
    visibleRange.length += length;
    
    if (NSMaxRange(visibleRange) > string.length) {
        visibleRange.length = string.length - visibleRange.location;
    }
    
    //NSLog(@"%@", NSStringFromRange(visibleRange));
    
    NSMutableArray *braces = [NSMutableArray array];
    
    for (NSLayoutManager *layoutManager in self.textView.textStorage.layoutManagers) {
        layoutManager.delegate = self;
        [layoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:visibleRange];
    }
    
    for (NSInteger i = visibleRange.location; i < NSMaxRange(visibleRange); i++) {
        unichar c = [string characterAtIndex:i];
        
        if (c == '{') {
            [braces addObject:@(i)];
        } else if (c == '}') {
            if (braces.count > 0) {
                NSInteger selectorEnd = [[braces lastObject] integerValue];
                [braces removeLastObject];
                
                NSInteger selectorStart = 0;
                for (NSInteger j = selectorEnd-1; j >= 0; j--) {
                    unichar cc = [string characterAtIndex:j];
                    if (cc == '}' || cc == '{' || cc == ';' || cc == '/') {
                        selectorStart = j+1;
                        break;
                    }
                }
                
                NSRange selectorRange = NSMakeRange(selectorStart, selectorEnd-selectorStart);
                for (NSLayoutManager *layoutManager in self.textView.textStorage.layoutManagers) {
                    [layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName: [self.colorsDict objectForKey:CSS_SELECTOR]} forCharacterRange:selectorRange];
                }
                
                // Start at end of rule, go backwards
                NSInteger endProp = -1;
                NSInteger endValue = -1;
                BOOL shouldSkip = NO;
                for (NSInteger j = i; j >= selectorEnd; j--) {
                    unichar cc = [string characterAtIndex:j];
                    if (cc == '(') {
                        shouldSkip = NO;
                    }
                    if (cc == '*' && j-1 >= 0 && [string characterAtIndex:j-1] == '/') {
                        shouldSkip = NO;
                    }
                    if (shouldSkip) {
                        continue;
                    }
                    if (cc == ')') {
                        shouldSkip = YES;
                    }
                    if (cc == '/' && j-1 >= 0 && [string characterAtIndex:j-1] == '*') {
                        shouldSkip = YES;
                    }
                    if (cc == ';' || cc == '}') {
                        endValue = j;
                    }
                    if (cc == ':') {
                        endProp = j;
                        
                        if (endValue != -1) {
                            NSRange valRange = NSMakeRange(j+1, endValue-j-1);
                            for (NSLayoutManager *layoutManager in self.textView.textStorage.layoutManagers) {
                                [layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName: [self.colorsDict objectForKey:CSS_VALUE]} forCharacterRange:valRange];
                            }
                            endValue = -1;
                        }
                    }
                    if (endProp != -1) {
                        if (cc == ';' || cc == '{' || (cc == '/' && j-1 >= 0 && [string characterAtIndex:j-1] == '*')) {
                            NSRange propRange = NSMakeRange(j+1, endProp-j-1);
                            for (NSLayoutManager *layoutManager in self.textView.textStorage.layoutManagers) {
                                [layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName: [self.colorsDict objectForKey:CSS_PROPERTY]} forCharacterRange:propRange];
                            }
                            
                            endProp = -1;
                        }
                    }
                }
            }
        } else if (c == '/' && i+1 < string.length && [string characterAtIndex:i+1] == '*') {
            for (NSInteger j = i; j < string.length; j++) {
                unichar cc = [string characterAtIndex:j];
                if (cc == '*' && j+1 < string.length && [string characterAtIndex:j+1] == '/') {
                    for (NSLayoutManager *layoutManager in self.textView.textStorage.layoutManagers) {
                        [layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName: [self.colorsDict objectForKey:QUOTE]} forCharacterRange:NSMakeRange(i, j+2-i)];
                    }
                    i = j+1;
                    break;
                }
            }
        }
    }
    
    
    
}

@end
