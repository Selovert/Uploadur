//
//  NotificationController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/19/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

#import <Foundation/Foundation.h>

@interface NotificationController : NSObject <NSUserNotificationCenterDelegate>

@property NSUserNotificationCenter *center;

- (NotificationController *) init;
- (void) notify:(NSString *)title message:(NSString *)message link:(NSString *)link;

@end
