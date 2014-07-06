//
//  TextViewController.h
//  iCSS
//
//  Created by Daniel Weber on 7/3/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Document;
@class DOMCSSStyleRule;

@interface TextViewController : NSViewController

@property (assign) Document *document;

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule;
- (void)clearControls;

@end
