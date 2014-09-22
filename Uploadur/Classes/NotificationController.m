//
//  NotificationController.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/19/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

#import "NotificationController.h"

@implementation NotificationController

- (NotificationController *) init {
    _center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [_center setDelegate:self];
    return [super init];
}

- (void) notify:(NSString *)title message:(NSString *)message link:(NSString *)link {
    NSDictionary *userinfo;
    if (link) {
        userinfo = [NSDictionary dictionaryWithObject:link forKey:@"link"];
    }
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:title];
    [notification setInformativeText:message];
    [notification setUserInfo:userinfo];
    [_center deliverNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSString *link;
    NSDictionary *info = [notification userInfo];
    if (info) {
        link = [info objectForKey:@"link"];
    }
    if (link) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:link]];
    }
}

@end
