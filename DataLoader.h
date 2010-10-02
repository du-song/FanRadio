//
//  DataLoader.h
//  FanRadio
//
//  Created by Du Song on 10-6-20.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const DataLoadedNotification;

@interface DataLoader : NSObject {
	NSURLConnection * _conn;
	NSMutableData * _data;
}

- (id) initWithURLString:(NSString *)url andCookie:(NSString *)cookie;

+ (DataLoader *)load:(NSString *)url;
+ (DataLoader *)load:(NSString *)url withCookie:(NSString *)cookie;

@end
