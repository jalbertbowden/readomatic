//
//  RMAppController.m
//  Readomatic
//
//  Created by Gernot Poetsch 19.04.07.
//  Copyright 2007 Gernot Poetsch. Released under GLPv3. Have Fun!
//

#import "RMAppController.h"

#import "RMDockController.h"

@implementation RMAppController

#pragma mark Class Methods

+ (void)initialize;
{	
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:NO], RMDefaultsOpenLinksInBackground,
		[NSNumber numberWithBool:YES], RMDefaultsShowUnreadCountInDock,
		[NSNumber numberWithBool:YES], RMDefaultsUseCustomStylesheet,
		nil]];
}

#pragma mark Init & Destroy

- (void)awakeFromNib;
{
	//Setup as URL-handler
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
													   andSelector:@selector(handleOpenURLEvent:withReplyEvent:)
													 forEventClass:kInternetEventClass
														andEventID:kAEGetURL];
	
	//We do menu handling manually for the main window
	[mainWindow setExcludedFromWindowsMenu:YES];
	
	//Load the Page
	NSURL *stylesheetUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"greader" ofType:@"css"]];
	[[webView preferences] bind:@"userStyleSheetEnabled" toObject:userDefaultsController withKeyPath:@"values.RMDefaultsUseCustomStylesheet" options:nil];
	[[webView preferences] setUserStyleSheetLocation:stylesheetUrl];
	NSURL *readerUrl = [NSURL URLWithString:RMGoogleReaderURLString];
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:readerUrl]];
	
	//Dock Icon
	dockController = [[RMDockController alloc] init];
	[dockController bind:@"unreadCountString" toObject:self withKeyPath:@"unreadCountString" options:nil];
	[dockController bind:@"showsUnreadCount" toObject:userDefaultsController withKeyPath:@"values.RMDefaultsShowUnreadCountInDock" options:nil];
}

- (void)dealloc;
{
	[dockController release];
	[super dealloc];
}

#pragma mark Event Handling

- (void)handleOpenURLEvent:(NSAppleEventDescriptor *)event withReplyEvent: (NSAppleEventDescriptor *)replyEvent;
{
	NSString *feedString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	if ([feedString hasPrefix:@"feed:"]) {
		feedString = [NSString stringWithFormat:@"http:%@", [feedString substringFromIndex:5]];
	}
	feedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)feedString, NULL, (CFStringRef)@":/?&", kCFStringEncodingUTF8);
	feedString = [NSString stringWithFormat:@"http://www.google.com/reader/view/feed/%@", feedString];

	//NSLog(@"Opening %@", feedString);
	
	NSURL *feedUrl = [NSURL URLWithString:feedString];
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:feedUrl]];	
}

#pragma mark Application Delegate

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag;
{
	if (!flag) {
		[mainWindow makeKeyAndOrderFront:self];
	}
	return YES;
}

#pragma mark WebKit Frame Loading Delegate

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	//Every time something in the DOM-tree changes, we trigger the KVO to look if the UnreadCount node changed
	[self willChangeValueForKey:@"unreadCountString"];
	[self didChangeValueForKey:@"unreadCountString"];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame;
{
	//[mainWindow presentError:error];
	[frame loadHTMLString:[self HTMLStringForError:error] baseURL:nil];
}

#pragma mark WebKit Resource Loading Delegate

-(void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource;
{
	//see -webView:didFinishLoadForFrame:
	[self willChangeValueForKey:@"unreadCountString"];
	[self didChangeValueForKey:@"unreadCountString"];
}


#pragma mark WebKit Policy Delegate

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener;
{
	//NSLog(@"Deciding Policy for %@", [actionInformation objectForKey:WebActionOriginalURLKey]);
	[listener use];
}

- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener;
{
	//Everyting that normally opens in a new window (and that are all external links) open in the Browser instead.
	[listener ignore];
	BOOL opensLinksInBackground = [[[NSUserDefaults standardUserDefaults] objectForKey:RMDefaultsOpenLinksInBackground] boolValue];
	[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:[actionInformation objectForKey:WebActionOriginalURLKey]]
					withAppBundleIdentifier:nil
									options:(opensLinksInBackground) ? NSWorkspaceLaunchWithoutActivation : nil
			 additionalEventParamDescriptor:nil
						  launchIdentifiers:nil];
}

#pragma mark Accessors

- (NSString *)unreadCountString;
{
	DOMDocument *document = [[webView mainFrame] DOMDocument];
	
	//Get the Node
	DOMHTMLElement *unreadCountElement = (DOMHTMLElement *)[document getElementById:@"reading-list-unread-count"];
	if (!unreadCountElement) return nil;
	
	//Is it hidden?
	if ([[unreadCountElement className] isEqualToString:@" hidden"]) return nil;
	
	//Get the Value
	NSString *nodeValue = [unreadCountElement innerText];
	if (!nodeValue) return nil;
		
	//Remove the brackets
	NSScanner *scanner = [[[NSScanner alloc] initWithString:nodeValue] autorelease];
	NSString *returnValue = nil;
	if ( [scanner scanString:@"(" intoString:NULL]
		 &&[scanner scanUpToString:@")" intoString:&returnValue]) {
		return returnValue;
	}
	return nil;
}

#pragma mark Error Handling

- (NSString *)HTMLStringForError:(NSError *)error;
{
	NSString *loadButtonString = [NSString stringWithFormat:@"<form action=\"%@\"><input type=\"submit\" value=\"Reload\" /></form>", RMGoogleReaderURLString];
	NSString *body = [NSString stringWithFormat:@"<h1>An error has occurred</h1><p>%@</p><p>%@</p>", [error localizedDescription], loadButtonString];
	return [NSString stringWithFormat:@"<html><head></head><body><div id=\"error-message\">%@</div></body></html>", body];
}

@end
