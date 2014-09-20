//
//  Globals.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/21/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject

@property NSString *clientID;
@property NSString *clientSecret;
@property NSString *refreshToken;
@property NSString *accessToken;
@property BOOL accessTokenIsExpired;
@property NSDate *expiresAt;
@property NSString *userName;
@property NSUserDefaults *defaults;
@property NSString *titleText;
@property NSURL *screenshotPath;
@property NSURL *archivePath;
@property NSInteger postUpload;
@property NSString *albumName;
@property NSString *albumID;
@property NSInteger albumIsPrivate;
@property NSInteger startUp;

- (void) loadSettings;
- (void) saveAccessToken;

@end
