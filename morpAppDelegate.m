//
//  morpAppDelegate.m
//  morp
//
//  Created by Kevin on 4/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "morpAppDelegate.h"
#import <IOKit/pwr_mgt/IOPMLib.h>

@implementation morpAppDelegate

@synthesize window;

- (void)displayPicture:(id) sender {
	//NSLog(@"pooper scoop");
	// so we have to disable the screensaver if it's up
	// and since i have no idea what else you can do, lets defer
	// to the painfully obvious and read an appropriate xkcd
	// http://xkcd.com/196
	
	CGEventRef ourEvent = CGEventCreate(NULL);
	CGPoint point = CGEventGetLocation(ourEvent);
	point.x += 1;
	point.y += 1;
	//now that we's got da mouse pos and shifted it, lets push it back
	CGEventRef event = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), kCGEventMouseMoved, point, kCGMouseButtonLeft);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
	
	UpdateSystemActivity(OverallAct);
	//IOPMAssertionID assertionID;
	//IOReturn success = IOPMAssertionCreate(kIOPMAssertionTypeNoDisplaySleep, kIOPMAssertionLevelOn, &assertionID);
	//if(success == kIOReturnSuccess){
		[window makeKeyAndOrderFront:self];
		[self performSelector:@selector(hidePicture:) withObject: nil afterDelay:10.0];
		//IOPMAssertionRelease(assertionID);
	//}
}

- (void)hidePicture:(id) sender {
	[window orderOut:self];
}


- (void) mouseDown:(NSEvent *) theEvent {
	[window orderOut:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	//[[NSHost currentHost] localizedName];
	
	NSRect mainDisplayRect = [[NSScreen mainScreen] frame];
	//[window setContentSize:mainDisplayRect.size];
	[window setStyleMask:NSBorderlessWindowMask];
	
	[window setLevel:NSMainMenuWindowLevel+1];
	[window setFrame:mainDisplayRect display:NO];
	//[window setFrameTopLeftPoint:NSMakePoint(0, 0)];
	[window setOpaque:YES];
	[window setHidesOnDeactivate:NO];
	//NSLog(@"magical blah");
	[self performSelector:@selector(displayPicture:) withObject: nil afterDelay:3.0];
//	[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(displayPicture:) userInfo:nil repeats:NO];
	//[window makeKeyAndOrderFront:self];
	
//
//	NSRect mainDisplayRect = [[NSScreen mainScreen] frame];
//	NSWindow *fullScreenWindow = [[NSWindow alloc] initWithContentRect: mainDisplayRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
//	[fullScreenWindow setLevel:NSMainMenuWindowLevel+1];
//	[fullScreenWindow setOpaque:YES];
//	[fullScreenWindow setHidesOnDeactivate:YES];
//	[fullScreenWindow makeKeyAndOrderFront:self];
//	CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
//	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename("dog.jpg");
//	CGImageRef image = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
//	//UIImage* image = [UIImage imageNamed:@"dog.jpg"];
//	
//	//CGImageRef imageRef = image.CGImage;
//	CGContextDrawImage(ctx, NSRectToCGRect(mainDisplayRect), image);
	
	
}

@end
