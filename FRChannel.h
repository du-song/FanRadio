//
//  FRChannel.h
//  FanRadio
//
//  Created by Du Song on 11-7-19.
//  Copyright 2011 rollingcode.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FRChannel;

@protocol FRVendor 

- (NSString *)uuid;
- (void)tuneToChannel:(FRChannel *)newChannel;

@end

@interface FRChannel : NSObject {
	XASSIGN NSUInteger _vendorChannelId;
	XASSIGN NSUInteger _tag;
	XRETAIN NSString *_name;
	XRETAIN NSString *_nameEng;
	XASSIGN	id<FRVendor> _vendor;
}

@property (nonatomic, assign) NSUInteger vendorChannelId;
@property (nonatomic, assign) NSUInteger tag;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *nameEng;
@property (nonatomic, assign) id<FRVendor> vendor;

- (void)dealloc;
- (id)initWithVendor:(id<FRVendor>) vendor;
- (void)tune;
- (NSString *)uuid;

@end
