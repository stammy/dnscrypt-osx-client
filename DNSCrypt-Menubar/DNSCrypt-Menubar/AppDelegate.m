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
@synthesize window = _window;
@synthesize dnscryptMenu = _dnscryptMenu;
@synthesize statusItem = _statusItem;
@synthesize versionMenuItem = _versionMenuItem;

DNSConfigurationState currentState = kDNS_CONFIGURATION_UNKNOWN;

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
    NSArray *resolversForLocalhost = [NSArray arrayWithObjects: kRESOLVER_IP_LOCALHOST, nil];
    NSArray *resolversForOpenDNS = [NSArray arrayWithObjects: kRESOLVER_IP_OPENDNS1, kRESOLVER_IP_OPENDNS2, nil];
    
    NSError *err;
    NSString *resolvConf = [NSString stringWithContentsOfFile: @"/etc/resolv.conf" encoding: NSISOLatin1StringEncoding error: &err];
    NSString *currentStateString = @"";
    NSMutableString *resolversString = [[NSMutableString alloc] init];
    if (! resolvConf) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
        currentStateString = NSLocalizedString(@"Network unavailable", @"Current state");
        [resolversString appendString: NSLocalizedString(@"None", @"No current state")];
    } else {
        NSMutableArray *resolvers = [[NSMutableArray alloc] init];
        NSArray *lines = [resolvConf componentsSeparatedByString: @"\n"];
        for (NSString *line_ in lines) {            
            NSString *line = [line_ stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *entry = [line componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            if (![[entry objectAtIndex: 0U] isEqualToString: @"nameserver"]) {
                continue;
            }
            NSString *resolver = [entry objectAtIndex: 1U];
            [resolvers addObject: resolver];
            [resolversString appendFormat: @"%s%@", (resolversString.length > 0 ? ", " : ""), resolver];            
        }
        if ([self resolversForService: resolvers includeResolvers: resolversForLocalhost]) {
            currentState = kDNS_CONFIGURATION_LOCALHOST;
            currentStateString = NSLocalizedString(@"DNSCrypt", @"Current state");
        } else if ([self resolversForService: resolvers includeResolvers: resolversForOpenDNS]) {
            currentStateString = NSLocalizedString(@"OpenDNS", @"Current state");        
            currentState = kDNS_CONFIGURATION_OPENDNS;
        } else {
            currentStateString = NSLocalizedString(@"Default", @"Current state");
            currentState = kDNS_CONFIGURATION_VANILLA;
        }
        if ([resolversString isEqualToString: kRESOLVER_IP_LOCALHOST]) {
            resolversString = [NSString stringWithFormat: NSLocalizedString(@"%@\nusing DNSCrypt", @"Current resolver when DNSCrypt has been enabled"), kDNSCRYPT_RESOLVER];
        }
    }
    [self updateLedStatus];
    _statusConfigurationMenuItem.title = currentStateString;
    _statusResolversMenuItem.title = resolversString;
    
    return TRUE;
}

- (void) periodicallyUpdateStatusWithCurrentConfig {
    [self updateStatusWithCurrentConfig];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [self performSelector: @selector(periodicallyUpdateStatusWithCurrentConfig) withObject:nil afterDelay: 2.5];
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

@end
