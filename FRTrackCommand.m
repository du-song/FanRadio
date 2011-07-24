//
//  FRTrackCommand.m
//  FanRadio
//
//  Created by Du Song on 10-7-1.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "FRTrackCommand.h"
#import "AppController.h"

@implementation FRTrackCommand

- (id)performDefaultImplementation {
    FWLog(@"FRTrackCommand performDefaultImplementation");
	NSString *s = [[AppController instance]->radio title];
	return s!=nil ? s : @"";
}

@end
