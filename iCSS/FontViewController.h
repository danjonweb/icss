//
//  FontViewController.h
//  iCSS
//
//  Created by Daniel Weber on 7/3/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Document;
@class DOMCSSStyleRule;
@class ColorTextField;

@interface FontViewController : NSViewController

@property (assign) Document *document;

@property (assign) IBOutlet NSColorWell *fontColorControl;
@property (assign) IBOutlet ColorTextField *fontColorTextControl;
@property (assign) IBOutlet NSTextField *fontSizeControl;
@property (assign) IBOutlet NSPopUpButton *fontSizeUnitsControl;
@property (assign) IBOutlet NSTextField *lineHeightControl;
@property (assign) IBOutlet NSPopUpButton *lineHeightUnitsControl;
@property (assign) IBOutlet NSSegmentedControl *fontWeightAndStyleControl;
@property (assign) IBOutlet NSSegmentedControl *textDecorationControl;
@property (assign) IBOutlet NSSegmentedControl *fontVariantControl;
@property (assign) IBOutlet NSSegmentedControl *textTransformControl;
@property (assign) IBOutlet NSTableView *fontFamilyTableView;
@property (assign) IBOutlet NSPopUpButton *fontStacksControl;
@property (assign) IBOutlet NSSegmentedControl *fontFamilyControl;

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule;
- (void)clearControls;

@end
