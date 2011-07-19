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
#import "DataPoster.h"
#import "RegexKitLite.h"
#import "SSGenericKeychainItem.h"
#import "FRChannel.h"
#import "FRChannelList.h"

NSString * const SongReadyNotification = @"SongReady";
NSString * const LoginCheckedNotification = @"LoginChecked";
NSString * const ChannelListLoadedNotification = @"ChannelListLoaded";

@implementation DoubanRadio

@synthesize channelId = _channelId;
@synthesize lastChannelId = _lastChannelId;
@synthesize sid = _sid;
@synthesize aid = _aid;
@synthesize liked = _liked;
@synthesize loginSuccess = _loginSuccess;
@synthesize title = _title;
@synthesize artist = _artist;
@synthesize url = _url;
@synthesize album = _album;
@synthesize cover = _cover;
@synthesize pageURL = _pageURL;
@synthesize username = _username;
@synthesize password = _password;
@synthesize userId = _userId;
@synthesize loginToken = _loginToken;
@synthesize loginExpire = _loginExpire;
@synthesize nickname = _nickname;
@synthesize profilePage = _profilePage;
@synthesize lastRequestUrl = _lastRequestUrl;

#define URL_PROFILE		"http://www.douban.com/people/%@/"
#define URL_PREFIX		"https://www.douban.com/j/app/radio/"
#define URL_TOKEN		"user_id=%@&expire=%@&token=%@"
#define URL_LOGIN		"https://www.douban.com/j/app/login?app_name=radio_iphone&version=20&email=%@&password=%@"
#define URL_PERFORM		URL_PREFIX "people?app_name=radio_iphone&version=20&type=%@&channel=%d&h=%@&du=%d&sid=%d&" URL_TOKEN
#define URL_CHANNELLIST	URL_PREFIX "channels?app_name=radio_iphone&version=20&" URL_TOKEN

static NSString *KeychainServiceName = @"FanRadio.Douban";

- (void)dealloc { 
	[_title release];
	[_artist release];
	[_url release];
	[_album release];
	[_cover release];
	[_pageURL release];
	[_username release];
	[_password release];
	[_userId release];
	[_loginToken release];
	[_loginExpire release];
	[_nickname release];
	[_profilePage release];
	[_lastRequestUrl release];
	[super dealloc];
}

- (NSString *) uuid {
	return @"douban";
}

- (NSString *) username {
	NSString *username_ = [[NSUserDefaults standardUserDefaults] stringForKey:@"DoubanUsername"];
	return username_ ? username_ : @"";
}

- (void) setUsername:(NSString *)username_ {
	[[NSUserDefaults standardUserDefaults] setValue:username_ forKey:@"DoubanUsername"];
}

- (NSString *) password {
	NSString *username_ = [self username];
	if ([username_ length]==0) return @"";
	NSString *password_ = [SSGenericKeychainItem passwordForUsername:username_ serviceName:KeychainServiceName];
	NSLog(@"getPassword %@ for %@", password_, username_);
	return password_ ? password_ : @"";
}

- (void) setPassword:(NSString *)password_ {
	NSString *username_ = [self username];
	if ([username_ length]==0) return;
	if (!password_) password_=@"";
	NSLog(@"setPassword %@ for %@", password_, username_);
	[SSGenericKeychainItem setPassword:password_ forUsername:username_ serviceName:KeychainServiceName];
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
- (void)skipCurrent {
	[self perform:@"s" reload:YES];
}
- (void)endAndPlayNext {
	if (_sid) [self perform:@"e" reload:NO];
	[self perform:@"n" reload:YES];
}

- (void)tuneToChannel:(FRChannel *)newChannel {
	_lastChannelId = _channelId;
	_channelId = newChannel.vendorChannelId;
	[self perform:@"n" reload:YES];
}

- (void)recheckLogin {
	[self checkLogin];
}

- (void)perform:(NSString *)action reload:(BOOL)r {
	NSString *url = [NSString stringWithFormat:@URL_PERFORM,
					 action, _channelId, /*h*/@"", /*du*/0, _sid,
					 self.userId, self.loginExpire, self.loginToken];
	if (r) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(songsFetched:) 
													 name:DataLoadedNotification 
												   object:[DataLoader load:url]];
	} else {
		[DataLoader load:url];
	}
}

- (void)checkLogin {
	NSLog(@"checkLogin %@", self.username);
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(checkLoginComplete:) 
												 name:DataLoadedNotification 
											   object:[DataLoader load:[NSString stringWithFormat:@URL_LOGIN,
																		[self.username URLEncodeString], 
																		[self.password URLEncodeString]]]];
}

- (void)checkLoginComplete:(NSNotification *)notification {
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	NSError *error;
	NSDictionary *json = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
	NSNumber *r = [json objectForKey:@"r"];
	self.loginSuccess = [r isEqualToNumber:[NSNumber numberWithInt:0]]; //check literally in case r is nil
	if (self.loginSuccess) {
		self.profilePage = [NSString stringWithFormat:@URL_PROFILE, 
							[json objectForKey:@"user_id"]];
		self.nickname = [json objectForKey:@"user_name"];
		self.userId = [json objectForKey:@"user_id"];
		self.loginToken = [json objectForKey:@"token"];
		self.loginExpire = [json objectForKey:@"expire"];
		NSLog(@"checkLoginComplete %@", self.nickname);
	} else {
		NSLog(@"login failed: %@", [json objectForKey:@"err"]);		
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:LoginCheckedNotification object:self];
}

- (void)loadChannelList {
	NSLog(@"loadChannelList");
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(loadChannelListComplete:) 
												 name:DataLoadedNotification 
											   object:[DataLoader load:[NSString stringWithFormat:@URL_CHANNELLIST,
																		self.userId, self.loginExpire, self.loginToken]]];
}

- (void)loadChannelListComplete:(NSNotification *)notification {
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	NSError *error;
	NSDictionary *json = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
	NSArray *channels = [json objectForKey:@"channels"];
	for (NSDictionary *item in channels) {
		FRChannel *channel = [[FRChannel alloc] initWithVendor:self];
		channel.name = [item objectForKey:@"name"];
		channel.nameEng = [item objectForKey:@"name_en"];
		channel.vendorChannelId = [[item objectForKey:@"channel_id"] integerValue];
		[[FRChannelList instance] addChannel:channel];
		[channel release];
	}
	NSLog(@"loadChannelListComplete %d loaded", [[FRChannelList instance].channels count]);
	[[NSNotificationCenter defaultCenter] postNotificationName:ChannelListLoadedNotification object:self];
}

- (void)songsFetched:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DataLoadedNotification object:[notification object]];
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	NSError *error = nil;
	NSDictionary *items = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
	NSArray *songs = [items objectForKey:@"song"];
	if (songs && [songs count]) {
		NSDictionary * song = [songs objectAtIndex:[songs count]-1];
		self.title = [song objectForKey:@"title"];
		self.artist = [song objectForKey:@"artist"];
		self.url = [song objectForKey:@"url"];
		self.album = [song objectForKey:@"albumtitle"];
		self.cover = [song objectForKey:@"picture"];
		self.pageURL = [NSString stringWithFormat:@"%@%@", @"http://music.douban.com", [song objectForKey:@"album"]];
		self.sid = [[song objectForKey:@"sid"] integerValue];
		self.aid = [[song objectForKey:@"aid"] integerValue];
		self.liked = [[song objectForKey:@"like"] boolValue];
		NSLog(@"songsFetched %@", self.title);
		[[NSNotificationCenter defaultCenter] postNotificationName:SongReadyNotification object:self];
	} else {
		NSLog(@"Song list not loaded. %@ %@", error, [items objectForKey:@"err"]);
		//TODO retry
	}
}

- (NSInteger) totalListenedTime {
	NSInteger time_ = [[NSUserDefaults standardUserDefaults] integerForKey:@"DoubanListenedTime"];
	return time_ > 0  ? time_ : 0;
}

- (void) setTotalListenedTime:(NSInteger)time_ {
	[[NSUserDefaults standardUserDefaults] setInteger:time_ forKey:@"DoubanListenedTime"];
}

- (NSInteger) totalListenedTracks {
	NSInteger tracks_ = [[NSUserDefaults standardUserDefaults] integerForKey:@"DoubanListenedTracks"];
	return tracks_>0 ? tracks_ : 0;
}

- (void) setTotalListenedTracks:(NSInteger)tracks_ {
	[[NSUserDefaults standardUserDefaults] setInteger:tracks_ forKey:@"DoubanListenedTracks"];
}

static DoubanRadio *_instance;

+ (DoubanRadio *)instance { 
	if (!_instance) { _instance = [[self alloc] init]; }
	return _instance; 
}

@end
