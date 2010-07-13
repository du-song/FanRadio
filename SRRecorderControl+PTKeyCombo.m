//
//  SRRecorderControl+PTKeyCombo.m
//  FanRadio
//
//  Created by Du Song on 10-7-13.
//  Copyright 2010 rollingcode.org. All rights reserved.
//

#import "SRRecorderControl+PTKeyCombo.h"

@implementation SRRecorderControl(SRRecorderControl_PTKeyCombo)

- (PTKeyCombo *) toPTKeyCombo {
	return [PTKeyCombo keyComboWithKeyCode:[self keyCombo].code
								 modifiers:[self cocoaToCarbonFlags:[self keyCombo].flags]];
}

- (void) fromPTKeyCombo:(PTKeyCombo *)ptKC {
	KeyCombo kc;
	kc.flags = [self carbonToCocoaFlags:[ptKC modifiers]];
	kc.code = [ptKC keyCode];
	[self setKeyCombo:kc];
}

- (void) registerAsGlobalHotKeyFor:(id)obj withSelector:(SEL)sel {
	[self unregisterAsGlobalHotKey];
	PTHotKey* globalHotKey = [[PTHotKey alloc] initWithIdentifier:self
											   keyCombo:[self toPTKeyCombo]];
	[globalHotKey setTarget:obj];
	[globalHotKey setAction:sel];
	[[PTHotKeyCenter sharedCenter] registerHotKey:globalHotKey];
}

- (void) unregisterAsGlobalHotKey {
	PTHotKey* globalHotKey = [[PTHotKeyCenter sharedCenter] hotKeyWithIdentifier:self];
	if (globalHotKey) {
		[[PTHotKeyCenter sharedCenter] unregisterHotKey:globalHotKey];
		[globalHotKey release];
	}
}

- (id) toPlist {
	return [[self toPTKeyCombo] plistRepresentation];
}

- (void) fromPlist:(id)plist {
	PTKeyCombo * kc = [[PTKeyCombo alloc] initWithPlistRepresentation:plist];
	[self fromPTKeyCombo:kc];
	[kc release];
}

@end
