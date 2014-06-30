//
//  BackgroundViewController.h
//  iCSS
//
//  Created by Daniel Weber on 6/29/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACTGradientEditor.h"

@class Document;
@class DOMCSSStyleRule;
@class ColorTextField;

@interface BackgroundViewController : NSViewController <ACTGradientDelegate>

@property (assign) Document *document;

@property (assign) IBOutlet NSColorWell *bgColorControl;
@property (assign) IBOutlet ColorTextField *bgColorTextControl;
@property (assign) IBOutlet NSPopUpButton *bgImageControl;
@property (assign) IBOutlet NSSegmentedControl *bgImageAddAndRemoveButtons;
@property (assign) IBOutlet NSMenu *bgAddImageMenu;
@property (assign) IBOutlet NSMenuItem *bgAddImageMenuItem;
@property (assign) IBOutlet NSMenuItem *bgAddLinearGradientMenuItem;
@property (assign) IBOutlet NSMenuItem *bgAddRadialGradientMenuItem;
@property (assign) IBOutlet NSTextField *bgImageURLLabel;
@property (assign) IBOutlet NSTextField *bgImageURLControl;
@property (assign) IBOutlet NSTextField *bgImageGradientLabel;
@property (assign) IBOutlet ACTGradientEditor *bgImageGradientEditor;
@property (assign) IBOutlet NSTextField *bgImageDirectionLabel;
@property (assign) IBOutlet NSTextField *bgImageDirectionControl;
@property (assign) IBOutlet NSPopUpButton *bgImageDirectionUnitsControl;
@property (assign) IBOutlet NSTextField *bgImagePositionXLabel;
@property (assign) IBOutlet NSTextField *bgImagePositionXControl;
@property (assign) IBOutlet NSPopUpButton *bgImagePositionXUnitsControl;
@property (assign) IBOutlet NSTextField *bgImagePositionYLabel;
@property (assign) IBOutlet NSTextField *bgImagePositionYControl;
@property (assign) IBOutlet NSPopUpButton *bgImagePositionYUnitsControl;
@property (assign) IBOutlet NSTextField *bgImageShapeLabel;
@property (assign) IBOutlet NSPopUpButton *bgImageShapeControl;
@property (assign) IBOutlet NSTextField *bgImageSizeXLabel;
@property (assign) IBOutlet NSTextField *bgImageSizeXControl;
@property (assign) IBOutlet NSPopUpButton *bgImageSizeXUnitsControl;
@property (assign) IBOutlet NSTextField *bgImageSizeYLabel;
@property (assign) IBOutlet NSTextField *bgImageSizeYControl;
@property (assign) IBOutlet NSPopUpButton *bgImageSizeYUnitsControl;
@property (assign) IBOutlet NSTextField *bgImageExtentLabel;
@property (assign) IBOutlet NSPopUpButton *bgImageExtentControl;
@property (assign) IBOutlet NSTextField *bgPositionXControl;
@property (assign) IBOutlet NSPopUpButton *bgPositionXUnitsControl;
@property (assign) IBOutlet NSTextField *bgPositionYControl;
@property (assign) IBOutlet NSPopUpButton *bgPositionYUnitsControl;
@property (assign) IBOutlet NSTextField *bgWidthControl;
@property (assign) IBOutlet NSPopUpButton *bgWidthUnitsControl;
@property (assign) IBOutlet NSTextField *bgHeightControl;
@property (assign) IBOutlet NSPopUpButton *bgHeightUnitsControl;
@property (assign) IBOutlet NSSegmentedControl *bgRepeatControl;
@property (assign) IBOutlet NSSegmentedControl *bgAttachmentControl;

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule;
- (void)clearControls;

@end
