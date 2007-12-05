//
//  RMPreferencesController.m
//  Readomatic
//
//  Created by Gernot Poetsch 04.05.07.
//  Copyright 2007 Gernot Poetsch. All rights reserved.
//

#import "RMPreferencesController.h"


@implementation RMPreferencesController

- (void)awakeFromNib;
{
	NSArray *allHandlers = (NSArray *)LSCopyAllHandlersForURLScheme((CFStringRef)@"feed");
	NSString *defaultHandler = (NSString *)LSCopyDefaultHandlerForURLScheme((CFStringRef)@"feed");
	
	NSMenu *readerMenu = [[[NSMenu alloc] init] autorelease];
	NSMenuItem *defaultItem = [self _menuItemForApplicationIdentifier:defaultHandler];
	if (defaultItem) [readerMenu addItem:defaultItem];
	[readerMenu addItem:[NSMenuItem separatorItem]];
	
	NSEnumerator *handlerEnumerator = [allHandlers objectEnumerator];
	NSString *currentHandler;
	while (currentHandler = [handlerEnumerator nextObject]) {
		if (![currentHandler isEqualToString:defaultHandler]) {
			NSMenuItem *currentItem = [self _menuItemForApplicationIdentifier:currentHandler];
			if (currentItem) [readerMenu addItem:currentItem];
		}
	}
	[readerSelector setMenu:readerMenu];
}

- (NSMenuItem *)_menuItemForApplicationIdentifier:(NSString *)identifier;
{
	NSMenuItem *returnValue = [[[NSMenuItem alloc] init] autorelease];
	
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	NSString *path = [workspace absolutePathForAppBundleWithIdentifier:identifier];
	if (!path) return nil;
	NSImage *icon = [workspace iconForFile:path];
	[icon setSize:NSMakeSize(16,16)];
	[returnValue setImage:icon];
	
	[returnValue setTitle:[[path lastPathComponent] stringByDeletingPathExtension]];
	[returnValue setRepresentedObject:identifier];
	return returnValue;
}

- (IBAction)selectReader:(id)sender;
{
	LSSetDefaultHandlerForURLScheme((CFStringRef)@"feed", (CFStringRef)[[sender selectedItem] representedObject]);
}

@end
