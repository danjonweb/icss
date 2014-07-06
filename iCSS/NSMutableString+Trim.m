//
//  NSMutableString+Trim.m
//  iCSS
//
//  Created by Daniel Weber on 7/1/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "NSMutableString+Trim.h"

@implementation NSMutableString (Trim)

- (void)trimCharactersInSet:(NSCharacterSet *)set {
    NSInteger frontLength = 0;
    unichar buffer[self.length + 1];
    [self getCharacters:buffer range:NSMakeRange(0, self.length)];
    for (NSInteger i = 0; i < self.length; i++) {
        unichar c = buffer[i];
        if ([set characterIsMember:c]) {
            frontLength++;
        } else {
            break;
        }
    }
    NSInteger backLength = 0;
    for (NSInteger i = self.length-1; i >= 0; i--) {
        unichar c = buffer[i];
        if ([set characterIsMember:c]) {
            backLength++;
        } else {
            break;
        }
    }
    [self deleteCharactersInRange:NSMakeRange(self.length-backLength, backLength)];
    [self deleteCharactersInRange:NSMakeRange(0, frontLength)];
}

@end
