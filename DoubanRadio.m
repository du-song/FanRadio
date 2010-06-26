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

NSString * const SongReadyNotification = @"SongReady";

@implementation DoubanRadio

@synthesize channelId = _channelId;
@synthesize lastChannelId = _lastChannelId;
@synthesize sid = _sid;
@synthesize aid = _aid;
@synthesize title = _title;
@synthesize artist = _artist;
@synthesize url = _url;
@synthesize album = _album;
@synthesize cover = _cover;
@synthesize pageURL = _pageURL;

- (void)dealloc { 
	[_title release];
	[_artist release];
	[_url release];
	[_album release];
	[_cover release];
	[_pageURL release];
	[super dealloc];
}

- (void)perform:(NSString *)action {
	NSString *url = [NSString stringWithFormat:@"http://douban.fm/j/mine/playlist?type=%@&channel=%lu&sid=%lu&aid=%lu", 
					 action, _channelId, _sid, _aid, _lastChannelId];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songsFetched:) name:DataLoadedNotification object:[DataLoader load:url]];
	_lastChannelId = _channelId;
}
- (void)likeCurrent {
	[self perform:@"s"];
}
- (void)unlikeCurrent {
	[self perform:@"s"];
}
- (void)banCurrent {
	[self perform:@"s"];
}
- (void)playNext {
	[self perform:@"s"];
}
- (void)tuneChannel:(NSUInteger)newChannelId {
	_lastChannelId = _channelId;
	_channelId = newChannelId;
	[self playNext];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:SongReadyNotification object:self];
	}
}

@end
