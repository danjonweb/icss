//
//  Document.m
//  iCSS
//
//  Created by Daniel Weber on 6/27/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "Document.h"
#import "FontViewController.h"
#import "TextViewController.h"
#import "BackgroundViewController.h"
#import "DimensionsViewController.h"
#import "PositioningViewController.h"
#import "BorderViewController.h"
#import "SyntaxHighlighter.h"
#import "CSSParser.h"
#import "TBMInspectorView.h"
#import "NSColor+HTMLColors.h"
#import "NSColor+iOS7Colors.h"
#import "ImageAndTextCell.h"
#import "ColorTextField.h"
#import "TBMDetailView.h"
#import "RegexKitLite.h"
#import <WebKit/WebKit.h>

@interface Document ()
@property (strong) WebView *webView;
@property (strong) WebView *styleWebView;
@property (strong) SyntaxHighlighter *syntaxHighlighter;
@property (strong) NSMutableArray *parsedRules;
@property (strong) NSMutableArray *rulesDataSource;
@property (strong) NSMutableDictionary *images;
@property (strong) NSMutableArray *parsers;
@property (strong) NSTimer *parseTimer;
@property NSInteger indexOfLastRule;
@property BOOL suppressOutlineSelectionChanged;
@property BOOL suppressParseOnProcessEditing;
@property BOOL suppressTextViewSelectionChanged;
@property (strong) NSMutableDictionary *units;
@property (strong) NSTimer *saveColorTimer;
@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    self.webView = [[WebView alloc] init];
    self.webView.frameLoadDelegate = self;
    
    self.styleWebView = [[WebView alloc] init];
    self.styleWebView.frameLoadDelegate = self;
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [NSColor setIgnoresAlpha:NO];
    
    self.rulesDataSource = [NSMutableArray array];
    self.parsedRules = [NSMutableArray array];
    self.parsers = [NSMutableArray array];
    
    self.images = [NSMutableDictionary dictionary];
    self.images[@"comment"] = [NSImage imageNamed:@"comment"];
    self.images[@"media"] = [NSImage imageNamed:@"media"];
    self.images[@"import"] = [NSImage imageNamed:@"import"];
    self.images[@"charset"] = [NSImage imageNamed:@"charset"];
    
    self.textView.textStorage.delegate = self;
    self.textView.font = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
    self.textView.automaticQuoteSubstitutionEnabled = NO;
    [self.textView setContinuousSpellCheckingEnabled:NO];
    self.syntaxHighlighter = [SyntaxHighlighter syntaxHighlighterForTextView:self.textView];
    
    self.fontViewController = [[FontViewController alloc] initWithNibName:@"FontViewController" bundle:nil];
    self.textViewController = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
    self.backgroundViewController = [[BackgroundViewController alloc] initWithNibName:@"BackgroundViewController" bundle:nil];
    self.dimensionsViewController = [[DimensionsViewController alloc] initWithNibName:@"DimensionsViewController" bundle:nil];
    self.positioningViewController = [[PositioningViewController alloc] initWithNibName:@"PositioningViewController" bundle:nil];
    self.borderViewController = [[BorderViewController alloc] initWithNibName:@"BorderViewController" bundle:nil];
    self.fontViewController.document = self;
    self.textViewController.document = self;
    self.backgroundViewController.document = self;
    self.dimensionsViewController.document = self;
    self.positioningViewController.document = self;
    self.borderViewController.document = self;
    
    TBMInspectorView *inspector = [[TBMInspectorView alloc] initWithFrame:NSMakeRect(0.0, 0.0, NSWidth(self.inspectorScrollView.frame), 0.0)];
    [inspector addView:self.fontViewController.view label:@"Font" expanded:YES];
    [inspector addView:self.textViewController.view label:@"Text" expanded:YES];
    [inspector addView:self.backgroundViewController.view label:@"Background" expanded:YES];
    [inspector addView:self.dimensionsViewController.view label:@"Dimensions" expanded:YES];
    [inspector addView:self.positioningViewController.view label:@"Positioning" expanded:YES];
    [inspector addView:self.borderViewController.view label:@"Borders" expanded:YES];
    [self.inspectorScrollView setDocumentView:inspector];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"css"];
    NSError *error;
    self.textView.string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        [self.textView scrollRectToVisible:NSMakeRect(0, 0, 10, 10)];
    }
    
    [self resetStyleRule];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    
    return YES;
}

#pragma mark - Outline View

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil)
        return self.rulesDataSource.count;
    NSDictionary *ruleDict = (NSDictionary *)item;
    if (ruleDict[@"rules"]) {
        NSArray *groupRules = ruleDict[@"rules"];
        return groupRules.count;
    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    NSDictionary *ruleDict = (NSDictionary *)item;
    if (ruleDict[@"rules"]) {
        return YES;
    }
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil)
        return [self.rulesDataSource objectAtIndex:index];
    NSDictionary *ruleDict = (NSDictionary *)item;
    if (ruleDict[@"rules"]) {
        NSArray *groupRules = ruleDict[@"rules"];
        return groupRules[index];
    }
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSDictionary *ruleDict = (NSDictionary *)item;
    return ruleDict[@"name"];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    ImageAndTextCell *imageAndTextCell = (ImageAndTextCell *)cell;
    
    // Reset cell
    [imageAndTextCell setTextColor:[NSColor blackColor]];
    [imageAndTextCell setDrawsBackground:NO];
    
    NSDictionary *ruleDict = (NSDictionary *)item;
    if (self.images[ruleDict[@"type"]]) {
        [imageAndTextCell setImage:self.images[ruleDict[@"type"]]];
    } else {
        [imageAndTextCell setImage:nil];
    }
    
    NSInteger index = [ruleDict[@"index"] integerValue];
    if (index >= 0 && index < self.parsedRules.count) {
        DOMCSSRule *rule = self.parsedRules[index];
        
        if (rule.type == DOM_STYLE_RULE) {
            DOMCSSStyleRule *styleRule = (DOMCSSStyleRule *)rule;
            if (styleRule.style.color.length > 0) {
                NSColor *color = [NSColor colorWithCSS:styleRule.style.color];
                [imageAndTextCell setTextColor:color];
                
                const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
                if (componentColors != NULL) {
                    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
                    if (colorBrightness < 0.8) {
                        
                    } else {
                        [imageAndTextCell setBackgroundColor:[NSColor whiteColor]];
                        [imageAndTextCell setDrawsBackground:YES];
                    }
                }
            }
            
            if (styleRule.style.backgroundColor.length > 0) {
                if (![styleRule.style.backgroundColor isEqualToString:@"transparent"] &&
                    ![styleRule.style.backgroundColor isEqualToString:@"inherit"] &&
                    ![styleRule.style.backgroundColor isEqualToString:@"none"] &&
                    ![styleRule.style.backgroundColor isEqualToString:@"initial"]) {
                    NSColor *backgroundColor = [NSColor colorWithCSS:styleRule.style.backgroundColor];
                    [imageAndTextCell setBackgroundColor:backgroundColor];
                    [imageAndTextCell setDrawsBackground:YES];
                }
            }
        } else if (rule.type == DOM_MEDIA_RULE) {
            
        } else if (rule.type == DOM_FONT_FACE_RULE) {
            
        }
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if (self.suppressOutlineSelectionChanged)
        return;
    NSDictionary *ruleDict = (NSDictionary *)[self.stylesOutlineView itemAtRow:self.stylesOutlineView.selectedRow];
    
    if (ruleDict[@"range"]) {
        NSRange range = NSRangeFromString(ruleDict[@"range"]);
        [self.textView setSelectedRange:range];
        [self.textView scrollRangeToVisible:range];
    }
    if (ruleDict[@"index"]) {
        NSInteger index = [ruleDict[@"index"] integerValue];
        if (index >= 0 && index < self.parsedRules.count) {
            DOMCSSRule *rule = self.parsedRules[index];
            if (rule.type == DOM_STYLE_RULE) {
                //DOMCSSStyleRule *styleRule = (DOMCSSStyleRule *)rule;
            }
        }
    }
};

#pragma mark - Text View

- (void)textStorageDidProcessEditing:(NSNotification *)notification {
    [self.syntaxHighlighter processEditing];
    if (self.suppressParseOnProcessEditing) {
        [self scan];
    } else {
        [self scanAndParse];
    }
}

- (void)loadStyleRuleFromArray:(NSArray *)rules {
    for (NSInteger i = 0; i < rules.count; i++) {
        NSDictionary *ruleDict = rules[i];
        if (ruleDict[@"range"] && ruleDict[@"index"]) {
            NSRange range = NSRangeFromString(ruleDict[@"range"]);
            if (NSLocationInRange(self.textView.selectedRange.location, range)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ruleDict[@"rules"]) {
                        // Matches group rule, look at subrules
                        [self.stylesOutlineView expandItem:ruleDict];
                        [self loadStyleRuleFromArray:ruleDict[@"rules"]];
                    } else {
                        self.suppressOutlineSelectionChanged = YES;
                        NSInteger row = [self.stylesOutlineView rowForItem:ruleDict];
                        [self.stylesOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                        self.suppressOutlineSelectionChanged = NO;
                        [self.stylesOutlineView scrollRowToVisible:row];
                        
                        NSInteger ruleIndex = [ruleDict[@"index"] integerValue];
                        if (ruleIndex >= 0 && ruleIndex < self.parsedRules.count) {
                            self.indexOfLastRule = ruleIndex;
                            DOMCSSRule *rule = self.parsedRules[ruleIndex];
                            DOMCSSStyleRule *styleRule = (DOMCSSStyleRule *)rule;
                            [self loadStyleRule:styleRule];
                        }
                    }
                });
                break;
            }
        }
    }
}

- (void)textViewDidChangeSelection:(NSNotification *)notification {
    if (self.suppressTextViewSelectionChanged)
        return;
    self.indexOfLastRule = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self loadStyleRuleFromArray:self.rulesDataSource];
    });
}

#pragma mark - Parsing

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    DOMCSSStyleSheet *sheet = (DOMCSSStyleSheet *)[sender.mainFrameDocument.styleSheets item:0];
    DOMCSSRuleList *ruleList = sheet.cssRules;
    
    if (sender == self.webView) {
        [self.parsedRules removeAllObjects];
        for (unsigned int i = 0; i < ruleList.length; i++) {
            DOMCSSRule *rule = [ruleList item:i];
            [self.parsedRules addObject:rule];
            if (i == self.indexOfLastRule) {
                [self loadStyleRule:(DOMCSSStyleRule *)rule];
            }
        }
        [self.stylesOutlineView reloadData];
    }
}

- (void)parseContentTimer:(NSTimer *)timer {
    CSSParser *parser = [CSSParser parser];
    parser.delegate = self;
    
    NSString *cssText = timer.userInfo[@"string"];
    BOOL reload = [timer.userInfo[@"reload"] boolValue];
    [self.parsers addObject:parser];
    self.suppressTextViewSelectionChanged = YES;
    [parser parse:cssText shouldReloadAfterParse:reload];
}

- (void)parserDidFinish:(NSDictionary *)userInfo {
    NSArray *rules = userInfo[@"rules"];
    BOOL shouldReload = [userInfo[@"reload"] boolValue];
    
    self.suppressTextViewSelectionChanged = NO;
    
    [self.rulesDataSource removeAllObjects];
    [self.rulesDataSource addObjectsFromArray:rules];
    CGPoint origin = self.stylesOutlineView.enclosingScrollView.contentView.bounds.origin;
    [self.stylesOutlineView.enclosingScrollView.contentView scrollToPoint:origin];
    
    if (shouldReload) {
        NSDictionary *string = userInfo[@"string"];
        [self.webView.mainFrame loadHTMLString:[NSString stringWithFormat:@"<html><head><style>%@</style></head><body></body></html>", string] baseURL:nil];
    } else {
        [self.stylesOutlineView reloadData];
        NSDictionary *ruleDict = [self ruleDictWithIndex:self.indexOfLastRule rules:self.rulesDataSource];
        if (ruleDict[@"parent"]) {
            NSInteger parentIndex = [ruleDict[@"parent"] integerValue];
            for (NSDictionary *item in self.rulesDataSource) {
                if ([item[@"index"] integerValue] == parentIndex) {
                    [self.stylesOutlineView expandItem:item];
                    NSInteger row = [self.stylesOutlineView rowForItem:ruleDict];
                    self.suppressOutlineSelectionChanged = YES;
                    [self.stylesOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                    self.suppressOutlineSelectionChanged = NO;
                }
            }
        }
    }
}

- (void)scanAndParse {
    for (NSInteger i = self.parsers.count - 1; i > 0; i--) {
        CSSParser *parser = [self.parsers objectAtIndex:i];
        [parser cancel];
    }
    [self.parseTimer invalidate];
    self.parseTimer = nil;
    
    NSDictionary *userInfo = userInfo = @{@"string": self.textView.string, @"reload": @(YES)};
    self.parseTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(parseContentTimer:) userInfo:userInfo repeats:NO];
}

- (void)scan {
    for (NSInteger i = self.parsers.count - 1; i > 0; i--) {
        CSSParser *parser = [self.parsers objectAtIndex:i];
        [parser cancel];
    }
    [self.parseTimer invalidate];
    self.parseTimer = nil;
    NSDictionary *userInfo = userInfo = @{@"string": self.textView.string, @"reload": @(NO)};
    self.parseTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(parseContentTimer:) userInfo:userInfo repeats:NO];
}

#pragma mark - Loading / Saving Properties

- (void)resetStyleRule {
    [self.fontViewController clearControls];
    [self.textViewController clearControls];
    [self.backgroundViewController clearControls];
    [self.dimensionsViewController clearControls];
    [self.positioningViewController clearControls];
    [self.borderViewController clearControls];
}

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule {
    [self.fontViewController loadStyleRule:styleRule];
    [self.textViewController loadStyleRule:styleRule];
    [self.backgroundViewController loadStyleRule:styleRule];
    [self.dimensionsViewController loadStyleRule:styleRule];
    [self.positioningViewController loadStyleRule:styleRule];
    [self.borderViewController loadStyleRule:styleRule];
}

- (void)loadValue:(NSString *)value textControl:(NSTextField *)textField unitsControl:(NSPopUpButton *)popUpButton {
    // Find keywords
    NSMutableArray *keywords = [NSMutableArray array];
    if ([popUpButton.itemTitles containsObject:@"Keyword"]) {
        for (NSInteger i = popUpButton.numberOfItems-1; i >= 0; i--) {
            NSString *title = [popUpButton itemTitleAtIndex:i];
            if ([title isEqualToString:@"Keyword"]) {
                break;
            }
            [keywords addObject:title];
        }
    }
    if ([popUpButton.itemTitles containsObject:@"inherit"]) {
        [keywords addObject:@"inherit"];
    }
    if ([popUpButton.itemTitles containsObject:@"initial"]) {
        [keywords addObject:@"initial"];
    }
    
    if ([keywords containsObject:value]) {
        [popUpButton selectItemWithTitle:value];
    } else {
        NSArray *unitsArray = @[@"rem", @"em", @"ex", @"ch", @"vw", @"vh", @"vmin", @"vmax", @"cm", @"mm", @"in", @"px", @"pt", @"pc", @"%"];
        NSString *number = @"";
        NSString *units = @"";
        for (units in unitsArray) {
            if ([value hasSuffix:units]) {
                number = [value stringByReplacingOccurrencesOfString:units withString:@""];
                break;
            }
        }
        [self setIfNotFirstResponder:textField string:number];
        [popUpButton selectItemWithTitle:units];
    }
}

- (void)changeProperty:(NSString *)property textControl:(NSTextField *)textField unitsControl:(NSPopUpButton *)popUpButton keywords:(NSArray *)keywords {
    if ([popUpButton.titleOfSelectedItem isEqualToString:@"unchanged"]) {
        [self removeProperty:property fromStyle:YES];
    } else {
        NSString *value;
        if ([keywords containsObject:popUpButton.titleOfSelectedItem]) {
            value = popUpButton.titleOfSelectedItem;
            textField.stringValue = @"";
        } else {
            if (textField.stringValue.length == 0) {
                textField.stringValue = @"0";
            }
            value = [NSString stringWithFormat:@"%@%@", textField.stringValue, popUpButton.titleOfSelectedItem];
        }
        [self replaceProperty:property value:value inStyle:YES];
    }
}

- (void)changeProperty:(NSString *)property popUpControl:(NSPopUpButton *)popUpButton {
    NSArray *keywords = [popUpButton.itemTitles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    if ([popUpButton.titleOfSelectedItem isEqualToString:@"unchanged"]) {
        [self removeProperty:property fromStyle:YES];
    } else {
        NSString *value;
        if ([keywords containsObject:popUpButton.titleOfSelectedItem]) {
            value = popUpButton.titleOfSelectedItem;
        }
        [self replaceProperty:property value:value inStyle:YES];
    }
}

- (void)removeProperty:(NSString *)prop fromStyle:(BOOL)removeFromStyle {
    NSMutableDictionary *ruleDict = [self ruleDictWithIndex:self.indexOfLastRule rules:self.rulesDataSource];
    if (!ruleDict)
        return;
    if (ruleDict[@"index"] && ruleDict[@"range"]) {
        NSInteger index = [ruleDict[@"index"] integerValue];
        DOMCSSStyleRule *styleRule = self.parsedRules[index];
        
        if (removeFromStyle) {
            [styleRule.style removeProperty:prop];
        }
        
        NSRange range = NSRangeFromString(ruleDict[@"range"]);
        NSString *cssText = [self.textView.string substringWithRange:range];
        NSRange replaceRange = [self rangeOfProperty:prop string:cssText includingProp:YES includingTerminator:YES];
        if (replaceRange.location == NSNotFound)
            return;
        for (NSInteger i = replaceRange.location-1; i >= 0; i--) {
            unichar c = [cssText characterAtIndex:i];
            if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c]) {
                replaceRange.location--;
                replaceRange.length++;
            } else {
                break;
            }
        }
        
        // Adjust range
        ruleDict[@"range"] = NSStringFromRange(NSMakeRange(range.location, range.length-replaceRange.length));
        
        self.suppressParseOnProcessEditing = YES;
        self.suppressTextViewSelectionChanged = YES;
        
        [self.textView.textStorage replaceCharactersInRange:NSMakeRange(range.location+replaceRange.location, replaceRange.length) withString:@""];
        
        self.suppressParseOnProcessEditing = NO;
        self.suppressTextViewSelectionChanged = NO;
        
    }
}

- (void)addProperty:(NSString *)prop value:(NSString *)val {
    NSMutableDictionary *ruleDict = [self ruleDictWithIndex:self.indexOfLastRule rules:self.rulesDataSource];
    if (!ruleDict)
        return;
    if (ruleDict[@"index"] && ruleDict[@"range"]) {
        NSInteger index = [ruleDict[@"index"] integerValue];
        DOMCSSStyleRule *styleRule = self.parsedRules[index];
        [styleRule.style setProperty:prop value:val priority:@""];
        
        NSRange range = NSRangeFromString(ruleDict[@"range"]);
        NSInteger pos = NSMaxRange(range)-1;
        
        NSDictionary *attrs = @{NSFontAttributeName: self.textView.font};
        NSAttributedString *newText;
        
        NSInteger i;
        for (i = pos-1 ; i > 0; i--) {
            if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self.textView.string characterAtIndex:i]]) {
                break;
            }
        }
        
        // Try to preserve whitespace
        NSMutableString *ws = [NSMutableString string];
        NSString *block = [self.textView.string substringWithRange:NSRangeFromString(ruleDict[@"blockRange"])];
        for (NSInteger j = 0; j < block.length; j++) {
            unichar c = [block characterAtIndex:j];
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:c]) {
                [ws appendString:[NSString stringWithFormat:@"%c", c]];
            } else if ([[NSCharacterSet newlineCharacterSet] characterIsMember:c]) {
            } else {
                break;
            }
        }
        
        NSRange propRange, valRange;
        if ([self.textView.string characterAtIndex:i] == ';') {
            // The last character is a semicolon, don't add one
            newText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@%@: %@;", ws, prop, val] attributes:attrs];
            propRange = NSMakeRange(i+2, prop.length + ws.length);
        } else if ([self.textView.string characterAtIndex:i] == '{') {
            // The last character is an open brace--the rule is empty so add default whitespace
            newText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n    %@%@: %@;", ws, prop, val] attributes:attrs];
            propRange = NSMakeRange(i+6, prop.length + ws.length);
        } else {
            // Add a closing semicolon before the new rule
            newText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@";\n%@%@: %@;", ws, prop, val] attributes:attrs];
            propRange = NSMakeRange(i+3, prop.length + ws.length);
        }
        valRange = NSMakeRange(NSMaxRange(propRange)+2, val.length);
        
        // Adjust range
        ruleDict[@"range"] = NSStringFromRange(NSMakeRange(range.location, range.length+newText.length));
        
        self.suppressParseOnProcessEditing = YES;
        self.suppressTextViewSelectionChanged = YES;
        [self.textView.textStorage insertAttributedString:newText atIndex:i+1];
        for (NSLayoutManager *layoutManager in self.textView.textStorage.layoutManagers) {
            [layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName:CSS_PROPERTY_COLOR} forCharacterRange:propRange];
            [layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName:CSS_VALUE_COLOR} forCharacterRange:valRange];
        }
        self.textView.selectedRange = NSMakeRange(pos, 0);
        self.suppressTextViewSelectionChanged = NO;
        self.suppressParseOnProcessEditing = NO;
    }
}

- (void)replaceProperty:(NSString *)prop value:(NSString *)val inStyle:(BOOL)replaceInStyle {
    NSMutableDictionary *ruleDict = [self ruleDictWithIndex:self.indexOfLastRule rules:self.rulesDataSource];
    if (!ruleDict)
        return;
    if (ruleDict[@"index"] && ruleDict[@"range"]) {
        NSInteger index = [ruleDict[@"index"] integerValue];
        DOMCSSStyleRule *styleRule = self.parsedRules[index];
        
        if (replaceInStyle) {
            NSString *priority = [styleRule.style getPropertyPriority:prop];
            [styleRule.style setProperty:prop value:val priority:priority];
        }
        
        NSRange range = NSRangeFromString(ruleDict[@"range"]);
        NSString *cssText = [self.textView.string substringWithRange:range];
        
        NSRange replaceRange = [self rangeOfProperty:prop string:cssText includingProp:NO includingTerminator:NO];
        if (replaceRange.location == NSNotFound) {
            [self addProperty:prop value:val];
            return;
        }
        NSString *newString = [NSString stringWithFormat:@" %@", val];
        
        // Adjust range
        ruleDict[@"range"] = NSStringFromRange(NSMakeRange(range.location, range.length-(replaceRange.length-newString.length)));
        
        self.suppressParseOnProcessEditing = YES;
        self.suppressTextViewSelectionChanged = YES;
        [self.textView replaceCharactersInRange:NSMakeRange(range.location+replaceRange.location, replaceRange.length) withString:newString];
        for (NSLayoutManager *layoutManager in self.textView.textStorage.layoutManagers) {
            [layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName: CSS_VALUE_COLOR} forCharacterRange:NSMakeRange(range.location+replaceRange.location, newString.length)];
        }
        self.suppressParseOnProcessEditing = NO;
        self.suppressTextViewSelectionChanged = NO;
    }
}

- (NSString *)valueOfProperty:(NSString *)prop string:(NSString *)cssText {
    NSString *regex = [NSString stringWithFormat:@"(?<!-)%@\\s*:", prop];
    NSRange startRange = [cssText rangeOfRegex:regex options:RKLCaseless inRange:NSMakeRange(0, cssText.length) capture:0 error:NULL];
    if (startRange.location == NSNotFound)
        return nil;
    NSInteger startPos = NSMaxRange(startRange);
    NSInteger endPos;
    unichar skipUntilChar = '\0';
    unichar skipUntilChar2 = '\0';
    for (endPos = startPos; endPos < cssText.length; endPos++) {
        unichar c = [cssText characterAtIndex:endPos];
        if (c == skipUntilChar) {
            if (skipUntilChar2 != '\0') {
                if (endPos+1 < cssText.length && [cssText characterAtIndex:endPos+1] == skipUntilChar2) {
                    skipUntilChar = '\0';
                    skipUntilChar2 = '\0';
                }
            } else {
                skipUntilChar = '\0';
            }
        }
        if (skipUntilChar != '\0')
            continue;
        if (c == '(') {
            skipUntilChar = ')';
        } else if (c == '"') {
            skipUntilChar = '"';
        } else if (c == '\'') {
            skipUntilChar = '\'';
        } else if (c == '/' && endPos+1 < cssText.length && [cssText characterAtIndex:endPos+1] == '*') {
            skipUntilChar = '*';
            skipUntilChar2 = '/';
        } else if (c == ';' || c == '}') {
            break;
        }
    }
    NSRange range = NSMakeRange(startPos, endPos - startPos);
    if (NSMaxRange(range) > cssText.length)
        return nil;
    return [[cssText substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSRange)rangeOfProperty:(NSString *)prop string:(NSString *)cssText includingProp:(BOOL)includeProperty includingTerminator:(BOOL)includeTerminator {
    NSString *regex = [NSString stringWithFormat:@"(?<!-)%@\\s*:", prop];
    NSRange startRange = [cssText rangeOfRegex:regex options:RKLCaseless inRange:NSMakeRange(0, cssText.length) capture:0 error:NULL];
    if (startRange.location == NSNotFound)
        return NSMakeRange(NSNotFound, 0);
    NSInteger startPos = includeProperty ? startRange.location : NSMaxRange(startRange);
    NSInteger endPos;
    for (endPos = startPos; endPos < cssText.length; endPos++) {
        unichar c = [cssText characterAtIndex:endPos];
        if (c == '}' || c == ';' || c == '!') {
            if (includeTerminator) {
                endPos++;
            }
            break;
        } else {
            if (c == '"' || c =='\'') {
                if (endPos+1 < cssText.length) {
                    for (NSInteger j = endPos+1; j < cssText.length; j++) {
                        unichar cc = [cssText characterAtIndex:j];
                        if (cc == '"' || cc == '\'') {
                            if (j+1 < cssText.length) {
                                endPos = j+1;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return NSMakeRange(startPos, endPos-startPos);
}

- (DOMCSSStyleRule *)currentStyleRule {
    NSDictionary *ruleDict = [self ruleDictWithIndex:self.indexOfLastRule rules:self.rulesDataSource];
    if (!ruleDict)
        return nil;
    NSInteger index = [ruleDict[@"index"] integerValue];
    DOMCSSStyleRule *styleRule = self.parsedRules[index];
    return styleRule;
}

- (NSMutableDictionary *)ruleDictWithIndex:(NSInteger)index rules:(NSArray *)rules {
    for (NSMutableDictionary *ruleDict in rules) {
        if ([ruleDict[@"index"] integerValue] == index) {
            return ruleDict;
        }
        if ([ruleDict[@"type"] isEqualToString:@"media"]) {
            for (NSMutableDictionary *ruleDict2 in ruleDict[@"rules"]) {
                if ([ruleDict2[@"index"] integerValue] == index) {
                    return ruleDict2;
                }
                if ([ruleDict2[@"type"] isEqualToString:@"media"]) {
                    for (NSMutableDictionary *ruleDict3 in ruleDict2[@"rules"]) {
                        if ([ruleDict3[@"index"] integerValue] == index) {
                            return ruleDict3;
                        }
                    }
                }
            }
        }
    }
    return nil;
}

- (void)applyFontShorthandForRule:(DOMCSSStyleRule *)styleRule {
    if (styleRule.style.font.length > 0) {
        [self removeProperty:@"font-style" fromStyle:NO];
        [self removeProperty:@"font-variant" fromStyle:NO];
        [self removeProperty:@"font-weight" fromStyle:NO];
        [self removeProperty:@"font-size" fromStyle:NO];
        [self removeProperty:@"line-height" fromStyle:NO];
        [self removeProperty:@"font-family" fromStyle:NO];
        
        NSMutableString *fontString = [NSMutableString string];
        if (styleRule.style.fontStyle.length > 0 && ![styleRule.style.fontStyle isEqualToString:@"normal"]) {
            [fontString appendFormat:@" %@", styleRule.style.fontStyle];
        }
        if (styleRule.style.fontVariant.length > 0 && ![styleRule.style.fontVariant isEqualToString:@"normal"]) {
            [fontString appendFormat:@" %@", styleRule.style.fontVariant];
        }
        if (styleRule.style.fontWeight.length > 0 && ![styleRule.style.fontWeight isEqualToString:@"normal"]) {
            [fontString appendFormat:@" %@", styleRule.style.fontWeight];
        }
        [fontString appendFormat:@" %@", styleRule.style.fontSize];
        if (styleRule.style.lineHeight.length > 0 && ![styleRule.style.lineHeight isEqualToString:@"normal"]) {
            [fontString appendFormat:@"/%@", styleRule.style.lineHeight];
        }
        [fontString appendFormat:@" %@", styleRule.style.fontFamily];
        [self replaceProperty:@"font" value:[fontString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] inStyle:NO];
        [self loadStyleRule:styleRule];
    } else {
        [self removeProperty:@"font" fromStyle:NO];
        
        if (styleRule.style.fontStyle.length > 0) {
            [self replaceProperty:@"font-style" value:styleRule.style.fontStyle inStyle:NO];
        }
        if (styleRule.style.fontVariant.length > 0) {
            [self replaceProperty:@"font-variant" value:styleRule.style.fontVariant inStyle:NO];
        }
        if (styleRule.style.fontWeight.length > 0) {
            [self replaceProperty:@"font-weight" value:styleRule.style.fontWeight inStyle:NO];
        }
        if (styleRule.style.fontSize.length > 0) {
            [self replaceProperty:@"font-size" value:styleRule.style.fontSize inStyle:NO];
        }
        if (styleRule.style.lineHeight.length > 0) {
            [self replaceProperty:@"line-height" value:styleRule.style.lineHeight inStyle:NO];
        }
        if (styleRule.style.fontFamily.length > 0) {
            [self replaceProperty:@"font-family" value:styleRule.style.fontFamily inStyle:NO];
        }
        
        [self loadStyleRule:styleRule];
    }
}

- (void)setIfNotFirstResponder:(NSControl *)control string:(NSString *)string {
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if (!([firstResponder isKindOfClass:[NSText class]] && (NSTextField *)[(NSText *)firstResponder delegate] == control)) {
        [control setStringValue:string];
    }
}

- (void)clearIfNotFirstResponder:(NSControl *)control {
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if (!([firstResponder isKindOfClass:[NSText class]] && (NSTextField *)[(NSText *)firstResponder delegate] == control)) {
        [control setStringValue:@""];
    }
}

- (void)disableIfNotFirstResponder:(NSControl *)control {
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if (!([firstResponder isKindOfClass:[NSText class]] && (NSTextField *)[(NSText *)firstResponder delegate] == control)) {
        [control setEnabled:NO];
    }
}

- (NSString *)replaceRGBColorWithHexString:(NSString *)value {
    if (value) {
        value = [value stringByReplacingOccurrencesOfRegex:@"rgb\\(.*?\\)" usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            NSColor *color = [NSColor colorWithCSS:capturedStrings[0]];
            if (color) {
                return color.hexStringValue;
            }
            return capturedStrings[0];
        }];
    }
    return value;
}

- (void)saveColorTimerFired:(NSTimer *)timer {
    NSDictionary *userInfo = timer.userInfo;
    ColorTextField *textField = userInfo[@"control"];
    NSColor *color = userInfo[@"color"];
    NSArray *recentColors = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentColors"];
    NSMutableArray *newRecentColors = [NSMutableArray array];
    if (recentColors) {
        [newRecentColors addObjectsFromArray:recentColors];
    }
    [newRecentColors addObject:color.formattedString];
    if (newRecentColors.count > 5) {
        [newRecentColors removeObjectAtIndex:0];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newRecentColors forKey:@"recentColors"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [textField reload];
}

- (void)saveColor:(NSColor *)color reloadControl:(ColorTextField *)textField {
    [self.saveColorTimer invalidate];
    self.saveColorTimer = nil;
    self.saveColorTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(saveColorTimerFired:) userInfo:@{@"control": textField, @"color": color} repeats:NO];
}

@end
