//
//  DataLoader.m
//  FanRadio
//
//  Created by Du Song on 10-6-20.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "DataLoader.h"

NSString * const DataLoadedNotification = @"DataLoaded";

@implementation DataLoader

- (id) initWithURLString:(NSString *)url {
	if (self = [super init]) {
		_conn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
		_data = [[NSMutableData data] retain];
	}
	return self;
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
    [_data setLength:0]; 
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	[[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotification object:self userInfo:[NSDictionary dictionaryWithObject:_data forKey:@"data"]];
	[self autorelease];
}

- (void)dealloc {
	[_data release];
	[super dealloc];
}

+ (DataLoader *)load:(NSString *)url {
	return [[DataLoader alloc] initWithURLString:url];
}

@end
