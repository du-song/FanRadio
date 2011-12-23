//
//  TestDouban.m
//  TestDouban
//
//  Created by Du Song on 11-12-3.
//  Copyright (c) 2011年 rollingcode.org All rights reserved.
//

#import "TestDouban.h"
#import "DoubanRadio.h"
#import "FRChannel.h"

@implementation TestDouban

static FRChannelList *list;
static DoubanRadio *douban;

- (void)setUp {
	[super setUp];
	if (!list) { // only initialize once
		list = [FRChannelList instance];
		douban = [DoubanRadio instance];
		douban.username = @"md-douban-test@rollingcode.org";
		douban.password = @"douban";
		NSLog(@"Test suite initialized.");
	}
	testDone = nil;
}

- (void)test1_Login {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginChecked:) name:LoginCheckedNotification object:douban];
	[douban checkLogin];
	while (!testDone && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	STAssertEqualObjects(testDone, @"success", @"test1_Login test should pass");
}

- (void)onLoginChecked:(NSNotification *)notification {
	if (douban.loginSuccess) {
		NSLog(@"%@ logged in as %@ / %@", douban, douban.username, douban.userId);
		testDone = @"success";
	} else {
		testDone = @"login fail";
	}
}

- (void)test2_LoadChannelList {
	[douban loadChannelList];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelListLoaded:) name:ChannelListLoadedNotification object:douban];
	while (!testDone && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	STAssertEqualObjects(testDone, @"success", @"test2_LoadChannelList test should pass");
}

- (void)onChannelListLoaded:(NSNotification *)notification {
	if ([[[FRChannelList instance] channels] count]>0) {
		NSLog(@"%@ loaded channel list %@", douban, [[FRChannelList instance] channels]);
		testDone = @"success";
	} else {
		testDone = @"LoadChannelList fail";
	}
}

- (void)test3_LoadSong {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSongReady:) name:SongReadyNotification object:douban];
	FRChannel *ch = [[[FRChannelList instance] channels] objectAtIndex:0];
	[ch tune];
	while (!testDone && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	STAssertEqualObjects(testDone, @"success", @"all test3_LoadSong should pass");
}

- (void)onSongReady:(NSNotification *)notification {
	if (douban.title && douban.url) {
		NSLog(@"%@ loaded song: %@", douban, douban.title);
		testDone = @"success";
	} else {
		testDone = @"test3_LoadSong fail";
	}
}

//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSongEnded:) name:SongReadyNotification object:douban];

- (void)onSongEnded:(NSNotification *)notification {
	NSLog(@"onSongEnded %@ loaded song %@", douban, douban.title);
}

- (void)tearDown {
	// Tear-down code here.
	[super tearDown];
}

- (void)dealloc {
	[super dealloc];
	NSLog(@"Test suite cleaned up.");
}
@end
