//
//  DataPoster.m
//  FanRadio
//
//  Created by Du Song on 10-9-16.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "DataPoster.h"


@implementation DataPoster

- (id) initWithURLString:(NSString *)url andParameters:(NSString *)param {
	if (self = [super init]) {
		NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		//[req setValue:@"" forHTTPHeaderField:@"Cookie"];
		[req setHTTPMethod: @"POST"];
		[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
		[req setHTTPBody: [NSData dataWithBytes:[param UTF8String] length: [param length]]];
		_conn = [NSURLConnection connectionWithRequest:req delegate:self];
		_data = [[NSMutableData data] retain];
	}
	return self;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	NSLog(@"DataPoster Redirection %@", [[request URL] absoluteString]);
	return request;
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

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
	NSLog(@"DataPoster failed: %@", error);
	[[NSNotificationCenter defaultCenter] postNotificationName:DataLoadedNotification object:self userInfo:[NSDictionary dictionaryWithObject:_data forKey:@"data"]];
	[self autorelease];
}

- (void)dealloc {
	[_data release];
	[super dealloc];
}

+ (DataPoster *)post:(NSString *)url andParameters:(NSString *)param {
	return [[DataPoster alloc] initWithURLString:url andParameters:param];
}

@end


@implementation NSString (URLEncode) 

// URL encode a string 
+ (NSString *)URLEncodeString:(NSString *)string { 
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR("% '\"?=&+<>;:-"), kCFStringEncodingUTF8); 
	
    return [result autorelease]; 
} 

// Helper function 
- (NSString *)URLEncodeString { 
    return [NSString URLEncodeString:self]; 
} 

@end