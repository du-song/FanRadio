//
//  AppController.m
//  FanRadio
//
//  Created by Du Song on 10-6-16.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "AppController.h"
#import "DataLoader.h"
#import "Speaker.h"
#import "PerProcessHTTPCookieStore.h"

@implementation AppController

static AppController * _instance = nil;
static NSMutableAttributedString * _heart;
static bool _inChinese = false;

+ (AppController *) instance {
	return _instance;
}

#pragma mark menu actions

- (void)markNormal {
	[statusItem setTitle:@"♪"];
}

- (void)markHappy {
	[statusItem setAttributedTitle:_heart];
}

- (void)markBuffer {
	[statusItem setTitle:@"𝄢"];
}

- (IBAction)like:(id)sender {
	if ([likeItem state]) {
		[radio unlikeCurrent];
		[likeItem setState:0];
		[self markNormal];
	} else {
		[radio likeCurrent];
		[likeItem setState:1];
		[self markHappy];
	}
}

- (IBAction)dislike:(id)sender {
	[radio banCurrent];
}

- (IBAction)tuneChannel:(id)sender {
	if (lastChannelItem) [lastChannelItem setState:0];
	lastChannelItem = sender;
	[sender setState:1];
	currentChannel = [[FRChannelList instance] channelByTag:[sender tag]];
	[currentChannel tune];
	[[NSUserDefaults standardUserDefaults] setObject:[currentChannel uuid] forKey:@"LastChannel"];
}

- (IBAction)doShuffle:(id)sender {
	[radio endAndPlayNext];
}

- (IBAction)endAndPlayNext:(id)sender {
	[radio endAndPlayNext];
}

- (IBAction)openPage:(id)sender {
	if (radio.pageURL) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:radio.pageURL]];
	}
}

- (IBAction)openUserPage:(id)sender {
	if (radio.loginSuccess) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:radio.profilePage]];
	} else {
		//FIXME [settingsPane orderFront:nil];
	}

}

- (IBAction)pause:(id)sender {
	if ([resumeItem isHidden]) {
		NSLog(@"pause");
		[Speaker pause];
		[resumeItem setHidden:NO];
		[pauseItem setHidden:YES];
	} else {
		NSLog(@"resume");
		[Speaker resume];
		[resumeItem setHidden:YES];
		[pauseItem setHidden:NO];	
	}
}

- (IBAction)resume:(id)sender{
	[self pause:sender];
}

#pragma mark app events

- (void)awakeFromNib {
	NSLog(@"awakeFromNib");
	_instance = self;
	pendingPlay = YES;
	lastPlayStarted = 0;
	currentChannel = nil;
	
	//check login info
	radio = [DoubanRadio instance];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songEnded:) name:SongEndedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songReady:) name:SongReadyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:LoginCheckedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChannels:) name:ChannelListLoadedNotification object:nil];
	[radio recheckLogin];	
	
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	//Keyboard Shortcut
	useMediaKeys = [[NSUserDefaults standardUserDefaults] boolForKey:@"UseMediaKeys"];	
	
    //show icon
    //float width = 24.0;
    //float height = [[NSStatusBar systemStatusBar] thickness];
    //NSRect viewFrame = NSMakeRect(0, 0, width, height);
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    //[statusItem setView:[[[StatusItemView alloc] initWithFrame:viewFrame controller:self] autorelease]];
	[statusItem setToolTip:@"Fan Radio"];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	
	//load channel
	[self markNormal];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songBuffering:) name:SongBufferingNotification object:nil];
	NSLog(@"awaken");
}

- (void)loginInProgress:(NSNotification *)notification {
	[usernameItem setTitle:@"Logging in..."];
	[usernameItem setEnabled:NO];	
}

- (void)updateUser:(NSNotification *)notification {
	[usernameItem setTitle:(radio.loginSuccess ? radio.nickname : @"Not Logged In")];
	[usernameItem setEnabled:YES];
	if (![[FRChannelList instance].channels count]) {
		[[DoubanRadio instance] loadChannelList];
	}
}

- (void)updateChannels:(NSNotification *)notification {
	int i = [statusMenu indexOfItem:channelsItem] + 1;
	NSMenuItem *m;
	while ((m = [statusMenu itemAtIndex:i]) != nil) {
		if (!m.tag) break;
		[statusMenu removeItem:m];
	}
	for (FRChannel *c in [FRChannelList instance].channels){
		m = [[NSMenuItem alloc] initWithTitle:(_inChinese ? c.name : c.nameEng) action:@selector(tuneChannel:) keyEquivalent:@""];
		m.tag = c.tag;
		[m setIndentationLevel:1];
		[statusMenu insertItem:m atIndex:i++];
		[m release];
	}
	currentChannel = [[FRChannelList instance] channelByUUID:[[NSUserDefaults standardUserDefaults] objectForKey:@"LastChannel"]];
	if (!currentChannel) {
		currentChannel = [[FRChannelList instance].channels objectAtIndex:0];
	}
	lastChannelItem = [statusMenu itemWithTag:currentChannel.tag];
	[lastChannelItem setState:1];
	if (pendingPlay) {
		pendingPlay = NO;
		[self doShuffle:nil];
	}
}

- (void)playNext {
	[self performSelector:@selector(doShuffle:) withObject:nil afterDelay:1];
}

- (void)setUseMediaKeys:(BOOL)u {
	useMediaKeys = u;
}

#define MAX_PLAY_TIME 30 * 60
#define MIN_PLAY_TIME 30 // ignore short clips, usually ads or unliked songs

- (void)songEnded:(NSNotification *)notification {
	NSLog(@"song ended");
	if (lastPlayStarted > 0) {
		NSTimeInterval t = time(nil) - lastPlayStarted;
		if (t > MIN_PLAY_TIME) {
			if (t > MAX_PLAY_TIME) t = MAX_PLAY_TIME;
			radio.totalListenedTime = radio.totalListenedTime + t;
			radio.totalListenedTracks ++;
		}
	}
	lastPlayStarted = 0;
	[self performSelector:@selector(endAndPlayNext:) withObject:nil afterDelay:0.1];
}

- (void)songReady:(NSNotification *)notification {
	NSLog(@"song ready");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coverLoaded:) name:DataLoadedNotification object:[DataLoader load:radio.cover]];
}

- (void)songBuffering:(NSNotification *)notification {
	[self markBuffer];
}

- (void)coverLoaded:(NSNotification *)notification {
	NSLog(@"cover loaded");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DataLoadedNotification object:[notification object]];
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	[Speaker play:radio.url];
	lastPlayStarted = time(nil);
	[songTitleItem setTitle:[NSString stringWithFormat:@"%@ - %@", radio.title, radio.artist]];
	[likeItem setState:radio.liked];
	NSImage *img = [[NSImage alloc] initWithData:data];
	[coverItem setImage:img];
	[img release];
	[coverItem setHidden:NO];
	[GrowlApplicationBridge notifyWithTitle:radio.title
								description:[NSString stringWithFormat:@"%@\n%@", radio.artist, radio.album] 
						   notificationName:@"Song Start"
								   iconData:data
								   priority:0
								   isSticky:NO
							   clickContext:nil];
	if (radio.liked) [self markHappy]; else [self markNormal];
}

- (void)dealloc { 
	[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
	[statusMenu release];
	[coverItem release];
	[songTitleItem release];
	[likeItem release];
	[usernameItem release];
	[pauseItem release];
	[resumeItem release];
	[super dealloc];
}

- (void)hitHotKey:(PTHotKey *)hotKey {
	NSLog(@"hitHotKey %zu", [[hotKey identifier] tag]);
	switch ([[hotKey identifier] tag]) {
		case 0: //shuffle
			[self doShuffle:nil];
			break;
		case 1: //like
			[self like:nil];
			break;
		case 2: //ban
			[self dislike:nil];
			break;
	}
}

- (NSArray *)feedParametersForUpdater:(id)updater sendingSystemProfile:(BOOL)sendingProfile {
	NSLog(@"feedParametersForUpdater");
	NSMutableArray *ret = [NSMutableArray array];
	NSString *uiid_ = [self uiid];
	NSString *time_ = [NSString stringWithFormat:@"%d", [radio totalListenedTime]]; 
	NSString *tracks_ = [NSString stringWithFormat:@"%d", [radio totalListenedTracks]]; 
	[ret addObject:[NSDictionary dictionaryWithObjectsAndKeys:uiid_, @"value", @"uiid", @"key", nil]];
	[ret addObject:[NSDictionary dictionaryWithObjectsAndKeys:time_, @"value", @"time", @"key", nil]];
	[ret addObject:[NSDictionary dictionaryWithObjectsAndKeys:tracks_, @"value", @"trck", @"key", nil]];
	return ret;
}

- (NSString *) uiid {
	NSString *uiid_ = [[NSUserDefaults standardUserDefaults] stringForKey:@"UniqueInstallationId"];
	if (!uiid_) {
		srandom(time(NULL));
		uiid_ = [NSString stringWithFormat:@"%8x%8x", random(), random()];
		[[NSUserDefaults standardUserDefaults] setValue:uiid_ forKey:@"UniqueInstallationId"];
	}
	return uiid_;
}

- (BOOL) togglePlayPause: (id)sender {
	if (!useMediaKeys) return NO;
	NSLog(@"media key pause");
	[self pause:sender];
	return YES;
}

- (BOOL) seekForward: (id)sender {
	if (!useMediaKeys) return NO;
	NSLog(@"media key forward");
	[self doShuffle:sender];
	return YES;
}

- (BOOL) seekBack: (id)sender {
	if (!useMediaKeys) return NO;
	NSLog(@"media key backward");
	[self like:sender];
	return YES;
}

+ (void)initialize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
								 dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:@"DoubanChannel"];
    [defaults registerDefaults:appDefaults];
#if COOKIE_MAGIC
	[PerProcessHTTPCookieStore makeSurePerProcessHTTPCookieStoreLinkedIn];
#endif
	_heart = [[NSMutableAttributedString alloc] initWithString:@"❤"];
	[_heart addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:16] range:NSMakeRange(0,1)];
	[_heart addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,1)];
	NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
	NSLog(@"preferredLanguage: %@", lang);
	_inChinese = [lang hasPrefix:@"zh"];
}

@end
