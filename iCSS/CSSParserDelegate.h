//
//  CSSParserDelegate.h
//  iCSS
//
//  Created by Daniel Weber on 7/6/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSSParserDelegate <NSObject>
- (void)parserDidFinish:(NSDictionary *)userInfo;
- (void)parserDidCancel:(NSDictionary *)userInfo;
@end
