//
//  Speaker.h
//  FanRadio
//
//  Created by Du Song on 10-6-19.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const SongEndedNotification;
extern NSString * const SongBufferingNotification;

@interface Speaker : NSObject {

}
+(void)play:(NSString *)url;
+(void)pause;
+(void)resume;
+(void)stop;
+(void)audioStatusChanged:(NSNotification *)notification; //private

@end
