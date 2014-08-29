//
//  DirectoryMonitor.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

#import "DirectoryMonitor.h"
#import "NotificationController.h"
#import "UploadController.h"
#import "Globals.h"

@implementation DirectoryMonitor

- (DirectoryMonitor *) initWithNotificationController:(NotificationController *)notificationController
                                     uploadController:(UploadController *)uploadController
                                              globals:(Globals *)globals {
    _globals = globals;
    _uploadController = uploadController;
    _notificationController = notificationController;
    _filemgr = [NSFileManager defaultManager];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                              target:self
                                            selector:@selector(timerLoop)
                                            userInfo:nil
                                             repeats:YES];
    return [super init];
}

- (void) timerLoop;
{
    NSArray *files = [self getSortedFilesFromFolder:[_globals.screenshotPath path]];
    if (_files) {
        NSUInteger newCount = [files count];
        NSUInteger oldCount = [_files count];
        if (newCount > oldCount) {
            [_uploadController uploadWrapper:[[files lastObject] objectForKey:@"path"]];
            
        }
    }
    _files = files;
    
    _globals.accessTokenIsExpired = 0;
    if ( [[NSDate date] timeIntervalSinceDate:_globals.expiresAt] > 0 ) {
        _globals.accessTokenIsExpired = 1;
    }
}

//This is reusable method which takes folder path and returns sorted file list
- (NSArray*)getSortedFilesFromFolder: (NSString*)folderPath
{
    NSError *error = nil;
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF EndsWith '.png'"];//Take only png file
    filesArray =  [filesArray filteredArrayUsingPredicate:predicate];
    
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    
    for(NSString* file in filesArray) {
        
        if (![file isEqualToString:@".DS_Store"]) {
            NSString* filePath = [folderPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];
            
        }
    }
    
    return filesAndProperties;
    
}

@end
