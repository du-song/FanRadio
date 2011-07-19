//
//  PrefController.m
//  FanRadio
//
//  Created by Du Song on 11-3-3.
//  Copyright 2011 rollingcode.org. All rights reserved.
//

#import "FRPrefController.h"
#import "DoubanRadio.h"
#import "AppController.h"

@implementation FRPrefController

- (void)awakeFromNib {
	if ([DoubanRadio instance].username) [doubanUsernameItem setStringValue:[DoubanRadio instance].username];
	if ([DoubanRadio instance].password) [doubanPasswordItem setStringValue:[DoubanRadio instance].password];
	[srShuffle setTag:0];
	[srLike setTag:1];
	[srBan setTag:2];
	[srShuffle fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyShuffle"]];
	[srLike fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyLike"]];
	[srBan fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyBan"]];
	[useMediaKeysItem setState:([[NSUserDefaults standardUserDefaults] boolForKey:@"UseMediaKeys"] ? 1 : 0)];
	//FIXME [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingPaneWillClose:) name:NSWindowWillCloseNotification object:settingsPane];
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo {
	[aRecorder registerAsGlobalHotKeyFor:self withSelector:@selector(hitHotKey:)];
	switch ([aRecorder tag]) {
		case 0: //shuffle
			[[NSUserDefaults standardUserDefaults] setObject:[srShuffle toPlist] forKey:@"HotKeyShuffle"];
			break;
		case 1: //like
			[[NSUserDefaults standardUserDefaults] setObject:[srLike toPlist] forKey:@"HotKeyLike"];
			break;
		case 2: //ban
			[[NSUserDefaults standardUserDefaults] setObject:[srBan toPlist] forKey:@"HotKeyBan"];
			break;
	}
}

- (IBAction)toggleUseMeidaKeys:(id)sender{
	BOOL u = [useMediaKeysItem state] != 0;
	[[AppController instance] setUseMediaKeys: u];
	NSLog(@"useMediaKeys: %d", u);
	[[NSUserDefaults standardUserDefaults] setBool:u forKey:@"UseMediaKeys"];	
}

- (IBAction)saveSettings:(id)sender {
	//if (radio.username == [doubanUsernameItem stringValue] && radio.password == [doubanPasswordItem stringValue] ) return;
	[DoubanRadio instance].username = [doubanUsernameItem stringValue];
	[DoubanRadio instance].password = [doubanPasswordItem stringValue];
	//FIXME [settingsPane close];
	NSLog(@"saved login info for %@", [DoubanRadio instance].username);
	[[DoubanRadio instance] recheckLogin];
}

- (IBAction)openDoubanRegister:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.douban.com/register"]];
}

@end
