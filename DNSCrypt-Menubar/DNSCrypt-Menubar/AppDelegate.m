
#import "AppDelegate.h"

@implementation AppDelegate
@synthesize statusResolversMenuItem = _statusResolversMenuItem;
@synthesize dnscryptMenuItem = _dnscryptMenuItem;
@synthesize window = _window;
@synthesize dnscryptMenu = _dnscryptMenu;
@synthesize statusItem = _statusItem;
@synthesize versionMenuItem = _versionMenuItem;

DNSConfigurationState currentState = kDNS_CONFIGURATION_UNKNOWN;
BOOL appUpdated = FALSE;

- (void) setCheckBoxesEnabled: (BOOL) enabled
{
    [_dnscryptMenuItem setEnabled: enabled];
}

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
    NSString *res;

    _dnscryptMenuItem.state = 0;

    res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-dnscrypt-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_dnscryptMenuItem setState: 1];
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

- (void) updateLedStatus
{
    NSImage *led = nil;
    
    switch (currentState) {
        case kDNS_CONFIGURATION_LOCALHOST:
            led = [NSImage imageNamed: @"Active"];
            break;
        case kDNS_CONFIGURATION_VANILLA:
            led = [NSImage imageNamed: @"Inactive"];
            break;
        default:
            led = [NSImage imageNamed: @"No-Network"];
    }
    [led setTemplate:YES];
    _statusItem.image = led;
}

- (BOOL) updateStatusWithCurrentConfig
{
    NSString *stateDescription = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-resolvers-description.sh", nil]];
    if ([stateDescription isEqualToString: @"DNSCrypt"]) {
        currentState = kDNS_CONFIGURATION_LOCALHOST;
        if (appUpdated == FALSE) {
            appUpdated = TRUE;
            [self appUpdate];
        }
    } else if ([stateDescription isEqualToString: @"None"]) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
    } else if ([stateDescription isEqualToString: @"Updating"]) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
    } else if (stateDescription.length > 0) {
        currentState = kDNS_CONFIGURATION_VANILLA;
    }
    [self updateLedStatus];
    
    NSString *hideMenuBar = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-hide-menubar-icon-status.sh | ./get-upstream-resolvers.sh", nil]];

    if ([hideMenuBar isEqualToString: @"yes"]) {
        _statusItem.visible = FALSE;
    } else if ([hideMenuBar isEqualToString: @"no"]) {
        _statusItem.visible = TRUE;
    }

    NSString *currentResolvers = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-upstream-resolvers.sh", nil]];
    _statusResolversMenuItem.title = currentResolvers;
    
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./gui-pop-conf-change.sh menubar", nil]];
    if ([res isEqualToString: @"yes"]) {
        [self initState];
    }
    [self setCheckBoxesEnabled: TRUE];
    
    return TRUE;
}

- (void) periodicallyUpdateStatusWithCurrentConfig {
    [self updateStatusWithCurrentConfig];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [self performSelector: @selector(periodicallyUpdateStatusWithCurrentConfig) withObject:nil afterDelay: 5.0];
}

- (void) waitForUpdate {
    NSString *res;
    static unsigned int tries;
    
    res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-tickets-count.sh", nil]];
    if (res.length <= 0 || [res isEqualToString: @"0"] || tries > kMAX_TRIES_AFTER_CHANGE) {
        tries = 0U;
        [self periodicallyUpdateStatusWithCurrentConfig];
        return;
    }
    tries++;
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(waitForUpdate) object: nil];
    [self performSelector: @selector(waitForUpdate) withObject: self afterDelay:kREFRESH_DELAY];
}

- (void) showSpinners
{
    [self setCheckBoxesEnabled: FALSE];

    NSImage *led = [NSImage imageNamed: @"No-Network"];
    _statusItem.image = led;
    
    [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./gui-push-conf-change.sh prefpane", nil]];
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(waitForUpdate) object: nil];
    [self performSelector: @selector(waitForUpdate) withObject: self afterDelay:kREFRESH_DELAY];
}

- (void) awakeFromNib
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.highlightMode = TRUE;
    _statusItem.toolTip = @"DNSCrypt";
    _statusItem.menu = _dnscryptMenu;
        
    NSString *versionStringFormat = NSLocalizedString(@"Client UI version: %@", @"Current UI version as shown in the menu");
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionMenuItem.title = [NSString stringWithFormat: versionStringFormat, version];
    
    [self initState];
    
    [self periodicallyUpdateStatusWithCurrentConfig];
    [self updateLedStatus];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
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
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-to-dnscrypt.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setDNSCryptOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-to-dhcp.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) appUpdate {
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./update-dnscrypt-app.sh", nil]];
    (void) res;
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

- (BOOL) setHideMenubarIconOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-hide-menubar-icon-on.sh", nil]];
    (void) res;
    _statusItem.visible = FALSE;
    return TRUE;
}

- (IBAction)hideMenubarIconMenuItemPushed:(NSMenuItem *)sender
{
    [self setHideMenubarIconOn];
}

@end
