//
//  SettingsWindowController.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

#import <AFHTTPRequestOperationManager.h>

#import "SettingsWindowController.h"
#import "StartupController.h"
#import "DirectoryMonitor.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "UploadController.h"

@implementation SettingsWindowController

- (void)windowWillLoad {
    _startupController = [[StartupController alloc] init];
    _defaults = [NSUserDefaults standardUserDefaults];
    _httpClient = [AFHTTPRequestOperationManager manager];
    _albums = [[NSMutableArray alloc] init];
    [super windowWillLoad];
}

- (void) reveal {
    [self showWindow:self];
    [_settingsWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    [self checkUser];
    [self updateWindow];
}

- (void) updateWindow {
    NSImage *screenshotIconImage = [[NSWorkspace sharedWorkspace] iconForFile:[_globals.screenshotPath path]];
    [screenshotIconImage setSize:NSMakeSize(16,16)];
    NSImage *archiveIconImage = [[NSWorkspace sharedWorkspace] iconForFile:[_globals.archivePath path]];
    [archiveIconImage setSize:NSMakeSize(16,16)];
    
    [_startupCheckBox setState:_globals.startUp];
    if ([_startupController isLaunchAtStartup] != _globals.startUp) {
        NSLog(@"Toggling startup");
        [_startupController toggleLaunchAtStartup];
    }
    
    [_titleTextBox setStringValue:_globals.titleText];
    [[_screenshotPathPopup itemAtIndex:0] setTitle:[_globals.screenshotPath path]];
    [[_screenshotPathPopup itemAtIndex:0] setImage:screenshotIconImage];
    [[_archivePathPopup itemAtIndex:0] setTitle:[_globals.archivePath path]];
    [[_archivePathPopup itemAtIndex:0] setImage:archiveIconImage];
    [_albumBox setStringValue:_globals.albumName];
    [_albumPrivacyCheckBox setState:_globals.albumIsPrivate];
    
    [self updatePostUploads];
    [self checkPostUploads];
}

- (void) checkUser {
    if ((_globals.accessToken) && (_globals.refreshToken)) {
        [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",_globals.accessToken] forHTTPHeaderField:@"Authorization"];
        [_httpClient POST:@"https://api.imgur.com/oauth2/token"
              parameters:@{ @"refresh_token": _globals.refreshToken,
                            @"client_id": _globals.clientID,
                            @"client_secret": _globals.clientSecret,
                            @"grant_type": @"refresh_token" }
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     _globals.accessToken = [responseObject objectForKey:@"access_token"];
                     id expiresIn = [responseObject objectForKey:@"expires_in"];
                     _globals.expiresAt = [NSDate dateWithTimeIntervalSinceNow:([expiresIn integerValue] - 120)];
                     _globals.userName = [responseObject objectForKey:@"account_username"];
                     
                     [_authenticateButton setEnabled:NO];
                     [_accountLabel setStringValue:[NSString stringWithFormat:@"Logged in as %@",_globals.userName]];
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
        _globals.accessToken = nil;
        _globals.refreshToken = nil;
        [_authenticateButton setEnabled:YES];
        [_accountLabel setStringValue:@"Not logged in..."];
        [_authorizeButton setEnabled:YES];
        [_authorizeLabel setTextColor:[NSColor controlTextColor]];
        [_albumBox setEnabled:NO];
        [_albumLabel setTextColor:[NSColor disabledControlTextColor]];
        [_albumPrivacyCheckBox setEnabled:NO];
        [_logoutButton setTransparent:YES];
        _globals.albumName = @"";
        _globals.albumID = nil;
        _globals.albumIsPrivate = 0;
    }
}

- (void) updateAlbums {
    if (_globals.refreshToken) {
        [_albums removeAllObjects];
        [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",_globals.accessToken] forHTTPHeaderField:@"Authorization"];
        [_httpClient GET:@"https://api.imgur.com/3/account/me/albums/"
              parameters:@{}
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     _globals.albumID = nil;
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
    if ((_globals.refreshToken) && (![_globals.albumName isEqualToString:@""])) {
        [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",_globals.accessToken] forHTTPHeaderField:@"Authorization"];
        [_httpClient GET:@"https://api.imgur.com/3/account/me/albums/"
              parameters:@{}
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     _globals.albumID = nil;
                     NSDictionary *data = [responseObject objectForKey:@"data"];
                     for (id key in data) {
                         if ([_globals.albumName isEqualToString:[key objectForKey:@"title"]]) {
                             NSLog(@"Match found");
                             _globals.albumID = [key objectForKey:@"id"];
                             [self setAlbumPrivacy];
                             [_defaults setObject:_globals.albumID forKey:@"albumID"];
                             dispatch_semaphore_signal(_semaphore);
                         }
                     }
                     if (!_globals.albumID) {
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
           parameters: @{ @"title": _globals.albumName }
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Made album '%@'",_globals.albumName);
                  NSDictionary *data = [responseObject objectForKey:@"data"];
                  _globals.albumID = [data objectForKey:@"id"];
                  [self setAlbumPrivacy];
                  [_defaults setObject:_globals.albumID forKey:@"albumID"];
                  dispatch_semaphore_signal(_semaphore);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Failure creating album!");
               dispatch_semaphore_signal(_semaphore);
           }
     ];
}

- (void) setAlbumPrivacy {
    NSString *privacy;
    if (_globals.albumIsPrivate) {
        privacy = @"hidden";
    } else {
        privacy = @"public";
    }
    [_httpClient POST:[NSString stringWithFormat:@"https://api.imgur.com/3/album/%@",_globals.albumID]
           parameters: @{ @"privacy": privacy,
                          @"layout": @"grid"}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Made album \"%@\" %@",_globals.albumName, privacy);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Failure updating album!");
              }
     ];
}

- (void) updatePostUploads {
    if (_globals.postUpload == 0) {
        [_moveRadio setState:1];
        [_deleteRadio setState:0];
        [_nothingRadio setState:0];
    } else if (_globals.postUpload == 1) {
        [_moveRadio setState:0];
        [_deleteRadio setState:1];
        [_nothingRadio setState:0];
    } else if (_globals.postUpload == 2) {
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
        _globals.postUpload = 0;
    } else if (_deleteRadio.state) {
        _globals.postUpload = 1;
    } else if (_nothingRadio.state) {
        _globals.postUpload = 2;
    }
}

- (void) saveSettings {
    _semaphore = dispatch_semaphore_create(0);
    _httpClient.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _globals.startUp = [_startupCheckBox state];
    _globals.titleText = [_titleTextBox stringValue];
    _globals.albumName = [_albumBox stringValue];
    _globals.albumIsPrivate = [_albumPrivacyCheckBox state];
    _globals.albumID = nil;
    [self savePostUploads];
    [self checkAlbum];
    
    [_defaults setInteger:_globals.startUp forKey:@"startUp"];
    [_defaults setObject:_globals.titleText forKey:@"titleText"];
    [_defaults setURL:_globals.screenshotPath forKey:@"screenshotPath"];
    [_defaults setURL:_globals.archivePath forKey:@"archivePath"];
    [_defaults setInteger:_globals.postUpload forKey:@"postUpload"];
    [_defaults setObject:_globals.refreshToken forKey:@"refreshToken"];
    [_defaults setObject:_globals.userName forKey:@"userName"];
    [_defaults setObject:_globals.albumName forKey:@"albumName"];
    [_defaults setObject:_globals.albumID forKey:@"albumID"];
    [_defaults setInteger:_globals.albumIsPrivate forKey:@"albumIsPrivate"];
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"Saving settings...");
    [_defaults synchronize];
    
}

- (IBAction)startupCheckBox:(id)sender {
    [self saveSettings];
    [self updateWindow];
}

- (IBAction)apply:(id)sender {
    [_settingsWindow close];
    [self saveSettings];
    [_appDelegate restart];
}

- (IBAction)showFilePicker:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            if ([[[sender menu] title]  isEqual: @"screenshot"]) {
                _globals.screenshotPath = [openPanel URLs][0];
                [_screenshotPathPopup selectItemAtIndex:0];
            } else if ([[[sender menu] title]  isEqual: @"archive"]) {
                _globals.archivePath = [openPanel URLs][0];
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.imgur.com/oauth2/authorize?client_id=%@&response_type=pin",_globals.clientID]];
    [[NSWorkspace sharedWorkspace] openURL:url];
    [self logout:self];
    
}

- (IBAction)authorize:(id)sender {
    NSString *pin = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
    [_httpClient POST:@"https://api.imgur.com/oauth2/token"
       parameters:@{@"client_id": _globals.clientID,
                    @"client_secret": _globals.clientSecret,
                    @"grant_type": @"pin",
                    @"pin": pin }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              _globals.refreshToken = [responseObject objectForKey:@"refresh_token"];
              _globals.accessToken = [responseObject objectForKey:@"access_token"];
              _globals.expiresAt = [NSDate dateWithTimeIntervalSinceNow:3480];
              [_globals saveAccessToken];
              [self checkUser];
              
              NSLog(@"Authentication successful with refresh token: %@",_globals.refreshToken);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error authenticating");
          }];
}

- (IBAction)logout:(id)sender {
    _globals.accessToken = nil;
    _globals.refreshToken = nil;
    [self checkUser];
    [self updateWindow];
}

- (IBAction)debug:(id)sender {
}

@end
