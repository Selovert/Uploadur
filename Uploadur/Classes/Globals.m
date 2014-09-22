//
//  Globals.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/21/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

#import "Globals.h"

@implementation Globals

- (Globals *) init {
    _defaults = [NSUserDefaults standardUserDefaults];
    [self loadSettings];
    NSDictionary *appKeys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppKeys" ofType:@"plist"]];
    _clientID = [appKeys objectForKey:@"clientID"];
    _clientSecret = [appKeys objectForKey:@"clientSecret"];
    return [super init];
}

- (void) loadSettings {
    _titleText = [_defaults objectForKey:@"titleText"];
    if (_titleText == nil) { _titleText = @"Uploaded Using Uploadur"; }
    
    _screenshotPath = [_defaults URLForKey:@"screenshotPath"];
    if (_screenshotPath == nil) { _screenshotPath = [NSURL URLWithString:[NSString stringWithFormat: @"%@/Pictures/Screenshots", NSHomeDirectory()]]; }
    
    _archivePath = [_defaults URLForKey:@"archivePath"];
    if (_archivePath == nil) { _archivePath = [NSURL URLWithString:[NSString stringWithFormat: @"%@/Pictures/Screenshots/Uploaded", NSHomeDirectory()]]; }
    
    _postUpload = [_defaults integerForKey:@"postUpload"];
    
    _refreshToken = [_defaults objectForKey:@"refreshToken"];
    
    _accessToken = [_defaults objectForKey:@"accessToken"];
    
    _expiresAt = [_defaults objectForKey:@"expiresAt"];
    
    _userName = [_defaults objectForKey:@"userName"];
    if (_userName == nil) {_userName = @""; }
    
    _albumName = [_defaults objectForKey:@"albumName"];
    if (_albumName == nil) { _albumName = @""; }
    
    _albumID = [_defaults objectForKey:@"albumID"];
    
    _albumIsPrivate = [_defaults integerForKey:@"albumIsPrivate"];
    
    _startUp = [_defaults integerForKey:@"startUp"];
}

- (void) saveAccessToken {
    [_defaults setObject:_accessToken forKey:@"accessToken"];
    [_defaults setObject:_expiresAt forKey:@"expiresAt"];
    [_defaults synchronize];
}


@end
