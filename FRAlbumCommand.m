//
//  FRAlbumCommand.m
//  FanRadio
//
//  Created by Du Song on 10-7-1.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "FRAlbumCommand.h"
#import "AppController.h"

@implementation FRAlbumCommand

- (id)performDefaultImplementation {
    FWLog(@"FRAlbumCommand performDefaultImplementation");
	NSString *s = [[AppController instance]->radio album];
	return s!=nil ? s : @"";
}

@end
