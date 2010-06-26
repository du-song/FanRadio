//
//  AppController.h
//  FanRadio
//
//  Created by Du Song on 10-6-16.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DoubanRadio.h"
#import "Growl/Growl.h"

@interface AppController : NSObject <GrowlApplicationBridgeDelegate> {
    NSStatusItem *statusItem;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *coverItem;
	IBOutlet NSMenuItem *songTitleItem;
@public
	DoubanRadio *radio;
}
- (void)playNext;
- (IBAction)doShuffle:(id)sender;
- (IBAction)openPage:(id)sender;
@end
