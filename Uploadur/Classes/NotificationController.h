//
//  NotificationController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/19/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationController : NSObject <NSUserNotificationCenterDelegate>

@property NSUserNotificationCenter *center;

- (NotificationController *) init;
- (void) notify:(NSString *)title message:(NSString *)message link:(NSString *)link;

@end
