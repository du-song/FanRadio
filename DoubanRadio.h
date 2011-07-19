//
//  DoubanRadio.h
//  FanRadio
//
//  Created by Du Song on 10-6-17.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FRChannel.h"

extern NSString * const SongReadyNotification;
extern NSString * const LoginCheckedNotification;
extern NSString * const ChannelListLoadedNotification;

@interface DoubanRadio : NSObject<FRVendor> {
	XASSIGN NSUInteger _channelId;
	XASSIGN NSUInteger _lastChannelId;
	XASSIGN NSUInteger _sid;
	XASSIGN NSUInteger _aid;
	XASSIGN BOOL _liked;
	XASSIGN BOOL _loginSuccess;
	XRETAIN NSString *_title;
	XRETAIN NSString *_artist;
	XRETAIN NSString *_url;
	XRETAIN NSString *_album;
	XRETAIN NSString *_cover;
	XRETAIN NSString *_pageURL;
	XRETAIN NSString *_username;
	XRETAIN NSString *_password;
	XRETAIN NSString *_userId;
	XRETAIN NSString *_loginToken;
	XRETAIN NSString *_loginExpire;
	XRETAIN NSString *_nickname;
	XRETAIN NSString *_profilePage;
	XRETAIN NSString *_lastRequestUrl;
}

@property (nonatomic, assign) NSUInteger channelId;
@property (nonatomic, assign) NSUInteger lastChannelId;
@property (nonatomic, assign) NSUInteger sid;
@property (nonatomic, assign) NSUInteger aid;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, assign) BOOL loginSuccess;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *album;
@property (nonatomic, retain) NSString *cover;
@property (nonatomic, retain) NSString *pageURL;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *loginToken;
@property (nonatomic, retain) NSString *loginExpire;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *profilePage;
@property (nonatomic, retain) NSString *lastRequestUrl;

- (void)dealloc;
- (NSString *) username;
- (void) setUsername:(NSString *)username_;
- (NSString *) password;
- (void) setPassword:(NSString *)password_;
- (void)likeCurrent;
- (void)unlikeCurrent;
- (void)banCurrent;
- (void)skipCurrent;
- (void)endAndPlayNext;
- (void)tuneToChannel:(FRChannel *)newChannel;
- (void)recheckLogin;
- (void)perform:(NSString *)action reload:(BOOL)r;
- (void)checkLogin;
- (void)checkLoginComplete:(NSNotification *)notification;
- (void)loadChannelList;
- (void)loadChannelListComplete:(NSNotification *)notification;
- (void)songsFetched:(NSNotification *)notification;
- (NSInteger) totalListenedTime;
- (void) setTotalListenedTime:(NSInteger)time_;
- (NSInteger) totalListenedTracks;
- (void) setTotalListenedTracks:(NSInteger)tracks_;
+ (DoubanRadio *)instance;

@end
