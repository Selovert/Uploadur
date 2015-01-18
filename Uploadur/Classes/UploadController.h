//
//  UploadController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/19/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan.
//
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.

@class AppDelegate;
@class NotificationController;
@class Globals;
@class AFHTTPRequestOperationManager;

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface UploadController : NSObject
{
    Reachability *internetReachableFoo;
}

@property AppDelegate *appDelegate;
@property NotificationController *notificationController;
@property Globals *globals;
@property AFHTTPRequestOperationManager *httpClient;

@property NSString *filePath;
@property BOOL foreignFile;
@property NSString *titleText;
@property NSURL *screenshotPath;
@property NSURL *archivePath;

@property NSUserDefaults *defaults;
@property NSFileManager *filemgr;
@property (copy) void(^continueHandler)();

- (UploadController *) initWithAppDelegate:(AppDelegate *)appDelegate
                    notificationController: (NotificationController *)notificationController
                                   globals:(Globals *)globals;
- (void) startUp;
- (void) uploadWrapper:(NSString *)fileName foreignFile:(BOOL)foreign;

@end
