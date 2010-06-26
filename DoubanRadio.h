//
//  DoubanRadio.h
//  FanRadio
//
//  Created by Du Song on 10-6-17.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const SongReadyNotification;

@interface DoubanRadio : NSObject {
	XASSIGN NSUInteger _channelId;
	XRETAIN NSString *_title;
	XRETAIN NSString *_artist;
	XRETAIN NSString *_url;
	XRETAIN NSString *_album;
	XRETAIN NSString *_cover;
	XRETAIN NSString *_pageURL;
}

- (void)dealloc;
- (void)getList;
- (void)songsFetched:(NSNotification *)notification;

@property (nonatomic, assign) NSUInteger channelId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *album;
@property (nonatomic, retain) NSString *cover;
@property (nonatomic, retain) NSString *pageURL;

@end
