//
//  AppDelegate.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

@class SettingsWindowController;
@class AboutWindowController;
@class DirectoryMonitor;
@class NotificationController;
@class UploadController;
@class Globals;

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *imageItem;
@property (weak) IBOutlet NSMenuItem *infoItem;

@property SettingsWindowController *settingsWindowController;
@property AboutWindowController *aboutWindowController;
@property DirectoryMonitor *directoryMonitor;
@property NotificationController *notificationController;
@property UploadController *uploadController;
@property Globals *globals;

@property NSString *URL;
@property NSString *defaultIcon;

- (IBAction)about:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)info:(id)sender;

- (void) updateCurrentImage:(NSString *)path;
- (void) changeIcon:(NSString *)icon setToDefault:(BOOL)def;
- (void) restart;

@end