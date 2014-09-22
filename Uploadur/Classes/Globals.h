//
//  Globals.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/21/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

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
