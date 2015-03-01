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
@class StatusItemView;

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property StatusItemView *statusItemView;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *imageItem;
@property (weak) IBOutlet NSMenuItem *openInFinderItem;
@property (weak) IBOutlet NSMenuItem *infoItem;

@property SettingsWindowController *settingsWindowController;
@property AboutWindowController *aboutWindowController;
@property DirectoryMonitor *directoryMonitor;
@property NotificationController *notificationController;
@property UploadController *uploadController;
@property Globals *globals;

@property NSString *URL;
@property NSString *defaultIcon;
@property NSString *lastUploadPath;

- (IBAction)about:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)info:(id)sender;
- (IBAction)openInFinder:(id)sender;

- (void) updateCurrentImage;
- (void) changeIcon:(NSString *)icon setToDefault:(BOOL)def;
- (void) restart;

@end
