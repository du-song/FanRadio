//
//  Growler.h
//  FanRadio
//
//  Created by Du Song on 10-6-19.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Growler : NSObject {
@private
	NSURLConnection * _conn;
	NSMutableData * _data;
	NSString * _title;
	NSString * _desc;
	NSString * _name;
}
- (void) growl:(NSString *)name title:(NSString *)title description:(NSString *)desc iconURL:(NSString *)iconURL;
+ (void) Growl:(NSString *)name title:(NSString *)title description:(NSString *)desc iconURL:(NSString *)iconURL;
@end
