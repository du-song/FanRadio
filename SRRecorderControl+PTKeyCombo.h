//
//  SRRecorderControl+PTKeyCombo.h
//  FanRadio
//
//  Created by Du Song on 10-7-13.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShortcutRecorder/ShortcutRecorder.h"
#import "PTKeyCombo.h"
#import "PTHotKey.h"
#import "PTHotKeyCenter.h"

@interface SRRecorderControl (SRRecorderControl_PTKeyCombo)

- (PTKeyCombo *) toPTKeyCombo;
- (void) fromPTKeyCombo:(PTKeyCombo *)ptKC;
- (void) registerAsGlobalHotKeyFor:(id)obj withSelector:(SEL)sel ;
- (void) unregisterAsGlobalHotKey;
- (id) toPlist;
- (void) fromPlist:(id)plist;
	
@end
