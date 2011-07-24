//
//  PrefController.h
//  FanRadio
//
//  Created by Du Song on 11-3-3.
//  Copyright 2011 rollingcode.org. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#if USE_SHORTCUT
#import "ShortcutRecorder/ShortcutRecorder.h"
#import "SRRecorderControl+PTKeyCombo.h"
#endif

@interface FRPrefController : NSWindowController<NSWindowDelegate> {
#if USE_SHORTCUT
/*	IBOutlet SRRecorderControl *srShuffle;
	IBOutlet SRRecorderControl *srLike;
	IBOutlet SRRecorderControl *srBan;*/
#endif
	IBOutlet NSTextField		*doubanUsernameItem;
	IBOutlet NSSecureTextField	*doubanPasswordItem;
	IBOutlet NSButton			*useMediaKeysItem;
	IBOutlet NSButton			*launchAtLoginItem;
	IBOutlet NSButton			*playAtLaunchItem;
}

- (void)awakeFromNib;
- (IBAction)setUseMediaKeys:(id)sender;
- (IBAction)doubanLogin:(id)sender;
- (IBAction)doubanRegister:(id)sender;
- (IBAction)toggleOpenAtLogon:(id)sender;
- (IBAction)togglePlayOnLaunch:(id)sender;

+ (void)showWindow:(id)owner;
@end
