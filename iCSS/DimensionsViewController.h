//
//  DimensionsViewController.h
//  iCSS
//
//  Created by Daniel Weber on 6/28/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Document;
@class DOMCSSStyleRule;

@interface DimensionsViewController : NSViewController

@property (assign) Document *document;

@property (assign) IBOutlet NSTextField *dimensionsWidthControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsWidthUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsHeightControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsHeightUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsMarginAllControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsMarginAllUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsMarginTopControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsMarginTopUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsMarginRightControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsMarginRightUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsMarginBottomControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsMarginBottomUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsMarginLeftControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsMarginLeftUnitsControl;

@property (assign) IBOutlet NSTextField *dimensionsPaddingAllControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsPaddingAllUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsPaddingTopControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsPaddingTopUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsPaddingRightControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsPaddingRightUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsPaddingBottomControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsPaddingBottomUnitsControl;
@property (assign) IBOutlet NSTextField *dimensionsPaddingLeftControl;
@property (assign) IBOutlet NSPopUpButton *dimensionsPaddingLeftUnitsControl;

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule;
- (void)clearControls;

@end
