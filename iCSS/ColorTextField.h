//
//  ColorTextField.h
//  iCSS
//
//  Created by Daniel Weber on 6/23/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColorTextField : NSTextField

@property (nonatomic, weak) NSPopUpButton *popUpButton;
@property (nonatomic, weak) NSTrackingArea *trackingArea;

- (void)reload;

@end
