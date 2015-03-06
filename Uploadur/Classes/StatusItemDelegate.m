//
//  StatusItemDelegate.m
//  Uploadur
//
//  Created by Tassilo Selover-Stephan on 04/03/15.
//  Copyright (c) 2015 Tassilo Selover-Stephan. All rights reserved.
//

#import "StatusItemDelegate.h"
#import "AppDelegate.h"
#import "PopoverController.h"
#import "UploadController.h"

@interface StatusItemDelegate()

@property AppDelegate *delegate;

@end

@implementation StatusItemDelegate

- (StatusItemDelegate *) initWithAppDelegate:(AppDelegate *)appDelegate {
    _delegate = appDelegate;
    if([_delegate.statusItem respondsToSelector:@selector(button)]) {
        NSStatusBarButton *button = [_delegate.statusItem button];
        [button sendActionOn:NSLeftMouseDownMask | NSLeftMouseUpMask | NSRightMouseDownMask];
        [button setTarget:self];
        [button setAction:@selector(clicked)];
        [_delegate.statusMenu setDelegate:self];
        _delegate.statusItem.highlightMode = YES;
        [_delegate.statusItem.button.window registerForDraggedTypes:@[NSFilenamesPboardType]];
        _delegate.statusItem.button.window.delegate = self;
    }
    return [super init];
}

-(void)clicked {
    NSEvent *currentEvent = [NSApp currentEvent];
    if([currentEvent type] == NSRightMouseDown) {
        _delegate.statusItem.highlightMode = NO;
        [self handleRightClick];
    } else if([currentEvent type] == NSLeftMouseDown) {
        _delegate.statusItem.highlightMode = YES;
        [self openMenu];
    }
}

- (void) openMenu {
    [_delegate.statusItem popUpStatusItemMenu:_delegate.statusMenu];
}

- (void) handleRightClick {
    if (_delegate.uploadController.foreignFile == 2) {
        [_delegate info:self];
    } else if ((_delegate.lastUploadItem.enabled == YES) && (_delegate.popoverController.image != nil)) {
        [_delegate openPopover];
    } else {
//        _delegate.statusItem.highlightMode = YES;
//        [self openMenu];
    }
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    NSArray *draggedFilePaths = [pb propertyListForType:NSFilenamesPboardType];
    if([[pb pasteboardItems] count] != 1){
        return NO;
    }
    
    if([NSBitmapImageRep canInitWithPasteboard:pb]){
        if([draggedFilePaths count] > 0) {
            [_delegate.uploadController uploadWrapper:[draggedFilePaths objectAtIndex:0] foreignFile:YES];
        }
        
        return YES;
    }
    
    return NO;
}

@end
