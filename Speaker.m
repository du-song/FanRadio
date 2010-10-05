//
//  Speaker.m
//  FanRadio
//
//  Created by Du Song on 10-6-19.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "Speaker.h"
#import "AudioStreamer.h"

AudioStreamer * streamer = nil;
NSSound * sound = nil;

NSString * const MusicOverNotification = @"MusicOver";
NSString * const MusicBufferNotification = @"MusicBuffer";

@implementation Speaker

+(void) play:(NSString *)url {
	NSLog(@"play %@", url);
	[Speaker stop];
	streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:url]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioStatusChanged:) name:ASStatusChangedNotification object:streamer];
	[streamer start];
	
	/*
	sound = [[NSSound alloc] initWithContentsOfURL:[NSURL URLWithString:url] byReference:YES];
	[sound setDelegate:self];
	if (![sound play]) NSLog(@"failed");
	NSLog(@"started");
	*/
}

+(void) stop {
	if (streamer) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		[streamer stop];
		[streamer autorelease];
		streamer = nil;
	}
	if (sound) {
		[sound autorelease];
		sound = nil;
	}
}

+ (void)audioStatusChanged:(NSNotification *)notification {
	AudioStreamer *stream = [notification object];
	NSLog(@"AudioStatusChanged: %d", stream.state);
	if (stream.state == AS_INITIALIZED) {
		[[NSNotificationCenter defaultCenter] postNotificationName:MusicOverNotification object:self];
	} else if (stream.state == AS_BUFFERING) {
		[[NSNotificationCenter defaultCenter] postNotificationName:MusicBufferNotification object:self];
	}
}
+ (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying {
	[[NSNotificationCenter defaultCenter] postNotificationName:MusicOverNotification object:self];
}
@end
