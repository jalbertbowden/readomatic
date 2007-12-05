//
//  RMDockController.h
//  Readomatic
//
//  Created by Gernot Poetsch 28.04.07.
//  Copyright 2007 Gernot Poetsch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RMDockController : NSObject {
	
	NSString *unreadCountString;
	BOOL showsUnreadCount;
}

- (NSString *)unreadCountString;
- (void)setUnreadCountString:(NSString *)value;

- (BOOL)showsUnreadCount;
- (void)setShowsUnreadCount:(BOOL)flag;

- (void)drawApplicationIcon;

@end
