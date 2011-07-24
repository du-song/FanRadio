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
#import "LaunchAtLoginController.h"
@implementation FRPrefController

- (void)awakeFromNib {
	if ([DoubanRadio instance].username) [doubanUsernameItem setStringValue:[DoubanRadio instance].username];
	if ([DoubanRadio instance].password) [doubanPasswordItem setStringValue:[DoubanRadio instance].password];
	[useMediaKeysItem setState:[AppController instance].useMediaKeys];
	LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
	BOOL launch = [launchController launchAtLogin];
	[launchController release];
	[launchAtLoginItem setState:launch];
	[useMediaKeysItem setState:([[NSUserDefaults standardUserDefaults] boolForKey:@"UseMediaKeys"] ? 1 : 0)];
	[playAtLaunchItem setState:([[NSUserDefaults standardUserDefaults] boolForKey:@"PlayOnLaunch"] ? 1 : 0)];
#if USE_SHORTCUT
	[srShuffle setTag:0];
	[srLike setTag:1];
	[srBan setTag:2];
	[srShuffle fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyShuffle"]];
	[srLike fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyLike"]];
	[srBan fromPlist:[[NSUserDefaults standardUserDefaults] valueForKey:@"HotKeyBan"]];
#endif
}

#if USE_SHORTCUT
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
#endif

- (IBAction)setUseMediaKeys:(id)sender {
	BOOL u = [useMediaKeysItem state] != 0;
	[AppController instance].useMediaKeys = u;
	[[NSUserDefaults standardUserDefaults] setBool:u forKey:@"UseMediaKeys"];	
	FWLog(@"useMediaKeys: %d", u);
}

- (IBAction)doubanLogin:(id)sender {
	//if (radio.username == [doubanUsernameItem stringValue] && radio.password == [doubanPasswordItem stringValue] ) return;
	[DoubanRadio instance].username = [doubanUsernameItem stringValue];
	[DoubanRadio instance].password = [doubanPasswordItem stringValue];
	//FIXME [settingsPane close];
	FWLog(@"saved login info for %@", [DoubanRadio instance].username);
	[[DoubanRadio instance] recheckLogin];
}

- (IBAction)doubanRegister:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.douban.com/register"]];
}

static NSWindowController *wc = nil;

- (void)windowWillClose:(NSNotification *)notification {
	FWLog(@"close FRPrefController");
	[wc autorelease];
	wc = nil;
}

- (IBAction)toggleOpenAtLogon:(id)sender {
	LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
	[launchController setLaunchAtLogin:launchAtLoginItem.state != 0];
	[launchController release];
}

- (IBAction)togglePlayOnLaunch:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:playAtLaunchItem.state!=0 forKey:@"PlayOnLaunch"];	
}

+ (void)showWindow:(id)owner {
	if (!wc) wc = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
	[wc showWindow:owner];
	[[wc window] orderFront:owner];
	//return _instance;
	//[_instance showWindow:self];
}

- (id) init{
	if ( ! (self = [super init]) ) {
		return nil;
	}
	FWLog(@"init FRPrefController");
	return self;
}

- (void)dealloc {
	FWLog(@"dealloc FRPrefController");
	//if (self == _instance) _instance = nil;
	[super dealloc];
}
@end
