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
#import "StatusItemView.h"

@implementation AppDelegate


- (void) awakeFromNib {
    _defaultIcon = @"icon";
    // Install icon into the menu bar
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
    self.statusItemView = [[StatusItemView alloc] initWithStatusItem:self.statusItem];
    [self changeIcon:_defaultIcon setToDefault:NO];
    [self.statusItemView setAlternateImage:[NSImage imageNamed:@"icon-white"]];
    [self.statusItemView setMenu:self.statusMenu];
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
    _statusItemView.uploadController = _uploadController;
    
}

- (void) changeIcon:(NSString *)icon setToDefault:(BOOL)def {
    NSImage *image = [[NSBundle mainBundle] imageForResource:icon];
    [self.statusItemView setImage:image];
    if (def) {
        _defaultIcon = icon;
    }
}

- (void) updateCurrentImage {
    [_infoItem setEnabled:YES];
    [_infoItem setTitle:@"Last Upload"];
    [_imageItem setTitle:@""];
    
    NSSize size;
    CGFloat width;
    CGFloat height;
    NSImage *image = [[NSImage alloc] initByReferencingFile:_lastUploadPath];
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
    
    [_openInFinderItem setHidden:NO];
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

- (IBAction)openInFinder:(id)sender {
    if ((_globals.postUpload != 1) && (_lastUploadPath != nil)) {
        NSURL *fileURL = [NSURL fileURLWithPath: _lastUploadPath];
        NSArray *fileURLs = [NSArray arrayWithObjects:fileURL, nil];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
        
    }
}

@end
