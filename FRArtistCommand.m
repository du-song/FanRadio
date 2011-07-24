//
//  FRArtistCommand.m
//  FanRadio
//
//  Created by Du Song on 10-7-1.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "FRArtistCommand.h"
#import "AppController.h"

@implementation FRArtistCommand

- (id)performDefaultImplementation {
    FWLog(@"FRArtistCommand performDefaultImplementation");
	NSString *s = [[AppController instance]->radio artist];
	return s!=nil ? s : @"";
}

@end
