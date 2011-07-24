//
//  FRShuffleCommand.m
//  FanRadio
//
//  Created by Du Song on 10-7-1.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "FRShuffleCommand.h"
#import "AppController.h"

@implementation FRShuffleCommand

- (id)performDefaultImplementation {
    FWLog(@"FRShuffleCommand performDefaultImplementation");
	[[AppController instance] doShuffle:nil];
	return nil;
}

@end
