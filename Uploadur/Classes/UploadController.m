//
//  UploadController.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/19/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

#import <AFHTTPRequestOperationManager.h>

#import "AppDelegate.h"
#import "NotificationController.h"
#import "UploadController.h"
#import "Globals.h"

@implementation UploadController

- (UploadController *) initWithAppDelegate:(AppDelegate *)appDelegate
                    notificationController: (NotificationController *)notificationController
                                   globals:(Globals *)globals {
    _appDelegate = appDelegate;
    _globals = globals;
    _notificationController = notificationController;
    _defaults = [NSUserDefaults standardUserDefaults];
    _filemgr = [NSFileManager defaultManager];
    _httpClient = [AFHTTPRequestOperationManager manager];
    return [super init];
}

- (void) startUp {
    [_filemgr createDirectoryAtPath:[_globals.screenshotPath path] withIntermediateDirectories:YES attributes:nil error:nil];
    [_filemgr createDirectoryAtPath:[_globals.archivePath path] withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *currentPath = [[_defaults persistentDomainForName:@"com.apple.screencapture"] objectForKey:@"location"];
    if (![currentPath isEqualToString:[_globals.screenshotPath path]]) {
        NSDictionary *prefs = [[NSDictionary alloc] initWithObjects:@[[_globals.screenshotPath path]] forKeys:@[@"location"]];
        [_defaults setPersistentDomain:prefs forName:@"com.apple.screencapture"];
    }
}

- (void) uploadWrapper:(NSString *)fileName foreignFile:(BOOL)foreign {
    [_appDelegate changeIcon:@"icon-dl" setToDefault: NO];
    if ([self checkInternet]) {
        self.foreignFile = NO;
        if (foreign) {
            self.foreignFile = YES;
            _filePath = fileName;
            NSURL *tempURL = [NSURL fileURLWithPath:fileName];
            fileName = [[tempURL pathComponents] lastObject];
        } else {
            _filePath = [NSString stringWithFormat:@"%@/%@",[_globals.screenshotPath path],fileName];
        }
        NSLog(@"%@",_filePath);
        if (_globals.accessTokenIsExpired) {
            [self refreshUser:fileName];
        } else {
            [self upload:fileName];
        }
    } else {
        [_notificationController notify:@"Uploadur" message:@"Upload failed: no internet connection." link:nil];
        [_appDelegate changeIcon:_appDelegate.defaultIcon setToDefault:NO];
    }
}

- (void) upload:(NSString *)fileName {
    NSDictionary *parameters;
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:_filePath];
    NSString *imageString = [imageData base64EncodedStringWithOptions:0];
    if (imageString) {
        if (_globals.refreshToken && _globals.accessToken && (!_globals.accessTokenIsExpired) && _globals.albumID) {
            [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",_globals.accessToken] forHTTPHeaderField:@"Authorization"];
            parameters = @{ @"image": imageString,
                            @"album": _globals.albumID,
                            @"title":_globals.titleText};
        } else if (_globals.refreshToken && _globals.accessToken && (!_globals.accessTokenIsExpired) && (!_globals.albumID)) {
            [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",_globals.accessToken] forHTTPHeaderField:@"Authorization"];
            parameters = @{ @"image": imageString,
                            @"title":_globals.titleText};
        } else if ( (!_globals.accessToken) && (!_globals.refreshToken) ) {
            [_httpClient.requestSerializer setValue:[NSString stringWithFormat:@"Client-ID %@",_globals.clientID] forHTTPHeaderField:@"Authorization"];
            parameters = @{ @"image": imageString,
                            @"title":_globals.titleText};
        } else {
            [self uploadFailed:nil];
        }
        
        if (parameters) {
            [_httpClient POST:@"https://api.imgur.com/3/upload"
               parameters: parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSString *link = [[responseObject objectForKey:@"data"] objectForKey:@"link"];
                      [self postUpload:link fileName:fileName];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      [self uploadFailed:error];
                  }
            ];
        }
    } else {
        [self uploadFailed:nil];
    }
}

- (void) postUpload:(NSString *)imageURL fileName:(NSString *)fileName {
    [self copyText:imageURL];
    _appDelegate.URL = imageURL;
    [_appDelegate updateCurrentImage:_filePath];
    [_appDelegate changeIcon:_appDelegate.defaultIcon setToDefault:NO];
    if (!self.foreignFile) {
        [self manageFile:fileName];
    }
    [_notificationController notify:@"Uploadur" message:imageURL link:imageURL];
}

- (void) manageFile:(NSString *)fileName {
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@",[_globals.archivePath path],fileName];
    if (_globals.postUpload == 0) {
        if ([_filemgr isReadableFileAtPath:_filePath]) {
            [_filemgr moveItemAtPath:_filePath toPath:archivePath error:nil];
        } else {
            NSLog(@"Error moving file");
        }
    } else if (_globals.postUpload == 1) {
        if ([_filemgr isReadableFileAtPath:_filePath]) {
            [_filemgr removeItemAtPath:_filePath error:nil];
        } else {
            NSLog(@"Error deleting file");
        }
    } else if (_globals.postUpload == 2) {
        NSLog(@"Did nothing with file");
    }
}

- (void) uploadFailed:(NSError *)error {
    NSLog(@"Upload error: %@",[error.userInfo objectForKey:@"NSLocalizedDescription"]);
    [_appDelegate changeIcon:@"icon-error" setToDefault:NO];
    [_notificationController notify:@"Uploadur" message:@"Upload failed." link:nil];
}

- (void) copyText:(NSString *)text {
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pboard setString:text forType:NSStringPboardType];
}

- (BOOL) checkInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}



- (void) refreshUser:(NSString *)fileName {
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
                      _globals.accessTokenIsExpired = 0;
                      _globals.userName = [responseObject objectForKey:@"account_username"];
                      if (fileName) {
                          [self upload:fileName];
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"Failure refreshing user!");
                  }
         ];
    }
}

@end
