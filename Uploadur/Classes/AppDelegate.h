//
//  AppDelegate.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

@class SettingsWindowController;
@class AboutWindowController;
@class DirectoryMonitor;
@class NotificationController;
@class UploadController;
@class Globals;
@class StatusItemDelegate;
@class PopoverController;
@class URLInputPopover;

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property StatusItemDelegate *statusItemDelegate;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *lastUploadItem;
@property (weak) IBOutlet NSMenuItem *uploadFromURLItem;

@property SettingsWindowController *settingsWindowController;
@property PopoverController *popoverController;
@property URLInputPopover *urlInputPopover;
@property AboutWindowController *aboutWindowController;
@property DirectoryMonitor *directoryMonitor;
@property NotificationController *notificationController;
@property UploadController *uploadController;
@property Globals *globals;

@property NSString *URL;
@property NSString *defaultIcon;
@property NSString *lastUploadPath;
@property NSEvent *popoverTransiencyMonitor;

- (IBAction)about:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)info:(id)sender;
- (IBAction)lastUpload:(id)sender;
- (IBAction)uploadFromURL:(id)sender;

- (void) updateCurrentImage;
- (void) changeIcon:(NSString *)icon setToDefault:(BOOL)def;
- (void) restart;
- (void) openInFinder;
- (void) openPopover;
- (void) openURLPopover;

@end
