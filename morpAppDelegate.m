//
//  morpAppDelegate.m
//  morp
//
//  Created by Kevin on 4/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "morpAppDelegate.h"
#import <IOKit/pwr_mgt/IOPMLib.h>

#import "pubnub.h"


@interface TimeResponse: TimeDelegate @end
@implementation TimeResponse

-(void) callback: (NSNumber*) response {
	NSLog(@"%@", response);
}

@end

@interface SubscribeResponse : Response @end

@implementation SubscribeResponse

-(void) callback: (id) response {
	NSLog(@"Recieved message (channel: %@ -> %@", channel, response);
	
	if([response objectForKey: @"whitelist"] == nil || [[response objectForKey: @"whitelist"] containsObject: [[NSApp delegate] getAppID]]){

		
		if([response objectForKey: @"delay"]){
			[[NSApp delegate] setDelay: [response objectForKey: @"delay"]];
		}
		if([response objectForKey: @"scale"]){
			[[NSApp delegate] setScaling: [response objectForKey:@"scale"]];
		}
		if([response objectForKey:@"url"]){
			[[NSApp delegate] setImage: [response objectForKey:@"url"]];
		}
		if([response objectForKey:@"show"]){
			
			[[NSApp delegate] displayPicture: nil];
			
		}else if([response objectForKey: @"url"] == nil){		
			[[NSApp delegate] hidePicture: nil];
		}
	}else{
		NSLog(@"does not match whitelist criterion");
	
	}
	
	
	
}
@end


@interface PublishResponse: Response @end
@implementation PublishResponse

-(void) callback: (NSArray*) response {
	NSLog(@"%@", response);
}

-(void) fail: (NSArray*) response {
	NSLog(@"fail %@", response);
}

@end

@interface SignallingResponse : Response @end

@implementation SignallingResponse




-(void) callback: (id) response {
	NSLog(@"Recieved SIGNAL (channel: %@ -> %@", channel, response);
	SInt32 major, minor, bugfix;
	Gestalt(gestaltSystemVersionMajor, &major);
	Gestalt(gestaltSystemVersionMinor, &minor);
	Gestalt(gestaltSystemVersionBugFix, &bugfix);	
	NSString *systemVersion = [NSString stringWithFormat:@"%d.%d.%d", major, minor, bugfix];
	//NSLog(@"system version %@", systemVersion);

	[pubnub 
	 publish: @"listing"
	 message: [NSArray arrayWithObjects: 
			   @"mac",
			   [[NSApp delegate] getAppID],
			   NSUserName(), 
			   [[NSHost currentHost] name],
			   systemVersion,
			   [[[NSHost currentHost] addresses] objectAtIndex: 1],
			   nil]
	 deligate: [PublishResponse alloc]
	 ];
}

@end





@implementation morpAppDelegate

@synthesize window;

double hide_delay = 10.0;

int compid;

- (int) getAppID {
	return [NSNumber numberWithInt: compid ];
}


- (void) setDelay: (NSTimeInterval*) tdelay {
	hide_delay = [tdelay doubleValue];
}

- (void) setImage: (NSString*) url {
	//NSString *url = @"http://i.imgur.com/G8xFG3k.jpg";
	//	[pictastic setImage: [[NSImage alloc] initByReferencingURL:[NSURL URLWithString:url]]];
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	NSImage *img = [[NSImage alloc] initWithData:data];
	[pictastic setImage:img];
}
	 
- (void) setScaling: (NSString*) mode {
	if ([mode isEqualToString: @"propdown"]) {
		[pictastic setImageScaling: NSImageScaleProportionallyDown];
	}else if ([mode isEqualToString: @"indep"]) {
		[pictastic setImageScaling: NSImageScaleAxesIndependently];
	}else if ([mode isEqualToString: @"none"]) {
		[pictastic setImageScaling: NSImageScaleNone];
	}else if ([mode isEqualToString: @"propany"]) {
		[pictastic setImageScaling: NSImageScaleProportionallyUpOrDown];
	}
}

- (void)displayPicture: (id) sender {

	//NSImage *merp;
	//merp = [NSImage imageNamed:@"dog.jpg"];
	//[pictastic setImage:merp];
	//[pictastic setImage: [[NSImage alloc] imageNamed: @"dog.jpg"]];
	
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
	
	//UpdateSystemActivity(OverallAct);
	//IOPMAssertionID assertionID;
	//IOReturn success = IOPMAssertionCreate(kIOPMAssertionTypeNoDisplaySleep, kIOPMAssertionLevelOn, &assertionID);
	//if(success == kIOReturnSuccess){
	[window makeKeyAndOrderFront:self];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(hidePicture:) withObject: nil afterDelay: hide_delay];
		//IOPMAssertionRelease(assertionID);
	//}
}

- (void)hidePicture:(id) sender {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[window orderOut:self];
}


- (void) mouseDown:(NSEvent *) theEvent {
	[window orderOut:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	NSLog(@"initializing window for stuff");
	//[[NSHost currentHost] localizedName];
	srand(time(NULL));
	
	compid = rand() % 999999;
	
	NSRect mainDisplayRect = [[NSScreen mainScreen] frame];
	window = [[NSWindow alloc] initWithContentRect:mainDisplayRect
										 styleMask:NSBorderlessWindowMask
										   backing:NSBackingStoreBuffered
											 defer:NO
											screen:[NSScreen mainScreen]];
	
	[window setContentView:pictastic];
	
	//[window setContentSize:mainDisplayRect.size];
	//[window setStyleMask:NSBorderlessWindowMask];
	
	[window setLevel:NSMainMenuWindowLevel+1];
	[window setFrame:mainDisplayRect display:NO];
	//[window setFrameTopLeftPoint:NSMakePoint(0, 0)];
	[window setOpaque:YES];
	[window setHidesOnDeactivate:NO];
	//NSLog(@"magical blah");
	//[self performSelector:@selector(displayPicture:) withObject: nil afterDelay:3.0];
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
	
	NSLog(@"initializing pubnub");
	Pubnub *pubnub = [[Pubnub alloc] 
					  publishKey:@"pub-c-1feb89bd-fe5b-46f5-8fb4-85df202a9c47" 
					  subscribeKey: @"sub-c-df29bace-b1d7-11e2-a940-02ee2ddab7fe" 
					  secretKey:@"sec-c-NjhmMWQ2NzItOWFhNS00YjBmLWIxNzctYzQwZjJjZGI5NWFm" 
					  sslOn: YES
					  origin: @"pubsub.pubnub.com"
					  ];
	NSString* channel = @"main";
	NSLog(@"beginning pubnub timing");
	[pubnub time: [TimeResponse alloc]];
	
	NSLog(@"subscribing to signalling channel");
	
	[pubnub subscribe: @"signalling"
			 deligate: [[SignallingResponse alloc] pubnub: pubnub channel: @"signalling"]];
	
	//this is hacky fuck i should actually learn this one day 
	NSLog(@"Broadcasting presence");
	
	[[[SignallingResponse alloc] pubnub: pubnub channel: @"signalling"] callback: nil];
	
	//[pubnub 
	//	 publish: @"signalling"
	//	 message: [NSArray arrayWithObjects: @"startup", nil]
	//	 deligate: [PublishResponse alloc]
	//	 ];
	
	NSLog(@"Listenign to: %@", channel);
	[pubnub subscribe: channel
			 deligate: [[SubscribeResponse alloc] pubnub: pubnub channel: channel]];
	
}

@end
