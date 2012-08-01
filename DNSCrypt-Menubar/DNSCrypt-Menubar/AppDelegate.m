//
//  AppDelegate.m
//  DNSCrypt-Menubar
//
//  Created by OpenDNS, Inc. on 10/31/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "Sparkle/Sparkle.h"

@implementation AppDelegate
@synthesize statusResolversMenuItem = _statusResolversMenuItem;
@synthesize statusConfigurationMenuItem = _statusConfigurationMenuItem;
@synthesize familyShieldMenuItem = _familyShieldMenuItem;
@synthesize dnscryptMenuItem = _dnscryptMenuItem;
@synthesize fallbackMenuItem = _fallbackMenuItem;
@synthesize window = _window;
@synthesize dnscryptMenu = _dnscryptMenu;
@synthesize statusItem = _statusItem;
@synthesize versionMenuItem = _versionMenuItem;

DNSConfigurationState currentState = kDNS_CONFIGURATION_UNKNOWN;

- (NSString *) fromCommand: (NSString *) launchPath withArguments: (NSArray *) arguments
{
    NSPipe *pipe = [NSPipe pipe];
    NSTask *task = [[NSTask alloc] init];
    NSData *data;
    NSString *result;
    task.launchPath = launchPath;
    task.arguments = arguments;
    task.standardOutput = pipe;
    [task launch];
    data = [[pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    if ([result hasSuffix: @"\n"]) {
        result = [result substringToIndex: result.length - 1];
    }
    return result;
}

- (void) initState
{
    NSString *stateDescription = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-resolvers-description.sh", nil]];
    NSLog(@"%@", stateDescription);
    [_dnscryptMenuItem setState: 0];
    [_familyShieldMenuItem setState: 0];
    [_fallbackMenuItem setState: 0];
    if ([stateDescription isEqualToString: @"FamilyShield"]) {
        [_familyShieldMenuItem setState: 1];
    } else if ([stateDescription isEqualToString: @"DNSCrypt"]) {
        [_dnscryptMenuItem setState: 1];
    } else if ([stateDescription isEqualToString: @"OpenDNS"]) {
    } else if ([stateDescription isEqualToString: @"OpenDNS IPv6"]) {
    } else if ([stateDescription isEqualToString: @"Localhost"]) {
    } else if ([stateDescription isEqualToString: @"Localhost IPv6"]) {
    } else if ([stateDescription isEqualToString: @"None"]) {
    } else if ([stateDescription isEqualToString: @"Updating"]) {
    }
}

- (BOOL) resolversForService: (NSArray *) resolversForService includeResolvers:(NSArray *) resolvers
{
    NSUInteger matches = 0U;
    
    for (NSString *resolverForService in resolversForService) {
        if ([resolvers containsObject: resolverForService]) {
            matches++;
        } else {
            break;
        }
    }
    if (matches >= resolvers.count) {
        return TRUE;
    }
    return FALSE;
}

- (void) updateLedStatusWaiting
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *led = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"no-network.png"]];
    _statusItem.image = led;   
}

- (void) updateLedStatus
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *led = nil;
    
    switch (currentState) {
        case kDNS_CONFIGURATION_OPENDNS:
            led = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"yes-opendns-no-crypt.png"]];
            break;
        case kDNS_CONFIGURATION_LOCALHOST:
            led = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"yes-opendns-yes-crypt.png"]];
            break;
        case kDNS_CONFIGURATION_VANILLA:
            led = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"no-opendns.png"]];
            break;
        default:
            led = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"no-network.png"]];
    }
    _statusItem.image = led;
}

- (BOOL) updateStatusWithCurrentConfig
{    
    currentState = kDNS_CONFIGURATION_UNKNOWN;
    
    NSString *stateDescription = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-resolvers-description.sh", nil]];
    NSLog(@"%@", stateDescription);
    if ([stateDescription isEqualToString: @"FamilyShield"]) {
        currentState = kDNS_CONFIGURATION_OPENDNS;
    } else if ([stateDescription isEqualToString: @"DNSCrypt"]) {
        currentState = kDNS_CONFIGURATION_LOCALHOST;
    } else if ([stateDescription isEqualToString: @"OpenDNS"]) {
        currentState = kDNS_CONFIGURATION_OPENDNS;
    } else if ([stateDescription isEqualToString: @"OpenDNS IPv6"]) {
        currentState = kDNS_CONFIGURATION_OPENDNS;
    } else if ([stateDescription isEqualToString: @"None"]) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
    } else if ([stateDescription isEqualToString: @"Updating"]) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
    } else if (stateDescription.length > 0) {
        currentState = kDNS_CONFIGURATION_VANILLA;
    }
    [self updateLedStatus];
    
    NSString *currentResolvers = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-upstream-resolvers.sh", nil]];
    _statusConfigurationMenuItem.title = stateDescription;
    _statusResolversMenuItem.title = currentResolvers;
    
    return TRUE;
}

- (void) periodicallyUpdateStatusWithCurrentConfig {
    [self updateStatusWithCurrentConfig];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [self performSelector: @selector(periodicallyUpdateStatusWithCurrentConfig) withObject:nil afterDelay: 5.0];
}

- (void) awakeFromNib
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];    
    _statusItem.highlightMode = TRUE;
    _statusItem.toolTip = @"DNSCrypt";
    _statusItem.menu = _dnscryptMenu;
        
    NSString *versionStringFormat = NSLocalizedString(@"Client version: %@", @"Current version in the menu");
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionMenuItem.title = [NSString stringWithFormat: versionStringFormat, version];
    
    [self initState];
    
    [self periodicallyUpdateStatusWithCurrentConfig];
    [self updateLedStatus];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[SUUpdater sharedUpdater] setSendsSystemProfile: TRUE];
}

- (IBAction)preferencesMenuItemPushed:(NSMenuItem *)sender
{
    NSString *userPreferencePanePath = [NSString stringWithFormat: @"%@" kDNSCRYPT_PREFPANE_APP_PATH, NSHomeDirectory()];
    NSArray *preferencePanePaths = [NSArray arrayWithObjects: userPreferencePanePath, kDNSCRYPT_PREFPANE_APP_PATH, nil];
    for (NSString *preferencePanePath in preferencePanePaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath: preferencePanePath]) {
            [[NSWorkspace sharedWorkspace] openFile: preferencePanePath];
            return;
        }
    }
}

- (BOOL) setDNSCryptOn {
    [self updateLedStatusWaiting];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-to-dnscrypt.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (BOOL) setDNSCryptOff {
    [self updateLedStatusWaiting];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./switch-to-dhcp.sh", nil]];
    NSLog(@"%@", res);
    return TRUE;
}

- (IBAction)dnscryptMenuItemPushed:(NSMenuItem *)sender
{
    if (sender.state == 0) {
        sender.state = 1;
        [self setDNSCryptOn];
    } else {
        sender.state = 0;
        [self setDNSCryptOff];
    }
}

- (IBAction)familyShieldMenuItemPushed:(NSMenuItem *)sender
{

}

- (IBAction)fallbackMenuItemPushed:(NSMenuItem *)sender
{

}

@end
