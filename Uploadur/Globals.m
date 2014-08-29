//
//  Globals.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/21/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

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
}

- (void) saveAccessToken {
    [_defaults setObject:_accessToken forKey:@"accessToken"];
    [_defaults setObject:_expiresAt forKey:@"expiresAt"];
    [_defaults synchronize];
}


@end
