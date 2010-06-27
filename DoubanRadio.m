//
//  DoubanRadio.m
//  FanRadio
//
//  Created by Du Song on 10-6-17.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "DoubanRadio.h"
#import "CJSONDeserializer.h"
#import "Speaker.h"
#import "DataLoader.h"
#import "RegexKitLite.h"

NSString * const SongReadyNotification = @"SongReady";
NSString * const LoginCheckedNotification = @"LoginChecked";

@implementation DoubanRadio

@synthesize channelId = _channelId;
@synthesize lastChannelId = _lastChannelId;
@synthesize sid = _sid;
@synthesize aid = _aid;
@synthesize liked = _liked;
@synthesize title = _title;
@synthesize artist = _artist;
@synthesize url = _url;
@synthesize album = _album;
@synthesize cover = _cover;
@synthesize pageURL = _pageURL;
@synthesize username = _username;

- (void)dealloc { 
	[_title release];
	[_artist release];
	[_url release];
	[_album release];
	[_cover release];
	[_pageURL release];
	[_username release];
	[super dealloc];
}

- (void)perform:(NSString *)action reload:(BOOL)r {
	NSString *url = [NSString stringWithFormat:@"http://douban.fm/j/mine/playlist?type=%@&channel=%lu&sid=%lu&aid=%lu&last_channel=%lu", 
					 action, _channelId, _sid, _aid, _lastChannelId];
	_lastChannelId = _channelId;
	if (r) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(songsFetched:) 
													 name:DataLoadedNotification 
												   object:[DataLoader load:url]];
	} else {
		[DataLoader load:url];
	}
}
- (void)likeCurrent {
	[self perform:@"r" reload:NO];
}
- (void)unlikeCurrent {
	[self perform:@"u" reload:NO];
}
- (void)banCurrent {
	[self perform:@"b" reload:YES];
}
- (void)playNext {
	[self perform:@"s" reload:YES];
}
- (void)tuneChannel:(NSUInteger)newChannelId {
	_lastChannelId = _channelId;
	_channelId = newChannelId;
	[self playNext];
}
- (void)checkLogin {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(homeLoaded:) 
												 name:DataLoadedNotification 
											   object:[DataLoader load:@"http://douban.fm/"]];
}
- (void)homeLoaded:(NSNotification *)notification {
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSArray *matches = [NSArray arrayWithArray:[str arrayOfCaptureComponentsMatchedByRegex:@"<a href=\"http://www\\.douban\\.com/accounts/\" target=\"_blank\">([^<]+)</a>"]];
	NSLog(@"%@", matches);
	if ([matches count]) {
		self.username = [[matches objectAtIndex:0] objectAtIndex:1];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:LoginCheckedNotification object:self];
}

- (void)songsFetched:(NSNotification *)notification {
	//NSString *responseString = [request responseString];
	//NSLog(@"FIN %@", responseString);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DataLoadedNotification object:[notification object]];
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	NSError *error;
	NSDictionary *items = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
	NSLog(@"JSON %lu", [items count]);
	NSArray *songs = [items objectForKey:@"song"];
	if (songs && [songs count]) {
		NSDictionary * song = [songs objectAtIndex:0];
		self.title = [song objectForKey:@"title"];
		self.artist = [song objectForKey:@"artist"];
		self.url = [song objectForKey:@"url"];
		self.album = [song objectForKey:@"albumtitle"];
		self.cover = [song objectForKey:@"picture"];
		self.pageURL = [NSString stringWithFormat:@"%@%@", @"http://music.douban.com", [song objectForKey:@"album"]];
		self.sid = [[song objectForKey:@"sid"] integerValue];
		self.aid = [[song objectForKey:@"aid"] integerValue];
		self.liked = [[song objectForKey:@"like"] boolValue];
		[[NSNotificationCenter defaultCenter] postNotificationName:SongReadyNotification object:self];
	}
}

- (NSString *)userPage {
	return @"http://douban.fm/mine";
}

@end
