//
//  PopoverController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 02/03/15.
//  Copyright (c) 2015 Tassilo Selover-Stephan. All rights reserved.
//

@class AppDelegate;

#import <Cocoa/Cocoa.h>

@interface PopoverController : NSViewController

@property NSImage *image;
@property NSSize contentSize;

@property AppDelegate *delegate;
@property NSPopover *popover;

@property (strong) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSButton *finderButton;
@property (weak) IBOutlet NSButton *browserButton;

- (IBAction)finderButton:(id)sender;
- (IBAction)browserButton:(id)sender;

@end
