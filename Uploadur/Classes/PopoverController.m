//
//  PopoverController.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 02/03/15.
//  Copyright (c) 2015 Tassilo Selover-Stephan. All rights reserved.
//

#import "PopoverController.h"
#import "AppDelegate.h"

@interface PopoverController ()

@end

@implementation PopoverController

- (instancetype)init {
    self = [super initWithNibName:@"Popover" bundle:nil];
    NSAssert(self, @"Fatal: error loading nib Popover");
    
    self.popover = [[NSPopover alloc] init];
    self.popover.contentViewController = self;
    self.popover.behavior = NSPopoverBehaviorTransient;
    
    _contentSize.width = 175;
    _contentSize.height = 35;
    
    return self;
}

- (void) viewWillAppear {
    [_imageView setImage:_image];
    [_popover setContentSize:_contentSize];
}

- (void) viewDidAppear {
    [NSApp activateIgnoringOtherApps:YES];
}

- (void) viewDidLoad {
    NSSize size;
    NSSize buttonSize;
    size.width = 20;
    size.height = 20;
    buttonSize.width = 28;
    buttonSize.height = 28;
    NSImage *folder = [NSImage imageNamed:@"folder"];
    [folder setSize:size];
    NSImage *globe = [NSImage imageNamed:@"globe"];
    [globe setSize:size];
    
    [_finderButton setFrameSize:buttonSize];
    [_finderButton setImage:folder];
    [_browserButton setFrameSize:buttonSize];
    [_browserButton setImage:globe];
}

- (IBAction)finderButton:(id)sender {
    if (_delegate != nil) {
        [_delegate openInFinder];
        [self.popover close];
    }
}

- (IBAction)browserButton:(id)sender {
    if (_delegate != nil) {
        [_delegate info:self];
        [self.popover close];
    }
}
@end
