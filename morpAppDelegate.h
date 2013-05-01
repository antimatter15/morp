//
//  morpAppDelegate.h
//  morp
//
//  Created by Kevin on 4/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface morpAppDelegate : NSObject  {
    NSWindow *window;
	NSImageView *pictastic;
}

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSImageView *pictastic;



@end
