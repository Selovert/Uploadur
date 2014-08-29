//
//  UploadController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/19/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

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
- (void) uploadWrapper:(NSString *)filePath;

@end
