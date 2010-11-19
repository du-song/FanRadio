//
//  MyMediaApplication.m
//  TestMediaKey
//
//  Created by Du Song on 10-11-19.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "FanRadioApplication.h"
#import "AppController.h"
#import <IOKit/hidsystem/ev_keymap.h>


@implementation FanRadioApplication

- (void) sendEvent:(NSEvent *)event
{
	// Catch media key events
	if ([event type] == NSSystemDefined && [event subtype] == 8)
	{
		int keyCode = (([event data1] & 0xFFFF0000) >> 16);
		int keyFlags = ([event data1] & 0x0000FFFF);
		int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
		
		// Process the media key event and return
		if ([self mediaKeyEvent:keyCode state:keyState]) return;
	}
	
	// Continue on to super
	[super sendEvent:event];
}

- (BOOL) mediaKeyEvent:(int)key state:(BOOL)state
{
	BOOL r = NO;
	switch (key)
	{
			// Play pressed
		case NX_KEYTYPE_PLAY:
			if (state == NO)
				r = [(AppController *)[self delegate] togglePlayPause:self];
			break;
			
			// Rewind
		case NX_KEYTYPE_FAST:
			if (state == YES)
				r = [(AppController *)[self delegate] seekForward:self];
			break;
			
			// Previous
		case NX_KEYTYPE_REWIND:
			if (state == YES)
				r = [(AppController *)[self delegate] seekBack:self];
			break;
	}
	return r;
}


@end
