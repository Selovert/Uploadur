//
//  URLInputPopover.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 04/03/15.
//  Copyright (c) 2015 Tassilo Selover-Stephan. All rights reserved.
//

#import "URLInputPopover.h"
#import "AppDelegate.h"
#import "UploadController.h"

@interface URLInputPopover ()

@end

@implementation URLInputPopover

- (instancetype)init {
    self = [super initWithNibName:@"URLInputPopover" bundle:nil];
    NSAssert(self, @"Fatal: error loading nib Popover");
    
    self.popover = [[NSPopover alloc] init];
    self.popover.contentViewController = self;
    self.popover.behavior = NSPopoverBehaviorTransient;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void) viewWillAppear {
    [_textField setStringValue:@""];
}

- (void) viewDidAppear {
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)textField:(id)sender {
    if (![_textField.stringValue  isEqual: @""]) {
        [_delegate.uploadController uploadWrapper:_textField.stringValue foreignFile:2];
    }

    [_popover close];
}

@end
