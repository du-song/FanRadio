//
//  FRChannelList.h
//  FanRadio
//
//  Created by Du Song on 37-5-9.
//  Copyright 2037 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FRChannel.h"

@interface FRChannelList : NSObject {
	XRETAIN NSMutableArray * channels;
}

@property (nonatomic, retain) NSMutableArray * channels;

- (FRChannelList *)init;
- (void)dealloc;
- (NSUInteger)addChannel:(FRChannel *)channel;
- (FRChannel *)channelByTag:(NSUInteger)tag;
- (FRChannel *)channelByUUID:(NSString *)uuid;
+ (FRChannelList *) instance;

@end
