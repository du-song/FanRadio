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
#import "ShortcutRecorder/ShortcutRecorder.h"

@interface AppController : NSObject <GrowlApplicationBridgeDelegate> {
    NSStatusItem *statusItem;
	NSArray *channels;

	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *coverItem;
	IBOutlet NSMenuItem *songTitleItem;
	IBOutlet NSMenuItem *likeItem;
	
	IBOutlet NSMenuItem *channelPersonal;
	IBOutlet NSMenuItem *channelChinese;
	IBOutlet NSMenuItem *channelEnglish;
	IBOutlet NSMenuItem *channelCantonese;
	IBOutlet NSMenuItem *channel70s;
	IBOutlet NSMenuItem *channel80s;
	IBOutlet NSMenuItem *channel90s;
	IBOutlet NSMenuItem *lastChannel;
	
	IBOutlet NSMenuItem *usernameItem;
	IBOutlet NSMenuItem *turnOffItem;
	
	IBOutlet NSPanel *loginPromptPane;
	IBOutlet NSPanel *settingsPane;
	
	IBOutlet SRRecorderControl *srShuffle;
	IBOutlet SRRecorderControl *srLike;
	IBOutlet SRRecorderControl *srBan;
	
@public
	DoubanRadio *radio;
}
- (void)playNext;
- (void)restartOurselves;
- (void)markNormal;
- (void)markHappy;
- (IBAction)doShuffle:(id)sender;
- (IBAction)openPage:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)tuneChannel:(id)sender;
- (IBAction)like:(id)sender;
- (IBAction)dislike:(id)sender;
- (IBAction)openUserPage:(id)sender;
- (IBAction)relaunchApp:(id)sender;
- (IBAction)turnOff:(id)sender;
+ (void)initialize;
+ (AppController *)instance;
@end
