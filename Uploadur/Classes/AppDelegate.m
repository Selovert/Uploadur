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
#import "StatusItemDelegate.h"
#import "PopoverController.h"
#import "URLInputPopover.h"

@implementation AppDelegate


- (void) awakeFromNib {
    _defaultIcon = @"icon";
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self changeIcon:_defaultIcon setToDefault:NO];
    _statusItemDelegate = [[StatusItemDelegate alloc] initWithAppDelegate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _globals = [[Globals alloc] init];
    _notificationController = [[NotificationController alloc] init];
    _uploadController = [[UploadController alloc] initWithAppDelegate:self notificationController:_notificationController globals:_globals];
    [self restart];
    _directoryMonitor = [[DirectoryMonitor alloc] initWithNotificationController:_notificationController
                                                                uploadController:_uploadController
                                                                         globals:_globals];
    _settingsWindowController = [[SettingsWindowController alloc] initWithAppDelegate:self];
    _aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindow"];
    _popoverController = [[PopoverController alloc] init];
    _popoverController.delegate = self;
    _urlInputPopover = [[URLInputPopover alloc] init];
    _urlInputPopover.delegate = self;
    
}

- (void) changeIcon:(NSString *)icon setToDefault:(BOOL)def {
    NSImage *image = [NSImage imageNamed:icon];
    [image setTemplate:YES];
    [self.statusItem.button setImage:image];
    if (def) {
        _defaultIcon = icon;
    }
}

- (void) updateCurrentImage {
    NSSize size;
    NSSize contentSize;
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
    } else {
        size.width = [image size].width;
        size.height = [image size].height;
    }
    if (size.width < 175) {
        contentSize.width = 175;
    } else {
        contentSize.width = size.width;
    }
    
    if (size.height < 35) {
        contentSize.height = 35;
    } else {
        contentSize.height = size.height;
    }
    
    _popoverController.image = image;
    _popoverController.contentSize = contentSize;
    
    [_lastUploadItem setEnabled:YES];
}

- (void) restart {
    [_uploadController startUp];
    [_globals loadSettings];
    _directoryMonitor.files = [_directoryMonitor getSortedFilesFromFolder:[_globals.screenshotPath path]];

}

- (void) openPopover {
    if(_popoverTransiencyMonitor)
    {
        [NSEvent removeMonitor:_popoverTransiencyMonitor];
        
        _popoverTransiencyMonitor = nil;
    }
    
    if (_popoverController.popover.shown) {
        [_popoverController.popover close];
    }
    [self.popoverController.popover showRelativeToRect:[_statusItem.button frame]
                                                ofView:_statusItem.button
                                         preferredEdge:NSMinYEdge];
    
    if(_popoverTransiencyMonitor == nil)
    {
        _popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUpMask handler:^(NSEvent* event)
                                     {
                                         [_popoverController.popover close];
                                     }];
    }
}

- (void) openURLPopover {
    if (_urlInputPopover.popover.shown) {
        [_urlInputPopover.popover close];
    }
    [self.urlInputPopover.popover showRelativeToRect:[_statusItem.button frame]
                                                ofView:_statusItem.button
                                         preferredEdge:NSMinYEdge];
}

- (void) openInFinder {
    if ((_globals.postUpload != 1) && (_lastUploadPath != nil)) {
        NSURL *fileURL = [NSURL fileURLWithPath: _lastUploadPath];
        NSArray *fileURLs = [NSArray arrayWithObjects:fileURL, nil];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
        
    }
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

- (IBAction)lastUpload:(id)sender {
    [self openPopover];
}

- (IBAction)uploadFromURL:(id)sender {
    [self openURLPopover];
}

@end


