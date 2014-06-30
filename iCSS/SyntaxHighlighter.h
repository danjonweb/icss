//
//  SyntaxHighlighter.h
//  iCSS
//
//  Created by Daniel Weber on 1/30/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyntaxHighlighter : NSObject <NSLayoutManagerDelegate>

+ (SyntaxHighlighter *)syntaxHighlighterForTextView:(NSTextView *)textView;
- (void)processEditing;

@end
