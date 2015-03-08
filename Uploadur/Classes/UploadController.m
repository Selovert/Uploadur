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

@interface UploadController()

@property int dlCount;

@end

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
    _dlCount = 0;
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

- (void) uploadWrapper:(NSString *)fileName foreignFile:(int)foreign {
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                              target:self
                                            selector:@selector(dlAnimate)
                                            userInfo:nil
                                             repeats:YES];
    if ([self checkInternet]) {
        self.foreignFile = NO;
        if (foreign == 1) {
            self.foreignFile = YES;
            _filePath = fileName;
            NSURL *tempURL = [NSURL fileURLWithPath:fileName];
            fileName = [[tempURL pathComponents] lastObject];
        } else if (foreign == 2) {
            NSURL *tempURL = [NSURL URLWithString:fileName];
            if (tempURL && tempURL.scheme && tempURL.host) {
                self.foreignFile = 2;
                _filePath = fileName;
                fileName = [[tempURL pathComponents] lastObject];
            } else {
                [self cancelUpload:@"Upload failed: invalid URL."];
                return;
            }
        } else {
            _filePath = [NSString stringWithFormat:@"%@/%@",[_globals.screenshotPath path],fileName];
        }
        NSLog(@"%@",_filePath);
        if ([self checkSize]) {
            if (_globals.accessTokenIsExpired) {
                [self refreshUser:fileName];
            } else {
                [self upload:fileName];
            }
        } else {
            [self cancelUpload:@"Upload failed: File too large (10MB)."];
        }
    } else {
        [self cancelUpload:@"Upload failed: no internet connection."];
    }
}

- (void) upload:(NSString *)fileName {
    NSDictionary *parameters;
    NSString *imageString;
    if (_foreignFile == 2) {
        imageString = _filePath;
    } else {
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:_filePath];
        imageString = [imageData base64EncodedStringWithOptions:0];
    }
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
    _appDelegate.lastUploadPath = _filePath;
    [_appDelegate updateCurrentImage];
    [self stopAnimate];
    [_appDelegate changeIcon:_appDelegate.defaultIcon setToDefault:NO];
    if (!self.foreignFile) {
        [self manageFile:fileName];
    } else if (self.foreignFile == 2) {
        [_appDelegate.lastUploadItem setEnabled:NO];
    }
    [_notificationController notify:@"Uploadur" message:imageURL link:imageURL];
}

- (void) manageFile:(NSString *)fileName {
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@",[_globals.archivePath path],fileName];
    if (_globals.postUpload == 0) {
        if ([_filemgr isReadableFileAtPath:_filePath]) {
            [_filemgr moveItemAtPath:_filePath toPath:archivePath error:nil];
            _appDelegate.lastUploadPath = archivePath;
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
    [self stopAnimate];
    NSLog(@"Upload error: %@",[error.userInfo objectForKey:@"NSLocalizedDescription"]);
    [_appDelegate changeIcon:@"icon-error" setToDefault:NO];
    [_notificationController notify:@"Uploadur" message:@"Upload failed." link:nil];
}

- (void) cancelUpload:(NSString *)errorString {
    [_notificationController notify:@"Uploadur" message:errorString link:nil];
    [self stopAnimate];
    [_appDelegate changeIcon:_appDelegate.defaultIcon setToDefault:NO];
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

- (BOOL) checkSize {
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil] fileSize];
    long long maxSize = 10276044;
    return (fileSize < maxSize);
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
                      [self uploadFailed:error];
                  }
         ];
    }
}

- (void) dlAnimate {
    if (_dlCount == 0) {
        _dlCount = 1;
        [_appDelegate changeIcon:@"icon-dl-0" setToDefault:NO];
    } else if (_dlCount == 1) {
        _dlCount = 2;
        [_appDelegate changeIcon:@"icon-dl-1" setToDefault:NO];
    } else if (_dlCount == 2) {
        _dlCount = 0;
        [_appDelegate changeIcon:@"icon-dl-2" setToDefault:NO];
    }
}

- (void) stopAnimate {
    [_animationTimer invalidate];
    _animationTimer = nil;
}

@end
