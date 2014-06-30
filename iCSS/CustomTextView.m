//
//  CustomTextView.m
//  Test3
//
//  Created by Daniel Weber on 3/20/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "CustomTextView.h"

@implementation CustomTextView

- (IBAction)changeColor:(id)sender {
    
}

- (NSArray *)readablePasteboardTypes {
    return [NSArray arrayWithObjects:NSPasteboardTypeString, nil];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    if ([self shouldChangeTextInRange:range replacementString:aString]) {
        [super replaceCharactersInRange:range withString:aString];
    }
}

@end
