//
//  RMPreferencesController.h
//  Readomatic
//
//  Created by Gernot Poetsch 04.05.07.
//  Copyright 2007 Gernot Poetsch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RMPreferencesController : NSObject {
	IBOutlet NSPopUpButton *readerSelector;
}

- (NSMenuItem *)_menuItemForApplicationIdentifier:(NSString *)identifier;

- (IBAction)selectReader:(id)sender;

@end
