//
//  SettingsWindowController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

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
@property dispatch_semaphore_t semaphore;

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
@property (weak) IBOutlet NSComboBox *albumBox;
@property (weak) IBOutlet NSButton *albumPrivacyCheckBox;

@property NSMutableArray *albums;
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
