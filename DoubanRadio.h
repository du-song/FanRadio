//
//  DoubanRadio.h
//  FanRadio
//
//  Created by Du Song on 10-6-17.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const SongReadyNotification;
extern NSString * const LoginCheckedNotification;

@interface DoubanRadio : NSObject {
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
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *profilePage;
@property (nonatomic, retain) NSString *lastRequestUrl;

- (NSString *) username;
- (void) setUsername:(NSString *)username_;
- (NSString *) password;
- (void) setPassword:(NSString *)password_;
- (void)dealloc;
- (void)perform:(NSString *)action reload:(BOOL)r;
- (void)performInternal:(NSString *)url_;
- (void)likeCurrent;
- (void)unlikeCurrent;
- (void)banCurrent;
- (void)playNext;
- (void)tuneChannel:(NSUInteger)newChannelId;
- (void)recheckLogin;
- (void)recheckLoginCleanUpDone:(NSNotification *)notification;
- (void)checkLogin;
- (void)checkLoginComplete:(NSNotification *)notification;
- (void)songsFetched:(NSNotification *)notification;
- (NSInteger) totalListenedTime;
- (void) setTotalListenedTime:(NSInteger)time_;
- (NSInteger) totalListenedTracks;
- (void) setTotalListenedTracks:(NSInteger)tracks_;
- (NSArray *) channelList;

@end
