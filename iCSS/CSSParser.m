//
//  CSSParser.m
//  Test3
//
//  Created by Daniel Weber on 3/14/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "CSSParser.h"
#import "CSSParserDelegate.h"

@interface CSSParser ()
@property BOOL isCancelled;
@property (copy) NSString *cssText;
@property NSMutableArray *braces;
@property NSMutableArray *rules;
@property NSMutableArray *groupRules;
@property NSMutableString *parsableString;
@property NSInteger ruleNumber;
@property BOOL isGroup;
@property NSRange chunkRange;
@property BOOL shouldReload;
@end

@implementation CSSParser

+ (CSSParser *)parser {
    return [[CSSParser alloc] init];
}

- (void)cancel {
    self.isCancelled = YES;
}

#define CHUNK_SIZE 15000
#define CHUNK_DELAY 0.001

- (void)parseChunk {
    if (self.isCancelled) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        if ([self.delegate respondsToSelector:@selector(parserDidCancel:)]) {
            [self.delegate performSelector:@selector(parserDidCancel:) withObject:@{@"parser": self} afterDelay:0.0];
        }
        return;
    }
    unichar buffer[self.cssText.length + 1];
    [self.cssText getCharacters:buffer range:NSMakeRange(0, self.cssText.length)];
    for (NSInteger i = self.chunkRange.location; i < NSMaxRange(self.chunkRange); i++) {
        unichar c = buffer[i];
        if (c == '/') {
            if (i+1 < self.cssText.length && buffer[i+1] == '*') {
                // Add comments
                for (NSInteger j = i+1; j < self.cssText.length; j++) {
                    unichar c2 = buffer[j];
                    if (c2 == '*') {
                        if (j+1 < self.cssText.length && buffer[j+1] == '/') {
                            if (self.braces.count == 0) {
                                NSMutableDictionary *comment = [NSMutableDictionary dictionary];
                                NSString *commentText = [self.cssText substringWithRange:NSMakeRange(i+2, j-i-2)];
                                commentText = [commentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                commentText = [commentText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                                commentText = [commentText stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                                comment[@"name"] = commentText;
                                comment[@"type"] = @"comment";
                                comment[@"index"] = @(self.ruleNumber);
                                comment[@"range"] = NSStringFromRange(NSMakeRange(i, j-i+2));
                                [self.rules addObject:comment];
                                
                                [self.parsableString appendFormat:@"s%ld {%@} ", (long)self.ruleNumber, @""];
                                self.ruleNumber++;
                                
                            }
                            i = j+1;
                            break;
                        }
                    }
                }
            }
        } else if (c == '@') {
            if (i+7 < self.cssText.length &&
                buffer[i+1] == 'c' &&
                buffer[i+2] == 'h' &&
                buffer[i+3] == 'a' &&
                buffer[i+4] == 'r' &&
                buffer[i+5] == 's' &&
                buffer[i+6] == 'e' &&
                buffer[i+7] == 't') {
                for (NSInteger j = i+7; j < self.cssText.length; j++) {
                    unichar c2 = buffer[j];
                    if (c2 == ';') {
                        NSMutableDictionary *ruleDict = [NSMutableDictionary dictionary];
                        [ruleDict setObject:[self.cssText substringWithRange:NSMakeRange(i, j-i)] forKey:@"name"];
                        ruleDict[@"index"] = @(self.ruleNumber);
                        ruleDict[@"type"] = @"charset";
                        [self.rules addObject:ruleDict];
                        
                        [self.parsableString appendFormat:@"s%ld {%@} ", (long)self.ruleNumber, @""];
                        self.ruleNumber++;
                        
                        i = j;
                        break;
                    }
                }
            } else if (i+6 < self.cssText.length &&
                       buffer[i+1] == 'i' &&
                       buffer[i+2] == 'm' &&
                       buffer[i+3] == 'p' &&
                       buffer[i+4] == 'o' &&
                       buffer[i+5] == 'r' &&
                       buffer[i+6] == 't') {
                for (NSInteger j = i+6; j < self.cssText.length; j++) {
                    unichar c2 = buffer[j];
                    if (c2 == ';') {
                        NSMutableDictionary *ruleDict = [NSMutableDictionary dictionary];
                        [ruleDict setObject:[self.cssText substringWithRange:NSMakeRange(i, j-i)] forKey:@"name"];
                        ruleDict[@"index"] = @(self.ruleNumber);
                        ruleDict[@"type"] = @"import";
                        [self.rules addObject:ruleDict];
                        
                        [self.parsableString appendFormat:@"s%ld {%@} ", (long)self.ruleNumber, @""];
                        self.ruleNumber++;
                        
                        i = j;
                        break;
                    }
                }
            } else if (i+5 < self.cssText.length &&
                       buffer[i+1] == 'm' &&
                       buffer[i+2] == 'e' &&
                       buffer[i+3] == 'd' &&
                       buffer[i+4] == 'i' &&
                       buffer[i+5] == 'a') {
                self.isGroup = YES;
                [self.groupRules removeAllObjects];
            }
        } else if (c == '{') {
            [self.braces addObject:@(i)];
        } else if (c == '}') {
            if (self.braces.count > 0) {
                NSInteger selectorEnd = [[self.braces lastObject] integerValue];
                [self.braces removeLastObject];
                
                NSInteger selectorStart = 0;
                for (NSInteger j = selectorEnd-1; j >= 0; j--) {
                    unichar cc = buffer[j];
                    if (cc == '}' || cc == '{' || cc == ';' || cc == '/') {
                        selectorStart = j+1;
                        break;
                    }
                }
                
                NSString *selectorText = [self.cssText substringWithRange:NSMakeRange(selectorStart, selectorEnd-selectorStart)];
                NSInteger selectorTextStart = [self.cssText rangeOfCharacterFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet] options:NSCaseInsensitiveSearch range:NSMakeRange(selectorStart, selectorEnd-selectorStart)].location;
                selectorText = [selectorText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                selectorText = [selectorText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                
                NSMutableDictionary *ruleDict = [NSMutableDictionary dictionary];
                ruleDict[@"name"] = selectorText;
                ruleDict[@"index"] = @(self.ruleNumber);
                ruleDict[@"range"] = NSStringFromRange(NSMakeRange(selectorTextStart, i-selectorTextStart+1));
                
                NSRange blockRange = NSMakeRange(selectorEnd+1, i-selectorEnd-1);
                ruleDict[@"blockRange"] = NSStringFromRange(blockRange);
                
                [self.parsableString appendFormat:@"s%ld {%@} ", (long)self.ruleNumber, [self.cssText substringWithRange:blockRange]];
                self.ruleNumber++;
                
                if (self.isGroup) {
                    if (self.braces.count == 0) {
                        // End of group rule
                        for (NSMutableDictionary *subRule in self.groupRules) {
                            subRule[@"parent"] = ruleDict[@"index"];
                        }
                        ruleDict[@"rules"] = self.groupRules.copy;
                        ruleDict[@"type"] = @"media";
                        [self.rules addObject:ruleDict];
                        self.isGroup = NO;
                    } else {
                        [self.groupRules addObject:ruleDict];
                    }
                } else {
                    [self.rules addObject:ruleDict];
                }
            }
        }
        
        
    }
    
    NSInteger newStart = NSMaxRange(self.chunkRange);
    if (newStart >= self.cssText.length) {
        if ([self.delegate respondsToSelector:@selector(parserDidFinish:)]) {
            [self.delegate performSelector:@selector(parserDidFinish:) withObject:@{@"parser": self, @"rules": self.rules, @"string": self.parsableString, @"reload": @(self.shouldReload)} afterDelay:0.0];
        }
    } else {
        self.chunkRange = NSMakeRange(newStart, newStart + CHUNK_SIZE < self.cssText.length ? CHUNK_SIZE : self.cssText.length - newStart);
        [self performSelector:@selector(parseChunk) withObject:nil afterDelay:CHUNK_DELAY];
    }
}

- (void)parse:(NSString *)string shouldReloadAfterParse:(BOOL)reload {
    self.cssText = string;
    self.shouldReload = reload;
    self.braces = [NSMutableArray array];
    self.rules = [NSMutableArray array];
    self.groupRules = [NSMutableArray array];
    self.parsableString = [NSMutableString string];
    self.ruleNumber = 0;
    self.isGroup = NO;
    self.chunkRange = NSMakeRange(0, self.cssText.length < CHUNK_SIZE ? self.cssText.length : CHUNK_SIZE);
    
    [self parseChunk];
}

@end
