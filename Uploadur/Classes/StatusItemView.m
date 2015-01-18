#import "StatusItemView.h"
#import "UploadController.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -


- (void)setMenu:(NSMenu *)menu {
    [menu setDelegate:self];
    [super setMenu:menu];
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //register for drags
        NSArray *dragTypes = @[NSURLPboardType, NSFileContentsPboardType, NSFilenamesPboardType];
        [self registerForDraggedTypes:dragTypes];
    }
    
    return self;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [self initWithFrame:itemRect];
    
    if (self != nil)
    {
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    return self;
}


#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon drawAtPoint:iconPoint fromRect:bounds operation:NSCompositeSourceOver fraction:1.0];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    NSMenu *menu = [super menu];
    [_statusItem popUpStatusItemMenu:menu];
    [NSApp sendAction:self.action to:self.target from:self];
}


- (void)menuWillOpen:(NSMenu *)menu {
    [self setHighlighted:YES];
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    [self setHighlighted:NO];
    [self setNeedsDisplay:YES];
}



#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    _image = newImage;
    [self setNeedsDisplay:YES];
}

- (void)setAlternateImage:(NSImage *)newImage
{
    _alternateImage = newImage;
    if (self.isHighlighted)
        [self setNeedsDisplay:YES];
}


//we want to copy the files
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:@[NSFilenamesPboardType]]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

//perform the drag and log the files that are dropped
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pb = [sender draggingPasteboard];
    NSArray *draggedFilePaths = [pb propertyListForType:NSFilenamesPboardType];
    if([[pb pasteboardItems] count] != 1){
        return NO;
    }
    
    if([NSBitmapImageRep canInitWithPasteboard:pb]){
        if([draggedFilePaths count] > 0) {
            [_uploadController uploadWrapper:[draggedFilePaths objectAtIndex:0] foreignFile:YES];
        }
       
        return YES;
    }   
    
    return NO;
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
