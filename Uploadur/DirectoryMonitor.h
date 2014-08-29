//
//  DirectoryMonitor.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

@class NotificationController;
@class UploadController;
@class Globals;

#import <Foundation/Foundation.h>

@interface DirectoryMonitor : NSObject

@property NotificationController *notificationController;
@property UploadController *uploadController;
@property Globals *globals;

@property NSFileManager *filemgr;
@property NSTimer *timer;
@property NSArray *files;

- (DirectoryMonitor *) initWithNotificationController:(NotificationController *)notificationController
                                     uploadController:(UploadController *)uploadController
                                              globals:(Globals *)globals;
- (NSArray*)getSortedFilesFromFolder: (NSString*)folderPath;

@end
