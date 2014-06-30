//
//  CSSParser.h
//  Test3
//
//  Created by Daniel Weber on 3/14/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSParser : NSObject

+ (CSSParser *)parser;
- (void)parse:(NSString *)string shouldReloadAfterParse:(BOOL)reload;
- (void)cancel;

@property (assign) id delegate;

@end
