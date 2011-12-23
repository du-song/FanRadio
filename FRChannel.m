//
//  FRChannel.m
//  FanRadio
//
//  Created by Du Song on 11-7-19.
//  Copyright 2011 rollingcode.org. All rights reserved.
//

#import "FRChannel.h"


@implementation FRChannel

@synthesize vendorChannelId = _vendorChannelId;
@synthesize tag = _tag;
@synthesize name = _name;
@synthesize nameEng = _nameEng;
@synthesize vendor = _vendor;

- (NSString *) description {
	return _inChinese ? self.name : self.nameEng;
}

- (void)dealloc { 
	[_name release];
	[_nameEng release];
	[super dealloc];
}

- (id)initWithVendor:(id<FRVendor>) vendor {
	self = [super init];
	if (self != nil)
	{
		_vendor = vendor;
	}
	return self;
}

- (void)tune {
	[_vendor tuneToChannel:self];
}

- (NSString *)uuid {
	return [NSString stringWithFormat:@"%@-%d", [_vendor uuid], _vendorChannelId];
}

@end
