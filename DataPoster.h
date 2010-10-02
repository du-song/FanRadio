//
//  DataPoster.h
//  FanRadio
//
//  Created by Du Song on 10-9-16.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataLoader.h"

@interface DataPoster : NSObject {
	NSURLConnection * _conn;
	NSMutableData * _data;
}

- (id) initWithURLString:(NSString *)url andParameters:(NSString *)param;

+ (DataPoster *)post:(NSString *)url andParameters:(NSString *)param;

@end

@interface NSString (URLEncode) 
+ (NSString *)URLEncodeString:(NSString *)string; 
- (NSString *)URLEncodeString; 
@end  
