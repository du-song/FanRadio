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
#import "SRRecorderControl+PTKeyCombo.h"
#import "FRChannelList.h"
#import "FRChannel.h"

#define COOKIE_MAGIC 1

@interface AppController : NSObject <GrowlApplicationBridgeDelegate> {
    XASSIGN NSStatusItem *statusItem;
	XASSIGN BOOL pendingPlay;
	XASSIGN BOOL useMediaKeys;
	XASSIGN NSTimeInterval lastPlayStarted;
	XASSIGN FRChannel *currentChannel;
	XASSIGN NSMenuItem *lastChannelItem;
	
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *coverItem;
	IBOutlet NSMenuItem *songTitleItem;
	IBOutlet NSMenuItem *likeItem;
	IBOutlet NSMenuItem *channelsItem;
	IBOutlet NSMenuItem *usernameItem;
	IBOutlet NSMenuItem *pauseItem;
	IBOutlet NSMenuItem *resumeItem;
	
@public
	DoubanRadio *radio;
}

- (void)markNormal;
- (void)markHappy;
- (void)markBuffer;
- (IBAction)like:(id)sender;
- (IBAction)dislike:(id)sender;
- (IBAction)tuneChannel:(id)sender;
- (IBAction)doShuffle:(id)sender;
- (IBAction)endAndPlayNext:(id)sender;
- (IBAction)openPage:(id)sender;
- (IBAction)openUserPage:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)resume:(id)sender;
- (void)awakeFromNib;
- (void)updateUser:(NSNotification *)notification;
- (void)updateChannels:(NSNotification *)notification;
- (void)playNext;
- (void)songEnded:(NSNotification *)notification;
- (void)songReady:(NSNotification *)notification;
- (void)songBuffering:(NSNotification *)notification;
- (void)coverLoaded:(NSNotification *)notification;
- (void)dealloc;
- (void)setUseMediaKeys:(BOOL)u;
- (void)hitHotKey:(PTHotKey *)hotKey;
- (NSArray *)feedParametersForUpdater:(id)updater sendingSystemProfile:(BOOL)sendingProfile;
- (NSString *) uiid;
- (BOOL) togglePlayPause: (id)sender;
- (BOOL) seekForward: (id)sender;
- (BOOL) seekBack: (id)sender;
+ (void)initialize;
+ (AppController *) instance;

@end
