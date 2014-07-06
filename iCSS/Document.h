//
//  Document.h
//  iCSS
//
//  Created by Daniel Weber on 6/27/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DOMCSSStyleRule;
@class FontViewController;
@class TextViewController;
@class BackgroundViewController;
@class DimensionsViewController;
@class PositioningViewController;
@class BorderViewController;
@class ColorTextField;

@interface Document : NSDocument <NSTextStorageDelegate>

@property (assign) IBOutlet NSWindow *docWindow;
@property (assign) IBOutlet NSOutlineView *stylesOutlineView;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSScrollView *inspectorScrollView;
@property (strong) FontViewController *fontViewController;
@property (strong) TextViewController *textViewController;
@property (strong) BackgroundViewController *backgroundViewController;
@property (strong) DimensionsViewController *dimensionsViewController;
@property (strong) PositioningViewController *positioningViewController;
@property (strong) BorderViewController *borderViewController;

/*
 Returns the last style rule loaded, either by clicking in the text of the rule
 or by clicking the selector name in the sidebar.
*/
- (DOMCSSStyleRule *)currentStyleRule;

/*
 Replaces the value of a property in the textview. If replaceInStyle = YES, it
 also replaces the value in the DOMCSSStyleRule.
 */
- (void)replaceProperty:(NSString *)prop value:(NSString *)val inStyle:(BOOL)replaceInStyle;

/*
 Removes a property in the textview. If removeFromStyle = YES, it also removes
 the value in the DOMCSSStyleRule.
 */
- (void)removeProperty:(NSString *)prop fromStyle:(BOOL)removeFromStyle;

/*
 Loads a value from the CSS text into a control, given the control and its
 corresponding units popup control. This method is very commonly used to
 divide up the CSS text (i.e. 15px) into a number and its units (15 and px).
*/
- (void)loadValue:(NSString *)value textControl:(NSTextField *)textField unitsControl:(NSPopUpButton *)popUpButton;

/*
 A shortcut for replaceProperty, given a text control, a corresponding units
 popup control, and an array of keywords. This method will remove a property
 if the value is empty, combine a number and its units, or replace one of
 the keywords.
*/
- (void)changeProperty:(NSString *)property textControl:(NSTextField *)textField unitsControl:(NSPopUpButton *)popUpButton keywords:(NSArray *)keywords;

/*
 Another shortcut for replaceProperty, given a popup control. It will replace
 the value of a property with the keyword selected from the popup button.
*/
- (void)changeProperty:(NSString *)property popUpControl:(NSPopUpButton *)popUpButton;

/*
 Returns the value of a property within a block of CSS text.
*/
- (NSString *)valueOfProperty:(NSString *)prop string:(NSString *)cssText;

/*
 Sets the string value of a text control if it's not the first responder. This
 is used when reloading a style as a user is typing in a text field (so the user
 can continue to type)
*/
- (void)setIfNotFirstResponder:(NSControl *)control string:(NSString *)string;

/*
 Sets the string value of a text control to an empty string if the text control
 is currently not the first responder.
*/
- (void)clearIfNotFirstResponder:(NSControl *)control;

/*
 Disables a control if it's not the first responder.
 */
- (void)disableIfNotFirstResponder:(NSControl *)control;

/*
 Uses regex to replace the standard RGB string (returned by WebKit) to a hex string.
*/
- (NSString *)replaceRGBColorWithHexString:(NSString *)value;

/*
 Saves a color to the recently used colors pref and then reloads the color control
*/
- (void)saveColor:(NSColor *)color reloadControl:(ColorTextField *)textField;

@end
