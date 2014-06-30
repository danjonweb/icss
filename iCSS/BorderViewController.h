//
//  BorderViewController.h
//  iCSS
//
//  Created by Daniel Weber on 6/27/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Document;
@class DOMCSSStyleRule;
@class ColorTextField;

@interface BorderViewController : NSViewController

@property (assign) Document *document;

@property (assign) IBOutlet NSSegmentedControl *borderControl;
@property (assign) IBOutlet NSButton *borderRemoveControl;
@property (assign) IBOutlet NSTextField *borderAllField;
@property (assign) IBOutlet NSTextField *borderTopField;
@property (assign) IBOutlet NSTextField *borderRightField;
@property (assign) IBOutlet NSTextField *borderBottomField;
@property (assign) IBOutlet NSTextField *borderLeftField;

@property (assign) IBOutlet NSPopUpButton *borderStyleControl;
@property (assign) IBOutlet NSColorWell *borderColorControl;
@property (assign) IBOutlet ColorTextField *borderColorTextControl;
@property (assign) IBOutlet NSTextField *borderThicknessControl;
@property (assign) IBOutlet NSPopUpButton *borderThicknessUnitsControl;

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule;
- (void)clearControls;

@end
