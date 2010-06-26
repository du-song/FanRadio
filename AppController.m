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

- (void)awakeFromNib
{
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
	radio.channelId = 1;
	[self playNext];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicOver:) name:MusicOverNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songReady:) name:SongReadyNotification object:nil];
}

- (IBAction)doShuffle:(id)sender {
	NSLog(@"doShuffle");
	[radio getList];
}

- (IBAction)openPage:(id)sender {
	if (radio.pageURL) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:radio.pageURL]];
	}
}

- (void)playNext {
	[self performSelector:@selector(doShuffle:) withObject:nil afterDelay:2];
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
@end
