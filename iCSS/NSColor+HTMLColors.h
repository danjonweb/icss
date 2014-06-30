//
//  NSColor+HTMLColors.h
//  iCSS
//
//  Created by Daniel Weber on 1/28/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, HTMLColorType) {
    HTMLColorUnknownType = 0,
    HTMLColorHexType = 1,
    HTMLColorRGBType = 2,
    HTMLColorRGBAType = 3,
    HTMLColorHSLType = 4,
    HTMLColorHSLAType = 5,
    HTMLColorNamedType = 6
};

@interface NSColor (HTMLColors)

+ (NSColor *)colorWithCSS:(NSString *)cssColor;
+ (NSColor *)colorWithHexString:(NSString *)hexColor;
+ (NSColor *)colorWithRGBString:(NSString *)rgbColor;
+ (NSColor *)colorWithHSLString:(NSString *)hslColor;
+ (NSColor *)colorWithW3CNamedColor:(NSString *)namedColor;
- (NSString *)hexStringValue;
- (NSString *)rgbStringValue;
- (NSString *)hslStringValue;
- (NSString *)formattedString;
+ (NSArray *)W3CColorNames;
+ (NSDictionary *)W3CColors;

@property HTMLColorType type;

@end

@interface NSScanner (HTMLColors)

- (BOOL)scanCSSColor:(NSColor **)color;
- (BOOL)scanRGBColor:(NSColor **)color;
- (BOOL)scanHSLColor:(NSColor **)color;
- (BOOL)scanHexColor:(NSColor **)color;
- (BOOL)scanW3CNamedColor:(NSColor **)color;

@end

@interface NSString (HTMLColors)
- (NSString *)formattedString;
@end