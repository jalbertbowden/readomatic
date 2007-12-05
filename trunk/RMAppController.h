//
//  RMAppController.h
//  Readomatic
//
//  Created by Gernot Poetsch 19.04.07.
//  Copyright 2007 Gernot Poetsch. Released under GLPv3. Have Fun!
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#define RMGoogleReaderURLString @"http://www.google.com/reader"

#define RMDefaultsOpenLinksInBackground @"RMDefaultsOpenLinksInBackground"
#define RMDefaultsShowUnreadCountInDock @"RMDefaultsShowUnreadCountInDock"
#define RMDefaultsUseCustomStylesheet	@"RMDefaultsUseCustomStylesheet"

@class RMDockController;

@interface RMAppController : NSObject {
	
	RMDockController *dockController;
	IBOutlet NSUserDefaultsController *userDefaultsController;
	
	IBOutlet WebView *webView;
	IBOutlet NSWindow *mainWindow;
}

- (NSString *)unreadCountString;
- (NSString *)HTMLStringForError:(NSError *)error;

@end
