//
//  NSColor+HTMLColors.m
//  iCSS
//
//  Created by Daniel Weber on 1/28/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "NSColor+HTMLColors.h"
#import <objc/runtime.h>

typedef struct {
    CGFloat a, b, c;
} CMRFloatTriple;

typedef struct {
    CGFloat a, b, c, d;
} CMRFloatQuad;

// CSS uses HSL, but we have to specify UIColor as HSB
static inline CMRFloatTriple HSB2HSL(CGFloat hue, CGFloat saturation, CGFloat brightness);
static inline CMRFloatTriple HSL2HSB(CGFloat hue, CGFloat saturation, CGFloat lightness);

static NSArray *CMRW3CColorNames(void);
static NSDictionary *CMRW3CNamedColors(void);

static char const * const ObjectTagKey = "ObjectTag";

@implementation NSColor (HTMLColors)

- (void)setType:(HTMLColorType)type
{
    NSNumber *number = [NSNumber numberWithInteger:type];
    objc_setAssociatedObject(self, ObjectTagKey, number , OBJC_ASSOCIATION_RETAIN);
}

- (HTMLColorType)type
{
    NSNumber *number = objc_getAssociatedObject(self, ObjectTagKey);
    return [number integerValue];
}

#pragma mark - Reading

+ (NSColor *)colorWithCSS:(NSString *)cssColor
{
    NSColor *color = nil;
    NSScanner *scanner = [NSScanner scannerWithString:cssColor];
    [scanner scanCSSColor:&color];
    return (scanner.isAtEnd) ? color : nil;
}

+ (NSColor *)colorWithHexString:(NSString *)hexColor
{
    NSColor *color = nil;
    NSScanner *scanner = [NSScanner scannerWithString:hexColor];
    [scanner scanHexColor:&color];
    return (scanner.isAtEnd) ? color : nil;
}

+ (NSColor *)colorWithRGBString:(NSString *)rgbColor
{
    NSColor *color = nil;
    NSScanner *scanner = [NSScanner scannerWithString:rgbColor];
    [scanner scanRGBColor:&color];
    return (scanner.isAtEnd) ? color : nil;
}

+ (NSColor *)colorWithHSLString:(NSString *)hslColor
{
    NSColor *color = nil;
    NSScanner *scanner = [NSScanner scannerWithString:hslColor];
    [scanner scanHSLColor:&color];
    return (scanner.isAtEnd) ? color : nil;
}

+ (NSColor *)colorWithW3CNamedColor:(NSString *)namedColor
{
    NSColor *color = nil;
    NSScanner *scanner = [NSScanner scannerWithString:namedColor];
    [scanner scanW3CNamedColor:&color];
    return (scanner.isAtEnd) ? color : nil;
}

#pragma mark - Writing

static inline unsigned ToByte(CGFloat f)
{
    f = MAX(0, MIN(f, 1)); // Clamp
    return (unsigned)round(f * 255);
}

- (NSString *)hexStringValue
{
    NSString *hex = nil;
    CGFloat red, green, blue, alpha;
    if ([self cmr_getRed:&red green:&green blue:&blue alpha:&alpha]) {
        hex = [NSString stringWithFormat:@"#%02X%02X%02X",
               ToByte(red), ToByte(green), ToByte(blue)];
    }
    return hex;
}

- (NSString *)rgbStringValue
{
    NSString *rgb = nil;
    CGFloat red, green, blue, alpha;
    if ([self cmr_getRed:&red green:&green blue:&blue alpha:&alpha]) {
        if (alpha == 1.0) {
            rgb = [NSString stringWithFormat:@"rgb(%u, %u, %u)",
                   ToByte(red), ToByte(green), ToByte(blue)];
        } else {
            rgb = [NSString stringWithFormat:@"rgba(%u, %u, %u, %g)",
                   ToByte(red), ToByte(green), ToByte(blue), alpha];
        }
    }
    return rgb;
}

- (NSString *)formattedString {
    if (self.alphaComponent == 1.0) {
        NSDictionary *colorNameDict = [NSColor W3CColors];
        NSString *hexString = self.hexStringValue;
        if ([colorNameDict objectForKey:hexString]) {
            return colorNameDict[hexString];
        } else {
            return self.hexStringValue;
        }
    } else {
        return self.rgbStringValue;
    }
}

static inline unsigned ToDeg(CGFloat f)
{
    return (unsigned)round(f * 360) % 360;
}

static inline unsigned ToPercentage(CGFloat f)
{
    f = MAX(0, MIN(f, 1)); // Clamp
    return (unsigned)round(f * 100);
}

- (NSString *)hslStringValue
{
    NSString *hsl = nil;
    CGFloat hue, saturation, brightness, alpha;
    if ([self cmr_getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        CMRFloatTriple hslVal = HSB2HSL(hue, saturation, brightness);
        if (alpha == 1.0) {
            hsl = [NSString stringWithFormat:@"hsl(%u, %u%%, %u%%)",
                   ToDeg(hslVal.a), ToPercentage(hslVal.b), ToPercentage(hslVal.c)];
        } else {
            hsl = [NSString stringWithFormat:@"hsla(%u, %u%%, %u%%, %g)",
                   ToDeg(hslVal.a), ToPercentage(hslVal.b), ToPercentage(hslVal.c), alpha];
        }
    }
    return hsl;
}

// Fix up getting color components
- (BOOL)cmr_getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    /*if ([self getRed:red green:green blue:blue alpha:alpha]) {
        return YES;
    }
    
    CGFloat white;
    if ([self getWhite:&white alpha:alpha]) {
        if (red)
            *red = white;
        if (green)
            *green = white;
        if (blue)
            *blue = white;
        return YES;
    }
    
    return NO;*/
    
    if (self.alphaComponent == 0.0) {
        *red = 0.0;
        *green = 0.0;
        *blue = 0.0;
        *alpha = 0.0;
        return YES;
    }
    NSColor *rgbColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (rgbColor) {
        [self getRed:red green:green blue:blue alpha:alpha];
        return YES;
    }
    return NO;
}

- (BOOL)cmr_getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha
{
    /*if ([self getHue:hue saturation:saturation brightness:brightness alpha:alpha]) {
        return YES;
    }
    
    CGFloat white;
    if ([self getWhite:&white alpha:alpha]) {
        if (hue)
            *hue = 0;
        if (saturation)
            *saturation = 0;
        if (brightness)
            *brightness = white;
        return YES;
    }
    
    return NO;*/
    
    NSColor *rgbColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (rgbColor) {
        [self getHue:hue saturation:saturation brightness:brightness alpha:alpha];
        return YES;
    }
    return NO;
}

+ (NSArray *)W3CColorNames
{
    return [[CMRW3CNamedColors() allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSDictionary *)W3CColors {
    return @{@"#FFDAB9" : @"peachpuff", @"#00FF7F" : @"springgreen", @"#4169E1" : @"royalblue", @"#008B8B" : @"darkcyan", @"#FFF0F5" : @"lavenderblush", @"#191970" : @"midnightblue", @"#FF00FF" : @"magenta", @"#F5F5F5" : @"whitesmoke", @"#FFA07A" : @"lightsalmon", @"#0000FF" : @"blue", @"#808080" : @"gray", @"#FFDEAD" : @"navajowhite", @"#696969" : @"dimgray", @"#483D8B" : @"darkslateblue", @"#00FA9A" : @"mediumspringgreen", @"#BDB76B" : @"darkkhaki", @"#F5F5DC" : @"beige", @"#98FB98" : @"palegreen", @"#40E0D0" : @"turquoise", @"#FFC0CB" : @"pink", @"#9400D3" : @"darkviolet", @"#6B8E23" : @"olivedrab", @"#48D1CC" : @"mediumturquoise", @"#F0F8FF" : @"aliceblue", @"#B0E0E6" : @"powderblue", @"#B0C4DE" : @"lightsteelblue", @"#FFF5EE" : @"seashell", @"#FFF8DC" : @"cornsilk", @"#556B2F" : @"darkolivegreen", @"#E6E6FA" : @"lavender", @"#708090" : @"slategray", @"#8B4513" : @"saddlebrown", @"#5F9EA0" : @"cadetblue", @"#EEE8AA" : @"palegoldenrod", @"#2F4F4F" : @"darkslategray", @"#FF7F50" : @"coral", @"#ADD8E6" : @"lightblue", @"#DB7093" : @"palevioletred", @"#F4A460" : @"sandybrown", @"#E9967A" : @"darksalmon", @"#C0C0C0" : @"silver", @"#708090" : @"slategrey", @"#00CED1" : @"darkturquoise", @"#FFEBCD" : @"blanchedalmond", @"#ADFF2F" : @"greenyellow", @"#FFFFF0" : @"ivory", @"#6495ED" : @"cornflowerblue", @"#00008B" : @"darkblue", @"#F0FFF0" : @"honeydew", @"#BC8F8F" : @"rosybrown", @"#7FFF00" : @"chartreuse", @"#00FFFF" : @"aqua", @"#8B008B" : @"darkmagenta", @"#3CB371" : @"mediumseagreen", @"#FF6347" : @"tomato", @"#7FFFD4" : @"aquamarine", @"#8A2BE2" : @"blueviolet", @"#E0FFFF" : @"lightcyan", @"#32CD32" : @"limegreen", @"#228B22" : @"forestgreen", @"#DCDCDC" : @"gainsboro", @"#CD5C5C" : @"indianred", @"#7CFC00" : @"lawngreen", @"#FF0000" : @"red", @"#D2691E" : @"chocolate", @"#696969" : @"dimgrey", @"#7B68EE" : @"mediumslateblue", @"#DDA0DD" : @"plum", @"#2E8B57" : @"seagreen", @"#FFFAFA" : @"snow", @"#90EE90" : @"lightgreen", @"#FFB6C1" : @"lightpink", @"#00BFFF" : @"deepskyblue", @"#A52A2A" : @"brown", @"#EE82EE" : @"violet", @"#F08080" : @"lightcoral", @"#F5FFFA" : @"mintcream", @"#9370DB" : @"mediumpurple", @"#A9A9A9" : @"darkgrey", @"#D2B48C" : @"tan", @"#9ACD32" : @"yellowgreen", @"#006400" : @"darkgreen", @"#FFFFE0" : @"lightyellow", @"#FDF5E6" : @"oldlace", @"#FFE4B5" : @"moccasin", @"#F0FFFF" : @"azure", @"#778899" : @"lightslategrey", @"#000080" : @"navy", @"#DC143C" : @"crimson", @"#4682B4" : @"steelblue", @"#0000CD" : @"mediumblue", @"#87CEFA" : @"lightskyblue", @"#FFFACD" : @"lemonchiffon", @"#F0E68C" : @"khaki", @"#66CDAA" : @"mediumaquamarine", @"#FFFF00" : @"yellow", @"#2F4F4F" : @"darkslategrey", @"#8FBC8F" : @"darkseagreen", @"#C71585" : @"mediumvioletred", @"#DA70D6" : @"orchid", @"#000000" : @"black", @"#FFFAF0" : @"floralwhite", @"#D3D3D3" : @"lightgray", @"#CD853F" : @"peru", @"#008080" : @"teal", @"#808080" : @"grey", @"#B8860B" : @"darkgoldenrod", @"#B22222" : @"firebrick", @"#FFE4C4" : @"bisque", @"#9932CC" : @"darkorchid", @"#FF8C00" : @"darkorange", @"#A0522D" : @"sienna", @"#D3D3D3" : @"lightgrey", @"#800080" : @"purple", @"#FFFFFF" : @"white", @"#20B2AA" : @"lightseagreen", @"#00FF00" : @"lime", @"#DEB887" : @"burlywood", @"#FFD700" : @"gold", @"#808000" : @"olive", @"#6A5ACD" : @"slateblue", @"#F5DEB3" : @"wheat", @"#AFEEEE" : @"paleturquoise", @"#F8F8FF" : @"ghostwhite", @"#D8BFD8" : @"thistle", @"#87CEEB" : @"skyblue", @"#778899" : @"lightslategray", @"#FFA500" : @"orange", @"#FAF0E6" : @"linen", @"#00FFFF" : @"cyan", @"#FFEFD5" : @"papayawhip", @"#FAFAD2" : @"lightgoldenrodyellow", @"#FF4500" : @"orangered", @"#1E90FF" : @"dodgerblue", @"#8B0000" : @"darkred", @"#008000" : @"green", @"#FFE4E1" : @"mistyrose", @"#DAA520" : @"goldenrod", @"#FAEBD7" : @"antiquewhite", @"#A9A9A9" : @"darkgray", @"#FF00FF" : @"fuchsia", @"#FA8072" : @"salmon", @"#4B0082" : @"indigo", @"#800000" : @"maroon", @"#FF69B4" : @"hotpink", @"#BA55D3" : @"mediumorchid", @"#FF1493" : @"deeppink"};
}

@end

@implementation NSString (HTMLColors)

- (NSString *)formattedString {
    NSColor *color = [NSColor colorWithCSS:self];
    return color.formattedString;
}

@end

@implementation NSScanner (HTMLColors)

- (BOOL)scanCSSColor:(NSColor **)color
{
    return [self scanHexColor:color]
    || [self scanRGBColor:color]
    || [self scanHSLColor:color]
    || [self cmr_scanTransparent:color]
    || [self scanW3CNamedColor:color];
}

- (BOOL)scanRGBColor:(NSColor **)color
{
    return [self cmr_caseInsensitiveWithCleanup:^BOOL{
        if ([self scanString:@"rgba" intoString:NULL]) {
            CMRFloatQuad scale = {1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0};
            CMRFloatQuad q;
            if ([self cmr_scanFloatQuad:&q scale:scale]) {
                if (color) {
                    *color = [NSColor colorWithCalibratedRed:q.a green:q.b blue:q.c alpha:q.d];
                    //*color = [NSColor colorWithRed:q.a green:q.b blue:q.c alpha:q.d];
                }
                [*color setType:HTMLColorRGBAType];
                return YES;
            }
        } else if ([self scanString:@"rgb" intoString:NULL]) {
            CMRFloatTriple scale = {1.0/255.0, 1.0/255.0, 1.0/255.0};
            CMRFloatTriple t;
            if ([self cmr_scanFloatTriple:&t scale:scale]) {
                if (color) {
                    *color = [NSColor colorWithCalibratedRed:t.a green:t.b blue:t.c alpha:1.0];
                    //*color = [NSColor colorWithRed:t.a green:t.b blue:t.c alpha:1.0];
                }
                [*color setType:HTMLColorRGBType];
                return YES;
            }
        }
        return NO;
    }];
}

// Wrap hues in a circle, where [0,1] = [0°,360°]
static inline CGFloat CMRNormHue(CGFloat hue)
{
    return hue - floor(hue);
}

- (BOOL)scanHSLColor:(NSColor **)color
{
    return [self cmr_caseInsensitiveWithCleanup:^BOOL{
        if ([self scanString:@"hsla" intoString:NULL]) {
            CMRFloatQuad scale = {1.0/360.0, 1.0, 1.0, 1.0};
            CMRFloatQuad q;
            if ([self cmr_scanFloatQuad:&q scale:scale]) {
                if (color) {
                    CMRFloatTriple t = HSL2HSB(CMRNormHue(q.a), q.b, q.c);
                    *color = [NSColor colorWithCalibratedHue:t.a saturation:t.b brightness:t.c alpha:q.d];
                    //*color = [NSColor colorWithHue:t.a saturation:t.b brightness:t.c alpha:q.d];
                }
                [*color setType:HTMLColorHSLAType];
                return YES;
            }
        } else if ([self scanString:@"hsl" intoString:NULL]) {
            CMRFloatTriple scale = {1.0/360.0, 1.0, 1.0};
            CMRFloatTriple t;
            if ([self cmr_scanFloatTriple:&t scale:scale]) {
                if (color) {
                    t = HSL2HSB(CMRNormHue(t.a), t.b, t.c);
                    *color = [NSColor colorWithCalibratedHue:t.a saturation:t.b brightness:t.c alpha:1.0];
                    //*color = [NSColor colorWithHue:t.a saturation:t.b brightness:t.c alpha:1.0];
                }
                [*color setType:HTMLColorHSLType];
                return YES;
            }
        }
        return NO;
    }];
}

- (BOOL)scanHexColor:(NSColor **)color
{
    return [self cmr_resetScanLocationOnFailure:^BOOL{
        return [self scanString:@"#" intoString:NULL]
        && [self cmr_scanHexTriple:color];
    }];
}

- (BOOL)scanW3CNamedColor:(NSColor **)color
{
    return [self cmr_caseInsensitiveWithCleanup:^BOOL{
        NSArray *colorNames = CMRW3CColorNames();
        NSDictionary *namedColors = CMRW3CNamedColors();
        for (NSString *name in colorNames) {
            if ([self scanString:name intoString:NULL]) {
                if (color) {
                    *color = [NSColor colorWithHexString:namedColors[name]];
                }
                [*color setType:HTMLColorNamedType];
                return YES;
            }
        }
        return NO;
    }];
}

#pragma mark - Private

- (void)cmr_withSkip:(NSCharacterSet *)chars run:(void (^)(void))block
{
    NSCharacterSet *skipped = self.charactersToBeSkipped;
    self.charactersToBeSkipped = chars;
    block();
    self.charactersToBeSkipped = skipped;
}

- (void)cmr_withNoSkip:(void (^)(void))block
{
    NSCharacterSet *skipped = self.charactersToBeSkipped;
    self.charactersToBeSkipped = nil;
    block();
    self.charactersToBeSkipped = skipped;
}

- (NSRange)cmr_rangeFromScanLocation
{
    NSUInteger loc = self.scanLocation;
    NSUInteger len = self.string.length - loc;
    return NSMakeRange(loc, len);
}

- (void)cmr_skipCharactersInSet:(NSCharacterSet *)chars
{
    [self cmr_withNoSkip:^{
        [self scanCharactersFromSet:chars intoString:NULL];
    }];
}

- (void)cmr_skip
{
    [self cmr_skipCharactersInSet:self.charactersToBeSkipped];
}

- (BOOL)cmr_resetScanLocationOnFailure:(BOOL (^)(void))block
{
    NSUInteger initialScanLocation = self.scanLocation;
    if (!block()) {
        self.scanLocation = initialScanLocation;
        return NO;
    }
    return YES;
}

- (BOOL)cmr_caseInsensitiveWithCleanup:(BOOL (^)(void))block
{
    NSUInteger initialScanLocation = self.scanLocation;
    BOOL caseSensitive = self.caseSensitive;
    self.caseSensitive = NO;
    
    BOOL success = block();
    if (!success) {
        self.scanLocation = initialScanLocation;
    }
    
    self.caseSensitive = caseSensitive;
    return success;
}

// Scan, but only so far
- (NSRange)cmr_scanCharactersInSet:(NSCharacterSet *)chars maxLength:(NSUInteger)maxLength intoString:(NSString **)outString
{
    NSRange range = [self cmr_rangeFromScanLocation];
    range.length = MIN(range.length, maxLength);
    
    NSUInteger len;
    for (len = 0; len < range.length; ++len) {
        if (![chars characterIsMember:[self.string characterAtIndex:(range.location + len)]]) {
            break;
        }
    }
    
    NSRange charRange = NSMakeRange(range.location, len);
    if (outString) {
        *outString = [self.string substringWithRange:charRange];
    }
    
    self.scanLocation = charRange.location + charRange.length;
    
    return charRange;
}

// Hex characters
static NSCharacterSet *CMRHexCharacters() {
    static NSCharacterSet *hexChars;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hexChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"];
    });
    return hexChars;
}

// We know we've got hex already, so assume this works
static NSUInteger CMRParseHex(NSString *str, BOOL repeated)
{
    unsigned int ans = 0;
    if (repeated) {
        str = [NSString stringWithFormat:@"%@%@", str, str];
    }
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner scanHexInt:&ans];
    return ans;
}

// Scan FFF or FFFFFF, doesn't reset scan location on failure
- (BOOL)cmr_scanHexTriple:(NSColor **)color
{
    NSString *hex = nil;
    NSRange range = [self cmr_scanCharactersInSet:CMRHexCharacters() maxLength:6 intoString:&hex];
    CGFloat red, green, blue;
    if (hex.length == 6) {
        // Parse 2 chars per component
        red   = CMRParseHex([hex substringWithRange:NSMakeRange(0, 2)], NO) / 255.0;
        green = CMRParseHex([hex substringWithRange:NSMakeRange(2, 2)], NO) / 255.0;
        blue  = CMRParseHex([hex substringWithRange:NSMakeRange(4, 2)], NO) / 255.0;
    } else if (hex.length >= 3) {
        // Parse 1 char per component, but repeat it to calculate hex value
        red   = CMRParseHex([hex substringWithRange:NSMakeRange(0, 1)], YES) / 255.0;
        green = CMRParseHex([hex substringWithRange:NSMakeRange(1, 1)], YES) / 255.0;
        blue  = CMRParseHex([hex substringWithRange:NSMakeRange(2, 1)], YES) / 255.0;
        self.scanLocation = range.location + 3;
    } else {
        return NO; // Fail
    }
    if (color) {
        *color = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];
        //*color = [NSColor colorWithRed:red green:green blue:blue alpha:1.0];
    }
    [*color setType:HTMLColorHexType];
    return YES;
}

// Scan "transparent"
- (BOOL)cmr_scanTransparent:(NSColor **)color
{
    return [self cmr_caseInsensitiveWithCleanup:^BOOL{
        if ([self scanString:@"transparent" intoString:NULL]) {
            if (color) {
                *color = [NSColor colorWithCalibratedWhite:0 alpha:0];
                //*color = [NSColor colorWithWhite:0 alpha:0];
            }
            return YES;
        }
        return NO;
    }];
}

// Scan a float or percentage. Multiply float by `scale` if it was not a
// percentage.
- (BOOL)cmr_scanNum:(CGFloat *)value scale:(CGFloat)scale
{
    float f = 0.0;
    if ([self scanFloat:&f]) {
        if ([self scanString:@"%" intoString:NULL]) {
            f *= 0.01;
        } else {
            f *= scale;
        }
        if (value) {
            *value = f;
        }
        return YES;
    }
    return NO;
}

// Scan a triple of numbers "(10, 10, 10)". If they are not percentages, multiply
// by the corresponding `scale` component.
- (BOOL)cmr_scanFloatTriple:(CMRFloatTriple *)triple scale:(CMRFloatTriple)scale
{
    __block BOOL success = NO;
    __block CMRFloatTriple t;
    [self cmr_withSkip:[NSCharacterSet whitespaceAndNewlineCharacterSet] run:^{
        success = [self scanString:@"(" intoString:NULL]
        && [self cmr_scanNum:&(t.a) scale:scale.a]
        && [self scanString:@"," intoString:NULL]
        && [self cmr_scanNum:&(t.b) scale:scale.b]
        && [self scanString:@"," intoString:NULL]
        && [self cmr_scanNum:&(t.c) scale:scale.c]
        && [self scanString:@")" intoString:NULL];
    }];
    if (triple) {
        *triple = t;
    }
    return success;
}

// Scan a quad of numbers "(10, 10, 10, 10)". If they are not percentages,
// multiply by the corresponding `scale` component.
- (BOOL)cmr_scanFloatQuad:(CMRFloatQuad *)quad scale:(CMRFloatQuad)scale
{
    __block BOOL success = NO;
    __block CMRFloatQuad q;
    [self cmr_withSkip:[NSCharacterSet whitespaceAndNewlineCharacterSet] run:^{
        success = [self scanString:@"(" intoString:NULL]
        && [self cmr_scanNum:&(q.a) scale:scale.a]
        && [self scanString:@"," intoString:NULL]
        && [self cmr_scanNum:&(q.b) scale:scale.b]
        && [self scanString:@"," intoString:NULL]
        && [self cmr_scanNum:&(q.c) scale:scale.c]
        && [self scanString:@"," intoString:NULL]
        && [self cmr_scanNum:&(q.d) scale:scale.d]
        && [self scanString:@")" intoString:NULL];
    }];
    if (quad) {
        *quad = q;
    }
    return success;
}

@end

static inline CMRFloatTriple HSB2HSL(CGFloat hue, CGFloat saturation, CGFloat brightness)
{
    CGFloat l = (2.0 - saturation) * brightness;
    saturation *= brightness;
    CGFloat satDiv = (l <= 1.0) ? l : (2.0 - l);
    if (satDiv) {
        saturation /= satDiv;
    }
    l *= 0.5;
    CMRFloatTriple hsl = {
        hue,
        saturation,
        l
    };
    return hsl;
}

static inline CMRFloatTriple HSL2HSB(CGFloat hue, CGFloat saturation, CGFloat l)
{
    l *= 2.0;
    CGFloat s = saturation * ((l <= 1.0) ? l : (2.0 - l));
    CGFloat brightness = (l + s) * 0.5;
    if (s) {
        s = (2.0 * s) / (l + s);
    }
    CMRFloatTriple hsb = {
        hue,
        s,
        brightness
    };
    return hsb;
}

// Color names, longest first
static NSArray *CMRW3CColorNames() {
    static NSArray *colorNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorNames = [[CMRW3CNamedColors() allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *k1, NSString *k2) {
            NSInteger diff = k1.length - k2.length;
            if (!diff) {
                return NSOrderedSame;
            } else if (diff > 0) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }];
    });
    return colorNames;
}

// Color values as defined in CSS3 spec.
// See: http://www.w3.org/TR/css3-color/#svg-color
static NSDictionary *CMRW3CNamedColors() {
    static NSDictionary *namedColors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        namedColors = @{
                        @"AliceBlue" : @"#F0F8FF",
                        @"AntiqueWhite" : @"#FAEBD7",
                        @"Aqua" : @"#00FFFF",
                        @"Aquamarine" : @"#7FFFD4",
                        @"Azure" : @"#F0FFFF",
                        @"Beige" : @"#F5F5DC",
                        @"Bisque" : @"#FFE4C4",
                        @"Black" : @"#000000",
                        @"BlanchedAlmond" : @"#FFEBCD",
                        @"Blue" : @"#0000FF",
                        @"BlueViolet" : @"#8A2BE2",
                        @"Brown" : @"#A52A2A",
                        @"BurlyWood" : @"#DEB887",
                        @"CadetBlue" : @"#5F9EA0",
                        @"Chartreuse" : @"#7FFF00",
                        @"Chocolate" : @"#D2691E",
                        @"Coral" : @"#FF7F50",
                        @"CornflowerBlue" : @"#6495ED",
                        @"Cornsilk" : @"#FFF8DC",
                        @"Crimson" : @"#DC143C",
                        @"Cyan" : @"#00FFFF",
                        @"DarkBlue" : @"#00008B",
                        @"DarkCyan" : @"#008B8B",
                        @"DarkGoldenRod" : @"#B8860B",
                        @"DarkGray" : @"#A9A9A9",
                        @"DarkGrey" : @"#A9A9A9",
                        @"DarkGreen" : @"#006400",
                        @"DarkKhaki" : @"#BDB76B",
                        @"DarkMagenta" : @"#8B008B",
                        @"DarkOliveGreen" : @"#556B2F",
                        @"DarkOrange" : @"#FF8C00",
                        @"DarkOrchid" : @"#9932CC",
                        @"DarkRed" : @"#8B0000",
                        @"DarkSalmon" : @"#E9967A",
                        @"DarkSeaGreen" : @"#8FBC8F",
                        @"DarkSlateBlue" : @"#483D8B",
                        @"DarkSlateGray" : @"#2F4F4F",
                        @"DarkSlateGrey" : @"#2F4F4F",
                        @"DarkTurquoise" : @"#00CED1",
                        @"DarkViolet" : @"#9400D3",
                        @"DeepPink" : @"#FF1493",
                        @"DeepSkyBlue" : @"#00BFFF",
                        @"DimGray" : @"#696969",
                        @"DimGrey" : @"#696969",
                        @"DodgerBlue" : @"#1E90FF",
                        @"FireBrick" : @"#B22222",
                        @"FloralWhite" : @"#FFFAF0",
                        @"ForestGreen" : @"#228B22",
                        @"Fuchsia" : @"#FF00FF",
                        @"Gainsboro" : @"#DCDCDC",
                        @"GhostWhite" : @"#F8F8FF",
                        @"Gold" : @"#FFD700",
                        @"GoldenRod" : @"#DAA520",
                        @"Gray" : @"#808080",
                        @"Grey" : @"#808080",
                        @"Green" : @"#008000",
                        @"GreenYellow" : @"#ADFF2F",
                        @"HoneyDew" : @"#F0FFF0",
                        @"HotPink" : @"#FF69B4",
                        @"IndianRed" : @"#CD5C5C",
                        @"Indigo" : @"#4B0082",
                        @"Ivory" : @"#FFFFF0",
                        @"Khaki" : @"#F0E68C",
                        @"Lavender" : @"#E6E6FA",
                        @"LavenderBlush" : @"#FFF0F5",
                        @"LawnGreen" : @"#7CFC00",
                        @"LemonChiffon" : @"#FFFACD",
                        @"LightBlue" : @"#ADD8E6",
                        @"LightCoral" : @"#F08080",
                        @"LightCyan" : @"#E0FFFF",
                        @"LightGoldenRodYellow" : @"#FAFAD2",
                        @"LightGray" : @"#D3D3D3",
                        @"LightGrey" : @"#D3D3D3",
                        @"LightGreen" : @"#90EE90",
                        @"LightPink" : @"#FFB6C1",
                        @"LightSalmon" : @"#FFA07A",
                        @"LightSeaGreen" : @"#20B2AA",
                        @"LightSkyBlue" : @"#87CEFA",
                        @"LightSlateGray" : @"#778899",
                        @"LightSlateGrey" : @"#778899",
                        @"LightSteelBlue" : @"#B0C4DE",
                        @"LightYellow" : @"#FFFFE0",
                        @"Lime" : @"#00FF00",
                        @"LimeGreen" : @"#32CD32",
                        @"Linen" : @"#FAF0E6",
                        @"Magenta" : @"#FF00FF",
                        @"Maroon" : @"#800000",
                        @"MediumAquaMarine" : @"#66CDAA",
                        @"MediumBlue" : @"#0000CD",
                        @"MediumOrchid" : @"#BA55D3",
                        @"MediumPurple" : @"#9370DB",
                        @"MediumSeaGreen" : @"#3CB371",
                        @"MediumSlateBlue" : @"#7B68EE",
                        @"MediumSpringGreen" : @"#00FA9A",
                        @"MediumTurquoise" : @"#48D1CC",
                        @"MediumVioletRed" : @"#C71585",
                        @"MidnightBlue" : @"#191970",
                        @"MintCream" : @"#F5FFFA",
                        @"MistyRose" : @"#FFE4E1",
                        @"Moccasin" : @"#FFE4B5",
                        @"NavajoWhite" : @"#FFDEAD",
                        @"Navy" : @"#000080",
                        @"OldLace" : @"#FDF5E6",
                        @"Olive" : @"#808000",
                        @"OliveDrab" : @"#6B8E23",
                        @"Orange" : @"#FFA500",
                        @"OrangeRed" : @"#FF4500",
                        @"Orchid" : @"#DA70D6",
                        @"PaleGoldenRod" : @"#EEE8AA",
                        @"PaleGreen" : @"#98FB98",
                        @"PaleTurquoise" : @"#AFEEEE",
                        @"PaleVioletRed" : @"#DB7093",
                        @"PapayaWhip" : @"#FFEFD5",
                        @"PeachPuff" : @"#FFDAB9",
                        @"Peru" : @"#CD853F",
                        @"Pink" : @"#FFC0CB",
                        @"Plum" : @"#DDA0DD",
                        @"PowderBlue" : @"#B0E0E6",
                        @"Purple" : @"#800080",
                        @"Red" : @"#FF0000",
                        @"RosyBrown" : @"#BC8F8F",
                        @"RoyalBlue" : @"#4169E1",
                        @"SaddleBrown" : @"#8B4513",
                        @"Salmon" : @"#FA8072",
                        @"SandyBrown" : @"#F4A460",
                        @"SeaGreen" : @"#2E8B57",
                        @"SeaShell" : @"#FFF5EE",
                        @"Sienna" : @"#A0522D",
                        @"Silver" : @"#C0C0C0",
                        @"SkyBlue" : @"#87CEEB",
                        @"SlateBlue" : @"#6A5ACD",
                        @"SlateGray" : @"#708090",
                        @"SlateGrey" : @"#708090",
                        @"Snow" : @"#FFFAFA",
                        @"SpringGreen" : @"#00FF7F",
                        @"SteelBlue" : @"#4682B4",
                        @"Tan" : @"#D2B48C",
                        @"Teal" : @"#008080",
                        @"Thistle" : @"#D8BFD8",
                        @"Tomato" : @"#FF6347",
                        @"Turquoise" : @"#40E0D0",
                        @"Violet" : @"#EE82EE",
                        @"Wheat" : @"#F5DEB3",
                        @"White" : @"#FFFFFF",
                        @"WhiteSmoke" : @"#F5F5F5",
                        @"Yellow" : @"#FFFF00",
                        @"YellowGreen" : @"#9ACD32"
                        };
    });
    return namedColors;
}

