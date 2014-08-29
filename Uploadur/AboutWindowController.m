//
//  AboutWindowController.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/29/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

#import "AboutWindowController.h"

@implementation AboutWindowController


- (void)windowDidLoad
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [_versionLabel setStringValue:[NSString stringWithFormat:@"Version %@",version]];
    [super windowDidLoad];
}

- (void) reveal {
    [self showWindow:self];
    [_aboutWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)viewSource:(id)sender {
    NSURL *sourcePath = [NSURL URLWithString: @"https://github.com/Selovert/Uploadur"];
    [[NSWorkspace sharedWorkspace] openURL:sourcePath];
}
@end
