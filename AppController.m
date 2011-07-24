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
#import "FRPrefController.h"

@implementation FanRadioApplication
- (void)sendEvent:(NSEvent *)theEvent {
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
	
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}
@end


@implementation AppController

@synthesize useMediaKeys = useMediaKeys;

static AppController * _instance = nil;
static NSMutableAttributedString * _heart;
static bool _inChinese = false;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		FWLog(@"Media key monitoring disabled");
	
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event {
	if (!useMediaKeys) return;
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);
	if (keyIsPressed) {
		//NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				if ([pauseItem isHidden]) {
					[self resume:nil]; 
				} else {
					[self pause:nil];
				}
				break;
				
			case NX_KEYTYPE_FAST:
				[self doShuffle:nil];
				break;
				
			case NX_KEYTYPE_REWIND:
				[self like:nil];
				break;
			default:
				//debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
				break;
				// More cases defined in hidsystem/ev_keymap.h
		}
	}
}

+ (AppController *) instance {
	return _instance;
}

#pragma mark menu actions

- (void)markNormal {
	[self syncPlayState:[resumeItem isHidden]];
}

- (void)markHappy {
	[statusItem setAttributedTitle:_heart];
}

- (void)markBuffer {
	[statusItem setTitle:@"턢"];
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

- (IBAction)openPreferences:(id)sender{
	//[FRPrefController showWindow];
	//[NSBundle loadNibNamed:@"Preferences" owner:@"foo"];
	[FRPrefController showWindow:self];
	/*static NSWindowController *wc = nil;
	if (!wc) wc = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
	[wc showWindow:self];
	[[wc window] makeKeyAndOrderFront:self];*/
}

- (IBAction)pause:(id)sender {
	[Speaker pause];
	[self syncPlayState:NO];
}

- (IBAction)resume:(id)sender{
	[Speaker resume];
	[self syncPlayState:YES];
}

#pragma mark app events

- (void)awakeFromNib {
	FWLog(@"awakeFromNib");
	_instance = self;
	pendingPlay = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlayOnLaunch"];
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
	[self syncPlayState:FALSE];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songBuffering:) name:SongBufferingNotification object:nil];
	FWLog(@"awaken");
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
	if (pendingPlay) {
		pendingPlay = NO;
		[radio tuneToChannel:currentChannel];
	}
	if (!currentChannel) {
		currentChannel = [[FRChannelList instance].channels objectAtIndex:0];
	}
	lastChannelItem = [statusMenu itemWithTag:currentChannel.tag];
	[lastChannelItem setState:1];
	FWLog(@"Last Channel %@ %@", currentChannel.name, lastChannelItem.title);
}

- (void)playNext {
	[self performSelector:@selector(doShuffle:) withObject:nil afterDelay:1];
}

#define MAX_PLAY_TIME 30 * 60
#define MIN_PLAY_TIME 30 // ignore short clips, usually ads or unliked songs

- (void)songEnded:(NSNotification *)notification {
	FWLog(@"song ended");
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
	FWLog(@"song ready");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coverLoaded:) name:DataLoadedNotification object:[DataLoader load:radio.cover]];
}

- (void)songBuffering:(NSNotification *)notification {
	[self markBuffer];
}

- (void)coverLoaded:(NSNotification *)notification {
	FWLog(@"cover loaded");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DataLoadedNotification object:[notification object]];
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	[Speaker play:radio.url];
	lastPlayStarted = time(nil);
	[songTitleItem setTitle:[NSString stringWithFormat:@"%@ - %@", radio.title, radio.artist]];
	[likeItem setState:radio.liked];
	NSImage *img = [[NSImage alloc] initWithData:data];
	NSSize sz = img.size;
	if (sz.height > 128) {
		sz.width = sz.width * 128 / sz.height;
		sz.height = 128;
		[img setSize:sz];
	}
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
	[self syncPlayState:TRUE];
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

#if USE_SHORTCUT
- (void)hitHotKey:(PTHotKey *)hotKey {
	@"hitHotKey %zu", [[hotKey identifier] tag]);
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
#endif

- (NSArray *)feedParametersForUpdater:(id)updater sendingSystemProfile:(BOOL)sendingProfile {
	FWLog(@"feedParametersForUpdater");
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

- (void) syncPlayState:(BOOL)isPlaying {
	if (isPlaying) {
		FWLog(@"pause enabled");
		[resumeItem setHidden:YES];
		[pauseItem setHidden:NO];
		[statusItem setTitle:@"♫"];
	} else {
		FWLog(@"resume enabled");
		[resumeItem setHidden:NO];
		[pauseItem setHidden:YES];
		[statusItem setTitle:@"♪"];
	}
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
	FWLog(@"preferredLanguage: %@", lang);
	_inChinese = [lang hasPrefix:@"zh"];
	
	// Register defaults for the whitelist of apps that want to use media keys
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
															 [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
															 [NSNumber numberWithBool:YES], @"PlayOnLaunch",
															 nil]];
}

@end
