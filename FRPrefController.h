//
//  PrefController.h
//  FanRadio
//
//  Created by Du Song on 11-3-3.
//  Copyright 2011 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShortcutRecorder/ShortcutRecorder.h"
#import "SRRecorderControl+PTKeyCombo.h"

@interface FRPrefController : NSObject {
	IBOutlet SRRecorderControl *srShuffle;
	IBOutlet SRRecorderControl *srLike;
	IBOutlet SRRecorderControl *srBan;
	
	IBOutlet NSTextField *doubanUsernameItem;
	IBOutlet NSSecureTextField *doubanPasswordItem;
	IBOutlet NSButton *useMediaKeysItem;
}

- (void)awakeFromNib;
@end
