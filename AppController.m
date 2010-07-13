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
#import "SRRecorderControl+PTKeyCombo.h"

@implementation AppController

AppController * _instance = nil;

- (void)awakeFromNib {
	_instance = self;
	[srShuffle setTag:0];
	[srLike setTag:1];
	[srBan setTag:2];
	[srShuffle fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyShuffle"]];
	[srLike fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyLike"]];
	[srBan fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyBan"]];
	NSLog(@"FanRadio Start");
	[GrowlApplicationBridge setGrowlDelegate:self];
    // Create an NSStatusItem.
    float width = 20.0;
    //float height = [[NSStatusBar systemStatusBar] thickness];
    //NSRect viewFrame = NSMakeRect(0, 0, width, height);
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:width] retain];
    //[statusItem setView:[[[StatusItemView alloc] initWithFrame:viewFrame controller:self] autorelease]];
	[statusItem setTitle:@"♪"];
	[statusItem setToolTip:@"Douban Radio"];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	radio = [[DoubanRadio alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicOver:) name:MusicOverNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songReady:) name:SongReadyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:LoginCheckedNotification object:nil];
	[radio checkLogin];
	channels = [NSArray arrayWithObjects:channelPersonal, channelChinese, channelEnglish, channel70s, channel80s, channel90s, channelCantonese, nil];
	lastChannel = [channels  objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"DoubanChannel"]];
	[lastChannel setState:1];
	radio.channelId = [lastChannel tag];
	[self playNext];	
}

- (IBAction)like:(id)sender {
	if ([likeItem state]) {
		[radio unlikeCurrent];
		[likeItem setState:0];
	} else {
		[radio likeCurrent];
		[likeItem setState:1];
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
	NSLog(@"doShuffle");
	[radio playNext];
}

- (IBAction)openPage:(id)sender {
	if (radio.pageURL) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:radio.pageURL]];
	}
}

- (IBAction)saveSettings:(id)sender {
	[settingsPane close];
}

- (IBAction)openUserPage:(id)sender {
	if (radio.username) {
		[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:[NSURL URLWithString:[radio userPage]]]  withAppBundleIdentifier:@"com.apple.Safari" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:NULL launchIdentifiers:NULL];
	} else {
		[loginPromptPane makeKeyAndOrderFront:nil];
		[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:[NSURL URLWithString:@"http://douban.fm/login"]]  withAppBundleIdentifier:@"com.apple.Safari" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:NULL launchIdentifiers:NULL];
	}

}

- (IBAction)relaunchApp:(id)sender {
	[self restartOurselves];
}


- (void)updateUser:(NSNotification *)notification {
	if (radio.username) {
		[usernameItem setTitle:radio.username];
	}
	//[usernameItem setTitle:(radio.username ? radio.username : @"Not Logged In")];
}
- (void)playNext {
	[self performSelector:@selector(doShuffle:) withObject:nil afterDelay:1];
}

- (void)musicOver:(NSNotification *)notification {
	NSLog(@"Music is over");
	[self playNext];
}

- (void)songReady:(NSNotification *)notification {
	NSLog(@"Song is ready");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coverLoaded:) name:DataLoadedNotification object:[DataLoader load:radio.cover]];
}

- (void)coverLoaded:(NSNotification *)notification {
	NSLog(@"Cover is loaded");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DataLoadedNotification object:[notification object]];
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	[Speaker play:radio.url];
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
}

- (void)dealloc {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
	[radio release];
	[statusItem release];
    [super dealloc];
}

- (void)restartOurselves {
	//$N = argv[N]
	NSString *killArg1AndOpenArg2Script = @"kill -9 $1 \n sleep 1 \n open \"$2\"";
	
	//NSTask needs its arguments to be strings
	NSString *ourPID = [NSString stringWithFormat:@"%d",
						[[NSProcessInfo processInfo] processIdentifier]];
	
	//this will be the path to the .app bundle,
	//not the executable inside it; exactly what `open` wants
	NSString * pathToUs = [[NSBundle mainBundle] bundlePath];
	
	NSArray *shArgs = [NSArray arrayWithObjects:@"-c", // -c tells sh to execute the next argument, passing it the remaining arguments.
					   killArg1AndOpenArg2Script,
					   @"", //$0 path to script (ignored)
					   ourPID, //$1 in restartScript
					   pathToUs, //$2 in the restartScript
					   nil];
	NSTask *restartTask = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:shArgs];
	[restartTask waitUntilExit]; //wait for killArg1AndOpenArg2Script to finish
	NSLog(@"*** ERROR: %@ should have been terminated, but we are still running", pathToUs);
	assert(!"We should not be running!");
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
	NSLog(@"hitShuffle %d", [[hotKey identifier] tag]);
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


+ (void)initialize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
								 dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:@"DoubanChannel"];
    [defaults registerDefaults:appDefaults];
}

+ (AppController *) instance {
	return _instance;
}
@end
