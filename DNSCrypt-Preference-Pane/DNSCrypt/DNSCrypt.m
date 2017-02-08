
#import "DNSCrypt.h"

@implementation DNSCrypt
@synthesize tabView = _tabView;
@synthesize aboutTabViewItem = _aboutTabViewItem;
@synthesize releaseNotesTabViewItem = _releaseNotesTabViewItem;
@synthesize releaseNotesWebView = _releaseNotesWebView;
@synthesize aboutWebView = _aboutWebView;
@synthesize staticResolversTextField = _staticResolversTextField;
@synthesize blacklistIPsTextField = _blacklistIPsTextField;
@synthesize blacklistDomainsTextField = _blacklistDomainsTextField;
@synthesize helpWebView = _helpWebView;
@synthesize viewLogButton = _viewLogButton;
@synthesize queryLoggingButton = _queryLoggingButton;
@synthesize exceptionsTextField = _exceptionsTextField;
@synthesize dnscryptButton = _dnscryptButton;
@synthesize disableIPv6Button = _disableIPv6Button;
@synthesize statusImageView = _statusImageView;
@synthesize statusText = _statusText;
@synthesize currentResolverTextField = _currentResolverTextField;
@synthesize resolverNamesButton = _resolverNamesButton;

DNSConfigurationState currentState = kDNS_CONFIGURATION_UNKNOWN;
NSArray *resolversList;

- (void) setCheckBoxesEnabled: (BOOL) enabled
{
    [_dnscryptButton setEnabled: enabled];
    [_disableIPv6Button setEnabled: enabled];
    [_resolverNamesButton setEnabled: enabled];
}

- (NSString *) fromCommand: (NSString *) launchPath withArguments: (NSArray *) arguments
{
    NSPipe *pipe = [[NSPipe alloc] init];
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

    _dnscryptButton.state = 0;
    _disableIPv6Button.state = 0;
    
    res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./get-dnscrypt-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_dnscryptButton setState: 1];
    }
    res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./get-aaaa-blocking-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_disableIPv6Button setState: 1];
    }
    res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./get-static-resolvers.sh", nil]];
    [_staticResolversTextField setStringValue: res];
    res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./get-query-logging-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_queryLoggingButton setState: 1];
    }
    NSString *fileContent;
    fileContent = [NSString stringWithContentsOfFile: kDNSCRYPT_BLACKLIST_IPS_TMP_FILE encoding:NSUTF8StringEncoding error: nil];
    if (fileContent != nil) {
        [_blacklistIPsTextField setStringValue: fileContent];
    }
    fileContent = [NSString stringWithContentsOfFile: kDNSCRYPT_BLACKLIST_DOMAINS_TMP_FILE encoding:NSUTF8StringEncoding error: nil];
    if (fileContent != nil) {
        [_blacklistDomainsTextField setStringValue: fileContent];
    }
    fileContent = [NSString stringWithContentsOfFile: kDNSCRYPT_EXCEPTIONS_TMP_FILE encoding:NSUTF8StringEncoding error: nil];
    if (fileContent != nil) {
        [_exceptionsTextField setStringValue: fileContent];
    }
    
    [_resolverNamesButton removeAllItems];
    
    resolversList = [NSArray arrayWithContentsOfCSVFile: kRESOLVERS_LIST_FILE options:CHCSVParserOptionsSanitizesFields | CHCSVParserOptionsStripsLeadingAndTrailingWhitespace];
    NSUInteger rows_count = [resolversList count];
    NSUInteger i;
    [_resolverNamesButton addItemWithTitle: NSLocalizedString(@"Please select a resolver", @"A resolver hasn't been selected yet")];
    res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./get-dnscrypt-resolver-name.sh", nil]];
    for (i = 1U; i < rows_count; i++) {
        NSArray *row = [resolversList objectAtIndex: i];
        NSString *name;
        if (row.count < 4) {
            continue;
        }
        name = [row objectAtIndex: 1];
        [_resolverNamesButton addItemWithTitle: name];
        if ([[row objectAtIndex: 0] isEqualToString: res]) {
            [_resolverNamesButton selectItemAtIndex: i];
            [self updateResolverInfo: row];
        }
    }
}

- (void) updateLedStatus
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier: @"com.github.dnscrypt-osxclient.DNSCrypt"];
    switch (currentState) {
        case kDNS_CONFIGURATION_UNKNOWN:
            _statusText.stringValue = NSLocalizedString(@"Standby", @"Status");
            _statusImageView.image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_red.png"]];
            break;
        case kDNS_CONFIGURATION_VANILLA:
            _statusText.stringValue = NSLocalizedString(@"Not using DNSCrypt", @"Status");
            _statusImageView.image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_red.png"]];
            break;
        case kDNS_CONFIGURATION_LOCALHOST:
            _statusText.stringValue = NSLocalizedString(@"Using DNSCrypt", @"Status");
            _statusImageView.image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_green.png"]];
            break;
        default:
            return;
    }
}

- (BOOL) updateStatusWithCurrentConfig
{
    NSString *stateDescription = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-resolvers-description.sh", nil]];
    if ([stateDescription isEqualToString: @"DNSCrypt"]) {
        currentState = kDNS_CONFIGURATION_LOCALHOST;
    } else if ([stateDescription isEqualToString: @"None"]) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
    } else if ([stateDescription isEqualToString: @"Updating"]) {
        currentState = kDNS_CONFIGURATION_UNKNOWN;
    } else if (stateDescription.length > 0) {
        currentState = kDNS_CONFIGURATION_VANILLA;
    }
    [self updateLedStatus];
    
    NSString *currentResolvers = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-upstream-resolvers.sh", nil]];
    _currentResolverTextField.stringValue = currentResolvers;
    
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./gui-pop-conf-change.sh prefpane", nil]];
    if ([res isEqualToString: @"yes"]) {
        [self initState];
    }
    [self setCheckBoxesEnabled: TRUE];
    
    return TRUE;
}

- (void) periodicallyUpdateStatusWithCurrentConfig {
    [self updateStatusWithCurrentConfig];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [self performSelector: @selector(periodicallyUpdateStatusWithCurrentConfig) withObject:nil afterDelay: kREFRESH_DELAY];
}

- (void) showSpinners {
    NSBundle *bundle = [NSBundle bundleWithIdentifier: kBUNDLE_IDENTIFIER];
    
    [self setCheckBoxesEnabled: FALSE];
    _statusText.stringValue = NSLocalizedString(@"Updating", @"Updating network configuraiton");
    _statusImageView.image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"ajax-loader.gif"]];
    _currentResolverTextField.stringValue = @"";
    
    [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./gui-push-conf-change.sh menubar", nil]];
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(waitForUpdate) object: nil];
    [self performSelector: @selector(waitForUpdate) withObject: self afterDelay:kREFRESH_DELAY];
}

- (BOOL) setDNSCryptOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-to-dnscrypt.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setDNSCryptOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-to-dhcp.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setDisableIPv6On {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-aaaa-blocking-on.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setDisableIPv6Off {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-aaaa-blocking-off.sh", nil]];
    (void) res;
    return TRUE;
}

- (IBAction)dnscryptButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setDNSCryptOn];
    } else {
        [self setDNSCryptOff];
    }
}

- (IBAction)disableIPv6ButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setDisableIPv6On];
    } else {
        [self setDisableIPv6Off];
    }
}

- (void) waitForUpdate {
    NSString *res;
    static unsigned int tries;
    
    res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./get-tickets-count.sh", nil]];
    if (res.length <= 0 || [res isEqualToString: @"0"] || tries > kMAX_TRIES_AFTER_CHANGE) {
        tries = 0U;
        [self periodicallyUpdateStatusWithCurrentConfig];
        return;
    }
    tries++;
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(waitForUpdate) object: nil];
    [self performSelector: @selector(waitForUpdate) withObject: self afterDelay:kREFRESH_DELAY];
}

- (void) updateResolverInfo: (NSArray *) row {
    NSString *location = [row objectAtIndex: 3];
    _locationText.stringValue = location;
    NSString *url = [row objectAtIndex: 5];
    if (![url isEqualToString: @""]) {
        _providerLink.title = url;
        _providerLink.hidden = false;
    } else {
        _providerLink.hidden = true;
    }
    NSString *description = [row objectAtIndex: 2];
    _descriptionText.stringValue = description;
}

- (IBAction)resolversNamesPopupButtonPressed:(NSPopUpButton *)sender {
    NSUInteger i = [sender indexOfSelectedItem];
    if (i <= 0U || i >= resolversList.count) {
        return;
    }
    NSArray *row = [resolversList objectAtIndex: i];
    [self updateResolverInfo: row];
    setenv("RESOLVER_NAME", [[row objectAtIndex: 0] UTF8String], 1);
    [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./set-dnscrypt-resolver-name.sh \"$RESOLVER_NAME\"", nil]];
}

- (void) mainViewDidLoad
{
    currentState = kDNS_CONFIGURATION_UNKNOWN;
    
    [self initState];
    [self periodicallyUpdateStatusWithCurrentConfig];

    SInt32 OSXversionMajor, OSXversionMinor;
    if (Gestalt(gestaltSystemVersionMajor, &OSXversionMajor) != noErr || Gestalt(gestaltSystemVersionMinor, &OSXversionMinor) != noErr || OSXversionMajor < 10 || OSXversionMinor < 6) {
        return;
    }
    [_releaseNotesWebView setDrawsBackground:false];
    [_releaseNotesWebView setShouldUpdateWhileOffscreen:true];
    [_releaseNotesWebView setUIDelegate:self];
    
    NSURL *releaseNotesURL;
    NSString *releaseNotesURLPath = [[NSBundle bundleForClass: [self class]] pathForResource: @"releasenotes" ofType: @"html" inDirectory: @"html"];
    if (! releaseNotesURLPath || ! (releaseNotesURL = [NSURL fileURLWithPath:  releaseNotesURLPath])) {
        [_tabView removeTabViewItem:_releaseNotesTabViewItem];
    } else {
        [[_releaseNotesWebView mainFrame] loadRequest:[NSURLRequest requestWithURL: releaseNotesURL]];
    }

    [_aboutWebView setDrawsBackground:false];
    [_aboutWebView setShouldUpdateWhileOffscreen:true];
    [_aboutWebView setUIDelegate:self];
    NSURL *aboutURL;
    NSString *aboutURLPath = [[NSBundle bundleForClass: [self class]] pathForResource: @"about" ofType: @"html" inDirectory: @"html"];
    if (! aboutURLPath || ! (aboutURL = [NSURL fileURLWithPath: aboutURLPath])) {
        [_tabView removeTabViewItem: _aboutTabViewItem];
    } else {
        [[_aboutWebView mainFrame] loadRequest:[NSURLRequest requestWithURL: aboutURL]];
    }
    
    [_helpWebView setDrawsBackground:false];
    [_helpWebView setShouldUpdateWhileOffscreen:false];
    [_helpWebView setUIDelegate:self];
    NSURL *helpURL;
    NSString *helpURLPath = [[NSBundle bundleForClass: [self class]] pathForResource: @"help" ofType: @"html" inDirectory: @"html"];
    if (! helpURLPath || ! (helpURL = [NSURL fileURLWithPath: helpURLPath])) {
        assert(0);
    } else {
        [[_helpWebView mainFrame] loadRequest:[NSURLRequest requestWithURL: helpURL]];
    }
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    return nil;
}

- (IBAction)providerLinkPushed:(NSButton *)sender
{
    (void) sender;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: sender.title]];
}

- (IBAction)uninstallPushed:(NSButton *)sender {
    [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_BIN_BASE_DIR @"' && /usr/bin/open ./Uninstall.app", nil]];
}

- (IBAction)staticResolversTextFieldChanged:(NSTextField *)sender {
    NSString *staticResolvers = sender.stringValue;
    NSCharacterSet *charset = [[NSCharacterSet characterSetWithCharactersInString: @"0123456789abcdefABCDEF:. "] invertedSet];
    staticResolvers = [[staticResolvers componentsSeparatedByCharactersInSet: charset] componentsJoinedByString: @" "];
    sender.stringValue = staticResolvers;
    setenv("STATIC_RESOLVERS", [staticResolvers UTF8String], 1);
    [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && exec ./set-static-resolvers.sh \"$STATIC_RESOLVERS\"", nil]];
}

- (BOOL) setQueryLoggingOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-query-logging-on.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setQueryLoggingOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-query-logging-off.sh", nil]];
    (void) res;
    return TRUE;
}

- (IBAction)queryLoggingButtonPressed:(NSButtonCell *)sender {
    if (sender.state != 0) {
        [self setQueryLoggingOn];
    } else {
        [self setQueryLoggingOff];
    }
}

- (IBAction)viewLogButtonPushed:(NSButton *)sender {
    [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"open /Applications/Utilities/Console.app " kDNSCRYPT_QUERY_LOG_FILE " || open " kDNSCRYPT_QUERY_LOG_FILE, nil]];
}

- (BOOL) updateBlacklistIPs {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./update-blacklist-ips.sh", nil]];
    (void) res;
    return TRUE;
}

- (IBAction)blacklistIPsUpdated:(NSTextField *)sender {
    NSString *content = sender.stringValue;
    if ([content writeToFile: kDNSCRYPT_BLACKLIST_IPS_TMP_FILE atomically: YES encoding: NSUTF8StringEncoding error: nil] != YES) {
        return;
    }
    [self updateBlacklistIPs];
}

- (BOOL) updateBlacklistDomains {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./update-blacklist-domains.sh", nil]];
    (void) res;
    return TRUE;
}

- (IBAction)blacklistDomainsUpdated:(NSTextField *)sender {
    NSString *content = sender.stringValue;
    if ([content writeToFile: kDNSCRYPT_BLACKLIST_DOMAINS_TMP_FILE atomically: YES encoding: NSUTF8StringEncoding error: nil] != YES) {
        return;
    }
    [self updateBlacklistDomains];
}

- (BOOL) updateExceptions {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/csh" withArguments: [NSArray arrayWithObjects: @"-f", @"-c", @"cd '" kDNSCRYPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./update-exceptions.sh", nil]];
    (void) res;
    return TRUE;
}

- (IBAction)exceptionsUpdated:(NSTextField *)sender {
    NSString *content = sender.stringValue;
    if ([content writeToFile: kDNSCRYPT_EXCEPTIONS_TMP_FILE atomically: YES encoding: NSUTF8StringEncoding error: nil] != YES) {
        return;
    }
    [self updateExceptions];
}

- (IBAction)helpButtonPressed:(NSButton *)sender {
    if (_helpWebView.isHidden) {
        [_helpWebView.window makeFirstResponder: nil];
        [_helpWebView setHidden: NO];
        [_helpWebView setAlphaValue: 0.0F];
        [_helpWebView.animator setAlphaValue: 1.0F];
        [_helpWebView setDrawsBackground: TRUE];
        [_viewLogButton setHidden: YES];
        [_queryLoggingButton setHidden: YES];
    } else {
        [_helpWebView.window makeFirstResponder: nil];
        [_helpWebView setHidden: YES];
        [_queryLoggingButton setHidden: NO];
    }
}

@end
