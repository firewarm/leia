#include "LEIARootListController.h"
#include <spawn.h>

@implementation LEIARootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}


- (void)openGithub {

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/firewarmm"] options:@{} completionHandler:nil];
}

- (void)openTwitter {

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://twitter.com/firewarmm"] options:@{} completionHandler:nil];
}

- (void)openDonatePage {

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://paypal.me/baswilson"] options:@{} completionHandler:nil];
}

- (void)respring {
	pid_t pid;
	const char* args[] = {"killall", "-9", "backboardd", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end
