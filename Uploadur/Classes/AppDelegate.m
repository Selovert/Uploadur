//
//  AppDelegate.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

#import "AppDelegate.h"
#import "Globals.h"
#import "SettingsWindowController.h"
#import "AboutWindowController.h"
#import "DirectoryMonitor.h"
#import "NotificationController.h"
#import "UploadController.h"

@implementation AppDelegate

- (void) awakeFromNib {
    _defaultIcon = @"icon";
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [self changeIcon:_defaultIcon setToDefault:NO];
    [_statusItem setAlternateImage:[[NSBundle mainBundle] imageForResource:@"icon-white"]];
    
    self.statusItem.menu = self.statusMenu;
    self.statusItem.highlightMode = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _globals = [[Globals alloc] init];
    _notificationController = [[NotificationController alloc] init];
    _uploadController = [[UploadController alloc] initWithAppDelegate:self notificationController:_notificationController globals:_globals];
    [self restart];
    _directoryMonitor = [[DirectoryMonitor alloc] initWithNotificationController:_notificationController
                                                                uploadController:_uploadController
                                                                         globals:_globals];
    _settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindow"];
    _settingsWindowController.directoryMonitor = _directoryMonitor;
    _settingsWindowController.appDelegate = self;
    _settingsWindowController.globals = _globals;
    _aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindow"];
    
}

- (void) changeIcon:(NSString *)icon setToDefault:(BOOL)def {
    NSImage *image = [[NSBundle mainBundle] imageForResource:icon];
    [self.statusItem setImage:image];
    if (def) {
        _defaultIcon = icon;
    }
}

- (void) updateCurrentImage:(NSString *)path {
    [_infoItem setEnabled:YES];
    [_infoItem setTitle:@"Last Upload"];
    [_imageItem setTitle:@""];
    
    NSSize size;
    CGFloat width;
    CGFloat height;
    NSImage *image = [[NSImage alloc] initByReferencingFile:path];
    CGFloat oldWidth = [image size].width;
    CGFloat oldHeight = [image size].height;
    if ((oldWidth > 300) || (oldHeight > 300)) {
        if (oldHeight < oldWidth) {
            width = 300;
            height = oldHeight / (oldWidth / 300);
        } else {
            height = 300;
            width = oldWidth / (oldHeight / 300);
        }
        size.width = width;
        size.height = height;
        [image setSize:size];
    }
    [_imageItem setImage:image];
    
}

- (void) restart {
    [_uploadController startUp];
    [_globals loadSettings];
    _directoryMonitor.files = [_directoryMonitor getSortedFilesFromFolder:[_globals.screenshotPath path]];

}

- (IBAction)about:(id)sender {
    [_aboutWindowController reveal];
}

- (IBAction)openSettings:(id)sender {
    [_settingsWindowController reveal];
}

- (IBAction)info:(id)sender {
    if (_URL) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_URL]];
    }
}

@end
