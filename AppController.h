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
#if USE_SHORTCUT
#import "ShortcutRecorder/ShortcutRecorder.h"
#import "SRRecorderControl+PTKeyCombo.h"
#endif
#import "FRChannelList.h"
#import "FRChannel.h"
#import "SPMediaKeyTap.h"

@interface FanRadioApplication : NSApplication {
}
- (void)sendEvent:(NSEvent *)event;
@end

@interface AppController : NSObject <GrowlApplicationBridgeDelegate> {
    XASSIGN NSStatusItem *statusItem;
	XASSIGN BOOL pendingPlay;
	XASSIGN BOOL useMediaKeys;
	XASSIGN NSTimeInterval lastPlayStarted;
	XASSIGN FRChannel *currentChannel;
	XASSIGN NSMenuItem *lastChannelItem;
	SPMediaKeyTap *keyTap;
	
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

@property (nonatomic, assign) BOOL useMediaKeys;

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
- (IBAction)openPreferences:(id)sender;
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
#if USE_SHORTCUT
- (void)hitHotKey:(PTHotKey *)hotKey;
#endif
- (NSArray *)feedParametersForUpdater:(id)updater sendingSystemProfile:(BOOL)sendingProfile;
- (NSString *) uiid;
- (void) syncPlayState:(BOOL)isPlaying; 
+ (void)initialize;
+ (AppController *) instance;

@end
