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
@class ColorTextField;

@interface TextViewController : NSViewController

@property (assign) Document *document;

@property (assign) IBOutlet NSSegmentedControl *textAlignControl;
@property (assign) IBOutlet NSTextField *textIndentControl;
@property (assign) IBOutlet NSPopUpButton *textIndentUnitsControl;
@property (assign) IBOutlet NSTextField *letterSpacingControl;
@property (assign) IBOutlet NSPopUpButton *letterSpacingUnitsControl;
@property (assign) IBOutlet NSTextField *wordSpacingControl;
@property (assign) IBOutlet NSPopUpButton *wordSpacingUnitsControl;
@property (assign) IBOutlet NSPopUpButton *whiteSpaceControl;

@property (assign) IBOutlet NSPopUpButton *textShadowControl;
@property (assign) IBOutlet NSSegmentedControl *textShadowAddAndRemoveButtons;
@property (assign) IBOutlet NSTextField *textShadowXControl;
@property (assign) IBOutlet NSPopUpButton *textShadowXUnitsControl;
@property (assign) IBOutlet NSTextField *textShadowYControl;
@property (assign) IBOutlet NSPopUpButton *textShadowYUnitsControl;
@property (assign) IBOutlet NSTextField *textShadowBlurControl;
@property (assign) IBOutlet NSPopUpButton *textShadowBlurUnitsControl;
@property (assign) IBOutlet NSColorWell *textShadowColorControl;
@property (assign) IBOutlet ColorTextField *textShadowColorTextControl;

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule;
- (void)clearControls;

@end
