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

@interface AppController : NSObject <GrowlApplicationBridgeDelegate> {
    NSStatusItem *statusItem;
	NSArray *channels;
	BOOL pendingPlay;
	NSTimeInterval lastPlayStarted;

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
	IBOutlet NSMenuItem *channelRock;
	IBOutlet NSMenuItem *channelFolk;
	IBOutlet NSMenuItem *channelLight;
	IBOutlet NSMenuItem *lastChannel;
	
	IBOutlet NSMenuItem *usernameItem;
	IBOutlet NSMenuItem *turnOffItem;
	
	IBOutlet NSPanel *loginPromptPane;
	IBOutlet NSPanel *settingsPane;
	
	IBOutlet SRRecorderControl *srShuffle;
	IBOutlet SRRecorderControl *srLike;
	IBOutlet SRRecorderControl *srBan;
	
	IBOutlet NSTextField *doubanUsernameItem;
	IBOutlet NSSecureTextField *doubanPasswordItem;
	
@public
	DoubanRadio *radio;
}
- (void)playNext;
- (void)markNormal;
- (void)markHappy;
- (IBAction)doShuffle:(id)sender;
- (IBAction)openPage:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)tuneChannel:(id)sender;
- (IBAction)like:(id)sender;
- (IBAction)dislike:(id)sender;
- (IBAction)openUserPage:(id)sender;
- (IBAction)turnOff:(id)sender;
- (IBAction)openDoubanRegister:(id)sender;
- (void)settingPaneWillClose:(NSNotification *)notification;
- (NSArray *)feedParametersForUpdater:(id)updater sendingSystemProfile:(BOOL)sendingProfile;
- (NSString *) uiid;
+ (void)initialize;
+ (AppController *)instance;

//private
- (void)trackEnded:(NSNotification *)notification;
- (void)trackReady:(NSNotification *)notification;
- (void)dataBuffer:(NSNotification *)notification;
- (void)coverLoaded:(NSNotification *)notification;
- (void)hitHotKey:(PTHotKey *)hotKey;
- (void)updateUser:(NSNotification *)notification;

@end
