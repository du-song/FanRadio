//
//  Growler.m
//  FanRadio
//
//  Created by Du Song on 10-6-19.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "Growler.h"
#import "Growl/Growl.h"

@implementation Growler
/*
- (id)init {
	if (self = [super init]) {
		_name = nil;
		_desc = nil;
		_title = nil;
		_data= nil;
	}
}
*/

- (void)growl:(NSString *)name title:(NSString *)title description:(NSString *)desc iconURL:(NSString *)iconURL {
	_name = [name retain];
	_desc = [desc retain];
	_title = [title retain];
    _conn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:iconURL]] delegate:self];
	_data = [[NSMutableData data] retain];
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
    [_data setLength:0]; 
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	[GrowlApplicationBridge notifyWithTitle:_title
								description:_desc
						   notificationName:_name
								   iconData:_data
								   priority:0
								   isSticky:NO
							   clickContext:nil];
	[self release];
}

- (void)dealloc {
	[_data release];
	[_desc release];
	[_title release];
	[_name release];
	[super dealloc];
}

+ (void)Growl:(NSString *)name title:(NSString *)title description:(NSString *)desc iconURL:(NSString *)iconURL {
	[[[Growler alloc] init] growl:name title:title description:desc iconURL:iconURL];
}

@end
