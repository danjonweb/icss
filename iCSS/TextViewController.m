//
//  TextViewController.m
//  iCSS
//
//  Created by Daniel Weber on 7/3/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import "TextViewController.h"
#import "Document.h"
#import <WebKit/WebKit.h>

@interface TextViewController ()

@end

@implementation TextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - Control Changed

- (IBAction)controlChanged:(id)sender {
    DOMCSSStyleRule *styleRule = [self.document currentStyleRule];
    
    
    
    [self loadStyleRule:styleRule];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id sender = [notification object];
    
    
    
    [self controlChanged:sender];
}

#pragma mark - Clear Controls

- (void)clearControls {
    
}

#pragma mark - Load Style

- (void)loadStyleRule:(DOMCSSStyleRule *)styleRule {
    
    [self clearControls];
    
    
}

@end
