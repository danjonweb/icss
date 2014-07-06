//
//  SyntaxHighlighter.h
//  iCSS
//
//  Created by Daniel Weber on 1/30/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CSS_PROPERTY_COLOR [NSColor iOS7lightBlueColor]
#define CSS_VALUE_COLOR [NSColor iOS7redColor]
#define CSS_SELECTOR_COLOR [NSColor iOS7darkBlueColor]
#define CSS_QUOTE_COLOR [NSColor iOS7darkGrayColor]

@interface SyntaxHighlighter : NSObject <NSLayoutManagerDelegate>

+ (SyntaxHighlighter *)syntaxHighlighterForTextView:(NSTextView *)textView;
- (void)processEditing;

@end
