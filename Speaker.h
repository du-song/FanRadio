//
//  Speaker.h
//  FanRadio
//
//  Created by Du Song on 10-6-19.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const MusicOverNotification;
extern NSString * const MusicBufferNotification;

@interface Speaker : NSObject {

}
+(void)play:(NSString *)url;
+(void)stop;
+(void)audioStatusChanged:(NSNotification *)notification; //private

@end
