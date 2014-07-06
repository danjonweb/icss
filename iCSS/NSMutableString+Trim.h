//
//  NSMutableString+Trim.h
//  iCSS
//
//  Created by Daniel Weber on 7/1/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Trim)

- (void)trimCharactersInSet:(NSCharacterSet *)set;

@end
