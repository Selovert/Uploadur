//
//  URLInputPopover.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 04/03/15.
//  Copyright (c) 2015 Tassilo Selover-Stephan. All rights reserved.
//

@class AppDelegate;

#import <Cocoa/Cocoa.h>

@interface URLInputPopover : NSViewController

@property AppDelegate *delegate;
@property NSPopover *popover;
@property (weak) IBOutlet NSTextField *textField;

- (IBAction)textField:(id)sender;

@end
