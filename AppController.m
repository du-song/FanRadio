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

AppController * _instance = nil;

- (void)markNormal {
	[statusItem setTitle:@"♪"];
}

- (void)markHappy {
	[statusItem setTitle:@"♡"];
}

- (void)markBuffer {
	[statusItem setTitle:@"𝄢"];
}

- (void)awakeFromNib {
	NSLog(@"awakeFromNib");
	_instance = self;
	pendingPlay = YES;
	lastPlayStarted = 0;

	//check login info
	radio = [[DoubanRadio alloc] init];
	if (radio.username) [doubanUsernameItem setStringValue:radio.username];
	if (radio.password) [doubanPasswordItem setStringValue:radio.password];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackEnded:) name:MusicOverNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackReady:) name:SongReadyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:LoginCheckedNotification object:nil];
	[radio recheckLogin];	
	
	[GrowlApplicationBridge setGrowlDelegate:self];

	//Keyboard Shortcut
	[srShuffle setTag:0];
	[srLike setTag:1];
	[srBan setTag:2];
	[srShuffle fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyShuffle"]];
	[srLike fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyLike"]];
	[srBan fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyBan"]];
	useMediaKeys = [[NSUserDefaults standardUserDefaults] boolForKey:@"UseMediaKeys"];	
	[useMediaKeysItem setState:(useMediaKeys ? 1 : 0)];

    //show icon
    float width = 24.0;
    //float height = [[NSStatusBar systemStatusBar] thickness];
    //NSRect viewFrame = NSMakeRect(0, 0, width, height);
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:width] retain];
    //[statusItem setView:[[[StatusItemView alloc] initWithFrame:viewFrame controller:self] autorelease]];
	[statusItem setToolTip:@"Fan Radio"];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingPaneWillClose:) name:NSWindowWillCloseNotification object:settingsPane];
	
	//load channel
	channels = [NSArray arrayWithObjects:channelPersonal, channelChinese, channelEnglish, channel70s, channel80s, channel90s, channelCantonese, channelRock, channelFolk, channelLight, nil];
	lastChannel = [channels  objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"DoubanChannel"]];
	[lastChannel setState:1];
	radio.channelId = [lastChannel tag];
	[self markNormal];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBuffer:) name:MusicBufferNotification object:nil];
	NSLog(@"awaken");
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
	if (lastChannel) [lastChannel setState:0];
	lastChannel = sender;
	[sender setState:1];
	[radio tuneChannel:[sender tag]];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[sender tag]] forKey:@"DoubanChannel"];
}

- (IBAction)doShuffle:(id)sender {
	[radio playNext];
}

- (IBAction)openPage:(id)sender {
	if (radio.pageURL) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:radio.pageURL]];
	}
}

- (IBAction)saveSettings:(id)sender {
	//if (radio.username == [doubanUsernameItem stringValue] && radio.password == [doubanPasswordItem stringValue] ) return;
	radio.username = [doubanUsernameItem stringValue];
	radio.password = [doubanPasswordItem stringValue];
	[settingsPane close];
	NSLog(@"saved login info for %@", radio.username);
	[usernameItem setTitle:@"Logging in..."];
	[usernameItem setEnabled:NO];
	[radio recheckLogin];
}

- (IBAction)openUserPage:(id)sender {
	if (radio.loginSuccess) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:radio.profilePage]];
	} else {
		[settingsPane orderFront:nil];
	}

}

- (IBAction)openDoubanRegister:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.douban.com/register"]];
}

- (IBAction)turnOff:(id)sender {
	if ([turnOffItem state]==1) {
		[turnOffItem setState:0];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackEnded:) name:MusicOverNotification object:nil];
		[self playNext];
	} else {
		[turnOffItem setState:1];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MusicOverNotification object:nil];
		[Speaker stop];
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

- (IBAction)toggleUseMeidaKeys:(id)sender{
	useMediaKeys = [useMediaKeysItem state] != 0;
	NSLog(@"useMediaKeys: %d", useMediaKeys);
	[[NSUserDefaults standardUserDefaults] setBool:useMediaKeys forKey:@"UseMediaKeys"];	
}

- (void)updateUser:(NSNotification *)notification {
	[usernameItem setTitle:(radio.loginSuccess ? radio.nickname : @"Not Logged In")];
	[usernameItem setEnabled:YES];
	if (pendingPlay) {
		pendingPlay = NO;
		[self doShuffle:nil];
	}
}

- (void)playNext {
	[self performSelector:@selector(doShuffle:) withObject:nil afterDelay:1];
}

#define MAX_PLAY_TIME 30 * 60
#define MIN_PLAY_TIME 30 // ignore short clips, usually ads or unliked songs

- (void)trackEnded:(NSNotification *)notification {
	NSLog(@"track ended");
	if (lastPlayStarted > 0) {
		NSTimeInterval t = time(nil) - lastPlayStarted;
		if (t > MIN_PLAY_TIME) {
			if (t > MAX_PLAY_TIME) t = MAX_PLAY_TIME;
			radio.totalListenedTime = radio.totalListenedTime + t;
			radio.totalListenedTracks ++;
		}
	}
	lastPlayStarted = 0;
	[self playNext];
}

- (void)trackReady:(NSNotification *)notification {
	NSLog(@"track ready");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coverLoaded:) name:DataLoadedNotification object:[DataLoader load:radio.cover]];
}

- (void)dataBuffer:(NSNotification *)notification {
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
	[radio release];
	[statusItem release];
    [super dealloc];
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo {
	[aRecorder registerAsGlobalHotKeyFor:self withSelector:@selector(hitHotKey:)];
	switch ([aRecorder tag]) {
		case 0: //shuffle
			[[NSUserDefaults standardUserDefaults] setObject:[srShuffle toPlist] forKey:@"HotKeyShuffle"];
			break;
		case 1: //like
			[[NSUserDefaults standardUserDefaults] setObject:[srLike toPlist] forKey:@"HotKeyLike"];
			break;
		case 2: //ban
			[[NSUserDefaults standardUserDefaults] setObject:[srBan toPlist] forKey:@"HotKeyBan"];
			break;
	}
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

- (void)settingPaneWillClose:(NSNotification *)notification {
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
	[PerProcessHTTPCookieStore makeSurePerProcessHTTPCookieStoreLinkedIn];
}

+ (AppController *) instance {
	return _instance;
}
	 
@end
