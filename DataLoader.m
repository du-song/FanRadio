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

- (id) initWithURLString:(NSString *)url andCookie:(NSString *)cookie {
	if ((self = [super init])) {
		NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		if (cookie) [req setValue:cookie forHTTPHeaderField:@"Cookie"];
		_conn = [NSURLConnection connectionWithRequest:req delegate:self];
		_data = [[NSMutableData data] retain];
	}
	return self;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	//NSLog(@"DataLoader Redirection %@", [[request URL] absoluteString]);
	return request;
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
    [_data setLength:0]; 
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	//NSLog(@"DataLoader connectionDidFinishLoading: %@", conn);
	[[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotification object:self userInfo:[NSDictionary dictionaryWithObject:_data forKey:@"data"]];
	[self autorelease];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
	NSLog(@"DataLoader failed: %@", error);
	[[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotification object:self userInfo:[NSDictionary dictionaryWithObject:_data forKey:@"data"]];
	[self autorelease];
}

- (void)dealloc {
	[_data release];
	[super dealloc];
}

+ (DataLoader *)load:(NSString *)url {
	return [[DataLoader alloc] initWithURLString:url andCookie:nil];
}

+ (DataLoader *)load:(NSString *)url withCookie:(NSString *)cookie {
	return [[DataLoader alloc] initWithURLString:url andCookie:cookie];
}

@end
