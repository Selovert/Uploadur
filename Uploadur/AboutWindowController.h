//
//  AboutWindowController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/29/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController

@property (strong) IBOutlet NSWindow *aboutWindow;
@property (weak) IBOutlet NSTextField *versionLabel;

- (void) reveal;
- (IBAction)viewSource:(id)sender;

@end
