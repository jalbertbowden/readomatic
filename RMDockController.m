//
//  RMDockController.m
//  Readomatic
//
//  Created by Gernot Poetsch 28.04.07.
//  Copyright 2007 Gernot Poetsch. Released under GLPv3. Have Fun!
//

#import "RMDockController.h"

#import "RMAppController.h"


@implementation RMDockController

#pragma mark Init & Destroy

- (id)init;
{
	if (![super init]) return nil;
	[self setShowsUnreadCount:YES];
	return self;
}

- (void)dealloc;
{
	[unreadCountString release];
	[super dealloc];
}

#pragma mark Accessors

- (NSString *)unreadCountString;
{
	return unreadCountString;
}

- (void)setUnreadCountString:(NSString *)value;
{
	if ([value isEqualToString:unreadCountString]) return;
	[self willChangeValueForKey:@"unreadCountString"];
	[value retain];
	[unreadCountString release];
	unreadCountString = value;
	[self didChangeValueForKey:@"unreadCountString"];
	[self drawApplicationIcon];
}

- (BOOL)showsUnreadCount;
{
	return showsUnreadCount;
}

- (void)setShowsUnreadCount:(BOOL)flag;
{
	[self willChangeValueForKey:@"showsUnreadCount"];
	showsUnreadCount = flag;
	[self didChangeValueForKey:@"showsUnreadCount"];
	[self drawApplicationIcon];
}

#pragma mark Drawing

- (void)drawApplicationIcon;
{
	//NSLog(@"Drawing Icon with UnreadCount %@", unreadCountString);
	
	NSImage *icon = [[[NSImage alloc] initWithSize:NSMakeSize(128,128)] autorelease];
	
	NSImage *unreadBezel = nil;
	unsigned int stringLength = [unreadCountString length];
	
	if (showsUnreadCount) {
		if (stringLength < 1) {
			unreadBezel = nil;
		} else if (stringLength < 3) {
			unreadBezel = [NSImage imageNamed:@"unreadBezel1&2"];
		} else if (stringLength < 4) {
			unreadBezel = [NSImage imageNamed:@"unreadBezel3"];
		} else if (stringLength < 5) {
			unreadBezel = [NSImage imageNamed:@"unreadBezel4"];
		} else {
			unreadBezel = [NSImage imageNamed:@"unreadBezel5"];
		}
	}
	
	[icon lockFocus];
	[[NSImage imageNamed:@"NSApplicationIcon"] compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	
	if (unreadBezel) {
		
		NSPoint bezelPoint = NSMakePoint([icon size].width - [unreadBezel size].width,
										 [icon size].height - [unreadBezel size].height);
		[unreadBezel compositeToPoint:bezelPoint operation:NSCompositeSourceOver];
		
		NSPoint unreadPoint = bezelPoint;
		unreadPoint.x += 11;
		unreadPoint.y += 16;
		if (stringLength < 2) unreadPoint.x += 7;
		
		NSDictionary *unreadAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										  [NSColor whiteColor], NSForegroundColorAttributeName,
										  [NSFont fontWithName:@"Lucida Grande Bold" size:26], NSFontAttributeName,
										  nil];
		[unreadCountString drawAtPoint:unreadPoint withAttributes:unreadAttributes];
	}
	[icon unlockFocus];
	[NSApp setApplicationIconImage:icon];
}

/*
- (void)drawApplicationIcon;
{
	//NSLog(@"Drawing Icon with UnreadCount %@", unreadCountString);
		
	NSImage *icon = [[[NSImage alloc] initWithSize:NSMakeSize(128,128)] autorelease];
	
	NSImage *unreadBezel = nil;
	unsigned int stringLength = [unreadCountString length];
	
	if (showsUnreadCount) {
		if (stringLength < 1) {
			unreadBezel = nil;
		} else if (stringLength < 3) {
			unreadBezel = [NSImage imageNamed:@"unreadBezel1&2"];
		} else if (stringLength < 4) {
			unreadBezel = [NSImage imageNamed:@"unreadBezel3"];
		} else if (stringLength < 5) {
			unreadBezel = [NSImage imageNamed:@"unreadBezel4"];
		} else {
			unreadBezel = [NSImage imageNamed:@"unreadBezel5"];
		}
	}
	
	[icon lockFocus];
	[[NSImage imageNamed:@"NSApplicationIcon"] compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
	
	if (unreadBezel) {
		
		NSPoint bezelPoint = NSMakePoint([icon size].width - [unreadBezel size].width,
										 [icon size].height - [unreadBezel size].height);
		[unreadBezel compositeToPoint:bezelPoint operation:NSCompositeSourceOver];
		
		NSPoint unreadPoint = bezelPoint;
		unreadPoint.x += 13;
		unreadPoint.y += 12;
		if (stringLength < 2) unreadPoint.x += 7;
		
		NSDictionary *unreadAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor whiteColor], NSForegroundColorAttributeName,
			[NSFont fontWithName:@"Helvetica Bold" size:24], NSFontAttributeName,
			nil];
		[unreadCountString drawAtPoint:unreadPoint withAttributes:unreadAttributes];
	}
	[icon unlockFocus];

	[NSApp setApplicationIconImage:icon];
}
 */

@end
