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

@implementation AppController

AppController * _instance = nil;

- (void)awakeFromNib
{
	_instance = self;
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
	[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:[NSURL URLWithString:[radio userPage]]]  withAppBundleIdentifier:@"com.apple.Safari" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:NULL launchIdentifiers:NULL];
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
