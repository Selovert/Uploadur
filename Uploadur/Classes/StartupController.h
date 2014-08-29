//
//  StartupController.h
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 8/18/14.
//  Copyright (c) 2014 Tassilo Selover-Stephan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartupController : NSObject

- (BOOL)isLaunchAtStartup;
- (void)toggleLaunchAtStartup;

@end
