//
//  SettingsWindowController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

@class StartupController;
@class DirectoryMonitor;
@class AppDelegate;
@class Globals;
@class AFHTTPRequestOperationManager;

#import <Cocoa/Cocoa.h>

@interface SettingsWindowController : NSWindowController

@property StartupController *startupController;
@property DirectoryMonitor *directoryMonitor;
@property AppDelegate *appDelegate;
@property Globals *globals;
@property AFHTTPRequestOperationManager *httpClient;

@property (strong) IBOutlet NSWindow *settingsWindow;
@property (weak) IBOutlet NSButton *startupCheckBox;
@property (weak) IBOutlet NSTextField *titleTextBox;
@property (weak) IBOutlet NSPopUpButton *screenshotPathPopup;
@property (weak) IBOutlet NSPopUpButton *archivePathPopup;
@property (weak) IBOutlet NSButtonCell *moveRadio;
@property (weak) IBOutlet NSButtonCell *deleteRadio;
@property (weak) IBOutlet NSButtonCell *nothingRadio;
@property (weak) IBOutlet NSButton *authenticateButton;
@property (weak) IBOutlet NSTextField *authorizeLabel;
@property (weak) IBOutlet NSButton *authorizeButton;
@property (weak) IBOutlet NSButton *logoutButton;
@property (weak) IBOutlet NSTextField *accountLabel;
@property (weak) IBOutlet NSTextField *albumLabel;
@property (weak) IBOutlet NSTextField *albumBox;
@property (weak) IBOutlet NSButton *albumPrivacyCheckBox;

@property NSInteger startUp;
@property NSUserDefaults *defaults;

- (void) reveal;

- (IBAction)startupCheckBox:(id)sender;
- (IBAction)apply:(id)sender;
- (IBAction)showFilePicker:(id)sender;
- (IBAction)enableArchive:(id)sender;
- (IBAction)disableArchive:(id)sender;
- (IBAction)authenticate:(id)sender;
- (IBAction)authorize:(id)sender;
- (IBAction)logout:(id)sender;

- (IBAction)debug:(id)sender;

@end
