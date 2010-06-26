//
//  StatusItemView.h
//  FanRadio
//
//  Created by Du Song on 10-6-16.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"

@interface StatusItemView : NSView {
	AppController *controller;
    BOOL clicked;
}

- (id)initWithFrame:(NSRect)frame controller:(AppController *)ctrlr;

@end
