//
//  DNSCrypt.m
//  DNSCrypt
//
//  Created by OpenDNS, Inc. on 8/11/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import "DNSCrypt.h"

@implementation DNSCrypt
@synthesize tabView = _tabView;
@synthesize aboutTabViewItem = _aboutTabViewItem;
@synthesize releaseNotesTabViewItem = _releaseNotesTabViewItem;
@synthesize previewNotesWebView = _previewNotesWebView;
@synthesize releaseNotesWebView = _releaseNotesWebView;
@synthesize feedbackWebView = _feedbackWebView;
@synthesize aboutWebView = _aboutWebView;
@synthesize staticResolversTextField = _staticResolversTextField;
@synthesize parentalControlsButton = _parentalControlsButton;
@synthesize queryLoggingButton = _queryLoggingButton;
@synthesize dnscryptButton = _dnscryptButton;
@synthesize opendnsButton = _opendnsButton;
@synthesize fallbackButton = _fallbackButton;
@synthesize familyShieldButton = _familyShieldButton;
@synthesize statusImageView = _statusImageView;
@synthesize statusText = _statusText;
@synthesize currentResolverTextField = _currentResolverTextField;

DNSConfigurationState currentState = kDNS_CONFIGURATION_UNKNOWN;

- (void) setCheckBoxesEnabled: (BOOL) enabled
{
    [_dnscryptButton setEnabled: enabled];
    [_opendnsButton setEnabled: enabled];
    [_familyShieldButton setEnabled: enabled];
    [_fallbackButton setEnabled: enabled];
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
    [task release];
    [pipe release];
    result = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    if ([result hasSuffix: @"\n"]) {
        result = [result substringToIndex: result.length - 1];
    }
    return result;
}

- (void) initState
{
    NSString *res;

    _dnscryptButton.state = 0;
    _familyShieldButton.state = 0;
    _opendnsButton.state = 0;
    _fallbackButton.state = 0;
    
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-dnscrypt-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_dnscryptButton setState: 1];
    }
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-familyshield-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_familyShieldButton setState: 1];
    }
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-insecure-opendns-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_opendnsButton setState: 1];
    }
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-fallback-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_fallbackButton setState: 1];
    }
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-static-resolvers.sh", nil]];
    [_staticResolversTextField setStringValue: res];
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-parental-controls-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_parentalControlsButton setState: 1];
    }
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-query-logging-status.sh", nil]];
    if ([res isEqualToString: @"yes"]) {
        [_queryLoggingButton setState: 1];
    }
}

- (void) updateLedStatus
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier: @"com.opendns.osx.DNSCrypt"];
    switch (currentState) {
        case kDNS_CONFIGURATION_UNKNOWN:
            _statusText.stringValue = NSLocalizedString(@"No network", @"Status");
            _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_red.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_VANILLA:
            _statusText.stringValue = NSLocalizedString(@"Unprotected", @"Status");
            _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_red.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_OPENDNS:
            _statusText.stringValue = NSLocalizedString(@"Unencrypted", @"Status");
            _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_yellow.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_LOCALHOST:
            _statusText.stringValue = NSLocalizedString(@"Protected", @"Status");
            _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_green.png"]] autorelease];
            break;
        default:
            return;
    }
}

- (BOOL) updateStatusWithCurrentConfig
{
    NSString *stateDescription = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-resolvers-description.sh", nil]];
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
    } else if (stateDescription.length > 0) {
        currentState = kDNS_CONFIGURATION_VANILLA;
    }
    [self updateLedStatus];
    
    NSString *currentResolvers = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./get-current-resolvers.sh | ./get-upstream-resolvers.sh", nil]];
    _currentResolverTextField.stringValue = currentResolvers;
    
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./gui-pop-conf-change.sh prefpane", nil]];
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
    _statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"ajax-loader.gif"]] autorelease];
    _currentResolverTextField.stringValue = @"";
    
    [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./gui-push-conf-change.sh menubar", nil]];
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(waitForUpdate) object: nil];
    [self performSelector: @selector(waitForUpdate) withObject: self afterDelay:kREFRESH_DELAY];
}

- (BOOL) setDNSCryptOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-to-dnscrypt.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setDNSCryptOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-to-dhcp.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setFamilyShieldOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-familyshield-on.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setFamilyShieldOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-familyshield-off.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setInsecureOpenDNSOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-insecure-opendns-on.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setInsecureOpenDNSOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-insecure-opendns-off.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setFallbackOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-fallback-on.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setFallbackOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-fallback-off.sh", nil]];
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

- (IBAction)opendnsButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setInsecureOpenDNSOn];
    } else {
        [self setInsecureOpenDNSOff];
    }
}

- (IBAction)familyShieldButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setFamilyShieldOn];
    } else {
        [self setFamilyShieldOff];
    }
}

- (IBAction)fallbackButtonPressed:(NSButton *)sender
{
    if (sender.state != 0) {
        [self setFallbackOn];
    } else {
        [self setFallbackOff];
    }
}

- (void) waitForUpdate {
    NSString *res;
    static unsigned int tries;
    
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./get-tickets-count.sh", nil]];
    if (res.length <= 0 || [res isEqualToString: @"0"] || tries > kMAX_TRIES_AFTER_CHANGE) {
        tries = 0U;
        [self periodicallyUpdateStatusWithCurrentConfig];
        return;
    }
    tries++;
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(waitForUpdate) object: nil];
    [self performSelector: @selector(waitForUpdate) withObject: self afterDelay:kREFRESH_DELAY];
}

- (void) webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    if (sender != _feedbackWebView) {
        return;
    }
    NSString *res;
    res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"/usr/local/sbin/dnscrypt-proxy --version | head -n 1", nil]];
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString: @"\r\n<>'"];
    res = [[res componentsSeparatedByCharactersInSet: charset] componentsJoinedByString: @" "];
    NSString *script = [NSString stringWithFormat: @"document.querySelector('textarea[name=feedback]').value='\\n\\n\\n--\\nOpenDNS user interface for OSX " kDNSCRYPT_PACKAGE_VERSION "\\n%@'", res];;
    [sender stringByEvaluatingJavaScriptFromString: script];
}

- (void) mainViewDidLoad
{
    currentState = kDNS_CONFIGURATION_UNKNOWN;
    [_previewNotesWebView setDrawsBackground:false];
    
    [self initState];
    [self periodicallyUpdateStatusWithCurrentConfig];

    NSString *version = kDNSCRYPT_PACKAGE_VERSION;
    NSString *softwareBlurbFormat = NSLocalizedString(@"This software (v: %@) encrypts and authenticates DNS packets between your computer and OpenDNS. This prevents man-in-the-middle attacks and snooping of DNS traffic by ISPs or others.", @"Description of what the package does - %@ is replaced by the version number");
    NSString *provideFeedback = NSLocalizedString(@"Please help by providing feedback!", @"Ask for feedback");
    NSString *describePorts = NSLocalizedString(@"DNSCrypt can use UDP and TCP ports 53 and 443.", @"Describe what ports DNSCrypt uses");
    NSString *describeFallback = NSLocalizedString(@"If you prefer reliability over security, enable fallback to insecure DNS.", @"Describe what the 'fallback to insecure mode' checkbox does");

    NSMutableString *htmlString = [NSMutableString stringWithString: @"<html><body style=\"font-family:Helvetica, sans-serif; font-size: 11px; color: #333; margin: 0px; padding: 2px 0px;\">"];

    [htmlString appendFormat: softwareBlurbFormat, version];
    [htmlString appendString: @"<br/><br/>"];
    [htmlString appendString: @"<strong>"];
    [htmlString appendString: provideFeedback];
    [htmlString appendString: @"</strong>"];
    [htmlString appendString: @"<ul style=\"list-style-position: inside; list-style-type: square; padding-left: 0px; margin-top: 0; margin-bottom: 0; \">"];
    [htmlString appendFormat: @"<li>%@</li>", describePorts];
    [htmlString appendFormat: @"<li>%@</li>", describeFallback];
    [htmlString appendString: @"</ul>"];
    [htmlString appendString: @"</body></html>"];
    [[_previewNotesWebView mainFrame] loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"file:///"]];

    [_feedbackWebView setDrawsBackground:false];
    [_feedbackWebView setShouldUpdateWhileOffscreen:true];
    [_feedbackWebView setUIDelegate:self];
    [_feedbackWebView setFrameLoadDelegate: self];
    NSString *feedbackURLText = @"http://dnscrypt.opendns.com/feedback.php";
    [[_feedbackWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:feedbackURLText]]];

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
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    return nil;
}

- (IBAction)openDNSLinkPushed:(NSButton *)sender
{
    (void) sender;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: kOPENDNS_URL]];
}

- (IBAction)uninstallPushed:(NSButton *)sender {
    [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_BIN_BASE_DIR @"' && /usr/bin/open ./Uninstall.app", nil]];
}

- (IBAction)staticResolversTextFieldChanged:(NSTextField *)sender {
    NSString *staticResolvers = sender.stringValue;
    NSCharacterSet *charset = [[NSCharacterSet characterSetWithCharactersInString: @"0123456789abcdefABCDEF:. "] invertedSet];
    staticResolvers = [[staticResolvers componentsSeparatedByCharactersInSet: charset] componentsJoinedByString: @" "];
    sender.stringValue = staticResolvers;
    setenv("STATIC_RESOLVERS", [staticResolvers UTF8String], 1);
    [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && exec ./set-static-resolvers.sh \"$STATIC_RESOLVERS\"", staticResolvers, nil]];
}

- (BOOL) setParentalControlsOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-parental-controls-on.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setParentalControlsOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-parental-controls-off.sh", nil]];
    (void) res;
    return TRUE;
}

- (IBAction)parentalControlsButtonPressed:(NSButtonCell *)sender {
    if (sender.state != 0) {
        [self setParentalControlsOn];
    } else {
        [self setParentalControlsOff];
    }
}

- (BOOL) setQueryLoggingOn {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-query-logging-on.sh", nil]];
    (void) res;
    return TRUE;
}

- (BOOL) setQueryLoggingOff {
    [self showSpinners];
    NSString *res = [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"cd '" kDNSCRIPT_SCRIPTS_BASE_DIR @"' && ./create-ticket.sh && ./switch-query-logging-off.sh", nil]];
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
    [self fromCommand: @"/bin/ksh" withArguments: [NSArray arrayWithObjects: @"-c", @"open /Applications/Utilities/Console.app " kDNSCRYPT_QUERY_LOG_FILE " || open " kDNSCRYPT_QUERY_LOG_FILE, nil]];
}

@end
