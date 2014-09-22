//
//  DirectoryMonitor.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

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
