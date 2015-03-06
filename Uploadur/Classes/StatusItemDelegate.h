//
//  StatusItemDelegate.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 04/03/15.
//  Copyright (c) 2015 Tassilo Selover-Stephan. All rights reserved.
//

@class AppDelegate;

#import <Foundation/Foundation.h>

@interface StatusItemDelegate : NSObject <NSMenuDelegate, NSWindowDelegate>

- (StatusItemDelegate *) initWithAppDelegate:(AppDelegate *)appDelegate;

@end
