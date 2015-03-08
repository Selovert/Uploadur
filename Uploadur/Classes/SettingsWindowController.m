//
//  SettingsWindowController.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

#import <AFHTTPRequestOperationManager.h>

#import "SettingsWindowController.h"
#import "StartupController.h"
#import "DirectoryMonitor.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "UploadController.h"

@implementation SettingsWindowController

- (SettingsWindowController *) initWithAppDelegate:(AppDelegate *)appDelegate {
    _appDelegate = appDelegate;
    _startupController = [[StartupController alloc] init];
    _defaults = [NSUserDefaults standardUserDefaults];
    _httpClient = [AFHTTPRequestOperationManager manager];
    _albums = [[NSMutableArray alloc] init];
    return [super initWithWindowNibName:@"SettingsWindow" owner:self];
}

- (void) reveal {
    [self.window setDelegate:self];
    [self showWindow:self];
    [_settingsWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    [self checkUser];
    [self updateWindow];
}

- (void) updateWindow {
    NSImage *screenshotIconImage = [[NSWorkspace sharedWorkspace] iconForFile:[_appDelegate.globals.screenshotPath path]];
    [screenshotIconImage setSize:NSMakeSize(16,16)];
    NSImage *archiveIconImage = [[NSWorkspace sharedWorkspace] iconForFile:[_appDelegate.globals.archivePath path]];
    [archiveIconImage setSize:NSMakeSize(16,16)];
    
    [_startupCheckBox setState:_appDelegate.globals.startUp];
    if ([_startupController isLaunchAtStartup] != _appDelegate.globals.startUp) {
        NSLog(@"Toggling startup");
        [_startupController toggleLaunchAtStartup];
    }
    
    [_titleTextBox setStringValue:_appDelegate.globals.titleText];
    [[_screenshotPathPopup itemAtIndex:0] setTitle:[_appDelegate.globals.screenshotPath path]];
    [[_screenshotPathPopup itemAtIndex:0] setImage:screenshotIconImage];
    [[_archivePathPopup itemAtIndex:0] setTitle:[_appDelegate.globals.archivePath path]];
    [[_archivePathPopup itemAtIndex:0] setImage:archiveIconImage];
    [_albumBox setStringValue:_appDelegate.globals.albumName];
    [_albumPrivacyCheckBox setState:_appDelegate.globals.albumIsPrivate];
    
    [self updatePostUploads];
    [self checkPostUploads];
}

- (void) checkUser {
    if ((_appDelegate.globals.accessToken) && (_appDelegate.globals.refreshToken)) {
        [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",_appDelegate.globals.accessToken] forHTTPHeaderField:@"Authorization"];
        [_httpClient POST:@"https://api.imgur.com/oauth2/token"
              parameters:@{ @"refresh_token": _appDelegate.globals.refreshToken,
                            @"client_id": _appDelegate.globals.clientID,
                            @"client_secret": _appDelegate.globals.clientSecret,
                            @"grant_type": @"refresh_token" }
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     _appDelegate.globals.accessToken = [responseObject objectForKey:@"access_token"];
                     id expiresIn = [responseObject objectForKey:@"expires_in"];
                     _appDelegate.globals.expiresAt = [NSDate dateWithTimeIntervalSinceNow:([expiresIn integerValue] - 120)];
                     _appDelegate.globals.userName = [responseObject objectForKey:@"account_username"];
                     
                     [_authenticateButton setEnabled:NO];
                     [_accountLabel setStringValue:[NSString stringWithFormat:@"Logged in as %@",_appDelegate.globals.userName]];
                     [_authorizeButton setEnabled:NO];
                     [_authorizeLabel setTextColor:[NSColor disabledControlTextColor]];
                     [_albumBox setEnabled:YES];
                     [self updateAlbums];
                     [_albumLabel setTextColor:[NSColor controlTextColor]];
                     [_albumPrivacyCheckBox setEnabled:YES];
                     [_logoutButton setTransparent:NO];
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Failure checking user!");
                 }
         ];
    } else {
        _appDelegate.globals.accessToken = nil;
        _appDelegate.globals.refreshToken = nil;
        [_authenticateButton setEnabled:YES];
        [_accountLabel setStringValue:@"Not logged in..."];
        [_authorizeButton setEnabled:YES];
        [_authorizeLabel setTextColor:[NSColor controlTextColor]];
        [_albumBox setEnabled:NO];
        [_albumLabel setTextColor:[NSColor disabledControlTextColor]];
        [_albumPrivacyCheckBox setEnabled:NO];
        [_logoutButton setTransparent:YES];
        _appDelegate.globals.albumName = @"";
        _appDelegate.globals.albumID = nil;
        _appDelegate.globals.albumIsPrivate = 0;
    }
}

- (void) updateAlbums {
    if (_appDelegate.globals.refreshToken) {
        [_albums removeAllObjects];
        [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",_appDelegate.globals.accessToken] forHTTPHeaderField:@"Authorization"];
        [_httpClient GET:@"https://api.imgur.com/3/account/me/albums/"
              parameters:@{}
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     _appDelegate.globals.albumID = nil;
                     NSDictionary *data = [responseObject objectForKey:@"data"];
                     for (id key in data) {
                         [_albums addObject:[key objectForKey:@"title"]];
                     }
                     [_albumBox removeAllItems];
                     [_albumBox addItemsWithObjectValues:_albums];
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Failure getting albums for the box!");
                 }
         ];

        
    }

}

- (void) checkAlbum {
    if ((_appDelegate.globals.refreshToken) && (![_appDelegate.globals.albumName isEqualToString:@""])) {
        [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",_appDelegate.globals.accessToken] forHTTPHeaderField:@"Authorization"];
        [_httpClient GET:@"https://api.imgur.com/3/account/me/albums/"
              parameters:@{}
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     _appDelegate.globals.albumID = nil;
                     NSDictionary *data = [responseObject objectForKey:@"data"];
                     for (id key in data) {
                         if ([_appDelegate.globals.albumName isEqualToString:[key objectForKey:@"title"]]) {
                             NSLog(@"Match found");
                             _appDelegate.globals.albumID = [key objectForKey:@"id"];
                             [self setAlbumPrivacy];
                             [_defaults setObject:_appDelegate.globals.albumID forKey:@"albumID"];
                             dispatch_semaphore_signal(_semaphore);
                         }
                     }
                     if (!_appDelegate.globals.albumID) {
                         NSLog(@"No match");
                         [self createAlbum];
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Failure getting albums!");
                     dispatch_semaphore_signal(_semaphore);
                 }
         ];
    }
    else {
        dispatch_semaphore_signal(_semaphore);
    }
}

- (void) createAlbum {
    [_httpClient POST:@"https://api.imgur.com/3/album/"
           parameters: @{ @"title": _appDelegate.globals.albumName }
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Made album '%@'",_appDelegate.globals.albumName);
                  NSDictionary *data = [responseObject objectForKey:@"data"];
                  _appDelegate.globals.albumID = [data objectForKey:@"id"];
                  [self setAlbumPrivacy];
                  [_defaults setObject:_appDelegate.globals.albumID forKey:@"albumID"];
                  dispatch_semaphore_signal(_semaphore);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Failure creating album!");
               dispatch_semaphore_signal(_semaphore);
           }
     ];
}

- (void) setAlbumPrivacy {
    NSString *privacy;
    if (_appDelegate.globals.albumIsPrivate) {
        privacy = @"hidden";
    } else {
        privacy = @"public";
    }
    [_httpClient POST:[NSString stringWithFormat:@"https://api.imgur.com/3/album/%@",_appDelegate.globals.albumID]
           parameters: @{ @"privacy": privacy,
                          @"layout": @"grid"}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Made album \"%@\" %@",_appDelegate.globals.albumName, privacy);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Failure updating album!");
              }
     ];
}

- (void) updatePostUploads {
    if (_appDelegate.globals.postUpload == 0) {
        [_moveRadio setState:1];
        [_deleteRadio setState:0];
        [_nothingRadio setState:0];
    } else if (_appDelegate.globals.postUpload == 1) {
        [_moveRadio setState:0];
        [_deleteRadio setState:1];
        [_nothingRadio setState:0];
    } else if (_appDelegate.globals.postUpload == 2) {
        [_moveRadio setState:0];
        [_deleteRadio setState:0];
        [_nothingRadio setState:1];
    }
}

- (void) checkPostUploads {
    if (_moveRadio.state) {
        [_archivePathPopup setEnabled:YES];
    } else if ((_deleteRadio.state) || (_nothingRadio.state)) {
        [_archivePathPopup setEnabled:NO];
    }
}

- (void) savePostUploads {
    if (_moveRadio.state) {
        _appDelegate.globals.postUpload = 0;
    } else if (_deleteRadio.state) {
        _appDelegate.globals.postUpload = 1;
    } else if (_nothingRadio.state) {
        _appDelegate.globals.postUpload = 2;
    }
}

- (void) saveSettings {
    _semaphore = dispatch_semaphore_create(0);
    _httpClient.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _appDelegate.globals.startUp = [_startupCheckBox state];
    _appDelegate.globals.titleText = [_titleTextBox stringValue];
    _appDelegate.globals.albumName = [_albumBox stringValue];
    _appDelegate.globals.albumIsPrivate = [_albumPrivacyCheckBox state];
    _appDelegate.globals.albumID = nil;
    [self savePostUploads];
    [self checkAlbum];
    
    [_defaults setInteger:_appDelegate.globals.startUp forKey:@"startUp"];
    [_defaults setObject:_appDelegate.globals.titleText forKey:@"titleText"];
    [_defaults setURL:_appDelegate.globals.screenshotPath forKey:@"screenshotPath"];
    [_defaults setURL:_appDelegate.globals.archivePath forKey:@"archivePath"];
    [_defaults setInteger:_appDelegate.globals.postUpload forKey:@"postUpload"];
    [_defaults setObject:_appDelegate.globals.refreshToken forKey:@"refreshToken"];
    [_defaults setObject:_appDelegate.globals.accessToken forKey:@"accessToken"];
    [_defaults setObject:_appDelegate.globals.expiresAt forKey:@"expiresAt"];
    [_defaults setObject:_appDelegate.globals.userName forKey:@"userName"];
    [_defaults setObject:_appDelegate.globals.albumName forKey:@"albumName"];
    [_defaults setObject:_appDelegate.globals.albumID forKey:@"albumID"];
    [_defaults setInteger:_appDelegate.globals.albumIsPrivate forKey:@"albumIsPrivate"];
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"Saving settings...");
    [_defaults synchronize];
    
}

- (void)windowWillClose:(NSNotification *)notification {
    [self saveSettings];
    [_appDelegate restart];
}

- (IBAction)startupCheckBox:(id)sender {
    [self saveSettings];
    [self updateWindow];
}

- (IBAction)showFilePicker:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            if ([[[sender menu] title]  isEqual: @"screenshot"]) {
                _appDelegate.globals.screenshotPath = [openPanel URLs][0];
                [_screenshotPathPopup selectItemAtIndex:0];
            } else if ([[[sender menu] title]  isEqual: @"archive"]) {
                _appDelegate.globals.archivePath = [openPanel URLs][0];
                [_archivePathPopup selectItemAtIndex:0];
            }
            [self updateWindow];
            [self saveSettings];
        }
        
    }];
}

- (IBAction)enableArchive:(id)sender {
    [_archivePathPopup setEnabled:YES];
}

- (IBAction)disableArchive:(id)sender {
    [_archivePathPopup setEnabled:NO];
}

- (IBAction)authenticate:(id)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.imgur.com/oauth2/authorize?client_id=%@&response_type=pin",_appDelegate.globals.clientID]];
    [[NSWorkspace sharedWorkspace] openURL:url];
    [self logout:self];
    
}

- (IBAction)authorize:(id)sender {
    NSString *pin = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
    [_httpClient POST:@"https://api.imgur.com/oauth2/token"
       parameters:@{@"client_id": _appDelegate.globals.clientID,
                    @"client_secret": _appDelegate.globals.clientSecret,
                    @"grant_type": @"pin",
                    @"pin": pin }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              _appDelegate.globals.refreshToken = [responseObject objectForKey:@"refresh_token"];
              _appDelegate.globals.accessToken = [responseObject objectForKey:@"access_token"];
              _appDelegate.globals.expiresAt = [NSDate dateWithTimeIntervalSinceNow:3480];
              [_appDelegate.globals saveAccessToken];
              [self checkUser];
              
              NSLog(@"Authentication successful with refresh token: %@",_appDelegate.globals.refreshToken);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error authenticating");
          }];
}

- (IBAction)logout:(id)sender {
    _appDelegate.globals.accessToken = nil;
    _appDelegate.globals.refreshToken = nil;
    _appDelegate.globals.expiresAt = nil;
    [self checkUser];
    [self updateWindow];
}

- (IBAction)debug:(id)sender {
}

@end
