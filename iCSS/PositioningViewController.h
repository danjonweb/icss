//
//  PositioningViewController.h
//  iCSS
//
//  Created by Daniel Weber on 6/28/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Document;
@class DOMCSSStyleRule;

@interface PositioningViewController : NSViewController

@property (assign) Document *document;

@property (assign) IBOutlet NSPopUpButton *positionControl;
@property (assign) IBOutlet NSTextField *positionTopControl;
@property (assign) IBOutlet NSPopUpButton *positionTopUnitsControl;
@property (assign) IBOutlet NSTextField *positionRightControl;
@property (assign) IBOutlet NSPopUpButton *positionRightUnitsControl;
@property (assign) IBOutlet NSTextField *positionBottomControl;
@property (assign) IBOutlet NSPopUpButton *positionBottomUnitsControl;
@property (assign) IBOutlet NSTextField *positionLeftControl;
@property (assign) IBOutlet NSPopUpButton *positionLeftUnitsControl;
@property (assign) IBOutlet NSPopUpButton *displayControl;
@property (assign) IBOutlet NSSegmentedControl *floatControl;
@property (assign) IBOutlet NSSegmentedControl *clearControl;
@property (assign) IBOutlet NSPopUpButton *visibilityControl;
@property (assign) IBOutlet NSPopUpButton *overflowControl;
@property (assign) IBOutlet NSSegmentedControl *zIndexUpDownControl;
@property (assign) IBOutlet NSComboBox *zIndexTextControl;

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule;
- (void)clearControls;

@end
