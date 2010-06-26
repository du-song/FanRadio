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
	IBOutlet NSPanel *settingsPane;
	IBOutlet NSMenuItem *lastChannel;
	
	IBOutlet NSMenuItem *channelPersonal;
	IBOutlet NSMenuItem *channelChinese;
	IBOutlet NSMenuItem *channelEnglish;
	IBOutlet NSMenuItem *channel70s;
	IBOutlet NSMenuItem *channel80s;
	IBOutlet NSMenuItem *channel90s;
	
	NSArray *channels;
@public
	DoubanRadio *radio;
}
- (void)playNext;
- (IBAction)doShuffle:(id)sender;
- (IBAction)openPage:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)tuneChannel:(id)sender;
+ (void)initialize;
@end
