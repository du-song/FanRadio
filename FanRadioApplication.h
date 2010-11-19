//
//  MyMediaApplication.h
//  TestMediaKey
//
//  Created by Du Song on 10-11-19.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FanRadioApplication : NSApplication {
}

- (void)sendEvent:(NSEvent *)event;
- (BOOL)mediaKeyEvent:(int)key state:(BOOL)state;
@end
