//
//  FRChannelList.m
//  FanRadio
//
//  Created by Du Song on 37-5-9.
//  Copyright 2037 rollingcode.org. All rights reserved.
//

#import "FRChannelList.h"

@implementation FRChannelList

@synthesize  channels;

static NSUInteger lastTag = 1911000;
static FRChannelList *_instance = nil;

- (FRChannelList *)init {
	self = [super init];
	if (self != nil)
	{
		channels = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc { 
	[ channels release];
	[super dealloc];
}

- (NSUInteger)addChannel:(FRChannel *)channel {
	lastTag++;
	channel.tag = lastTag;
	[channels addObject:channel];
	return lastTag;
}

- (FRChannel *)channelByTag:(NSUInteger)tag {
	for (FRChannel *channel in channels) {
		if (channel.tag == tag) return channel;
	}
	return nil;
}

- (FRChannel *)channelByUUID:(NSString *)uuid {
	for (FRChannel *channel in channels) {
		if ([uuid isEqualToString:[channel uuid]]) return channel;
	}
	return nil;
}

+ (FRChannelList *) instance {
	if (!_instance) _instance = [[FRChannelList alloc] init];
	return _instance;
}

@end
