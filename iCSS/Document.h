//
//  Document.h
//  iCSS
//
//  Created by Daniel Weber on 6/27/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DOMCSSStyleRule;
@class BorderViewController;
@class PositioningViewController;
@class DimensionsViewController;
@class BackgroundViewController;

@interface Document : NSDocument <NSTextStorageDelegate>

@property (assign) IBOutlet NSWindow *docWindow;
@property (assign) IBOutlet NSOutlineView *stylesOutlineView;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSScrollView *inspectorScrollView;
@property (strong) BorderViewController *borderViewController;
@property (strong) PositioningViewController *positioningViewController;
@property (strong) DimensionsViewController *dimensionsViewController;
@property (strong) BackgroundViewController *backgroundViewController;

- (DOMCSSStyleRule *)currentStyleRule;
- (void)replaceProperty:(NSString *)prop value:(NSString *)val inStyle:(BOOL)replaceInStyle;
- (void)removeProperty:(NSString *)prop fromStyle:(BOOL)removeFromStyle;
- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule;
- (void)loadValue:(NSString *)value textControl:(NSTextField *)textField unitsControl:(NSPopUpButton *)popUpButton keywords:(NSArray *)keywords;
- (void)changeProperty:(NSString *)property textControl:(NSTextField *)textField unitsControl:(NSPopUpButton *)popUpButton keywords:(NSArray *)keywords;
- (void)changeProperty:(NSString *)property popUpControl:(NSPopUpButton *)popUpButton;
- (NSString *)valueOfProperty:(NSString *)prop string:(NSString *)cssText;
- (void)setIfNotFirstResponder:(NSControl *)control string:(NSString *)string;
- (void)clearIfNotFirstResponder:(NSControl *)control;
- (void)disableIfNotFirstResponder:(NSControl *)control;
- (NSString *)replaceRGBColorWithHexString:(NSString *)value;

@end
