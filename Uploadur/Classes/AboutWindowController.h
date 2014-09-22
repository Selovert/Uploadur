//
//  AboutWindowController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/29/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController

@property (strong) IBOutlet NSWindow *aboutWindow;
@property (weak) IBOutlet NSTextField *versionLabel;

- (void) reveal;
- (IBAction)viewSource:(id)sender;

@end
