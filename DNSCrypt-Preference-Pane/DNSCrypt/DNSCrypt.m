//
//  DNSCrypt.m
//  DNSCrypt
//
//  Created by OpenDNS, Inc. on 8/11/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#include <sys/un.h>
#include <netinet/in.h>
#import "DNSCrypt.h"

@implementation DNSCrypt
@synthesize previewNotesWebView;
@synthesize releaseNotesWebView;
@synthesize feedbackWebView;
@synthesize aboutWebView;

@synthesize enableOpenDNSButton;
@synthesize enableDNSCryptButton;
@synthesize enableInsecureDNSButton;
@synthesize statusImageView;
@synthesize statusText;
@synthesize useHTTPSButton;
@synthesize currentResolverTextField;

DNSConfigurationState state;
BOOL useHTTPSPort = NO;
BOOL enableInsecure = NO;
BOOL checkBoxesHaveBeenInitialized = NO;

- (BOOL) ensureConfigUpdaterIsRunning
{
    NSArray *arguments = [NSArray arrayWithObjects: @"start", KDNSCRYPT_CONFIG_UPDATER_LABEL, nil];
    NSTask *task = [[[NSTask alloc] init] autorelease];
    task.launchPath = KLAUNCHCTL_PATH;
    task.arguments = arguments;
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    [task launch];
    [task waitUntilExit];

    return FALSE;
}

- (BOOL) sendCommandToConfigUpdater: (NSString *) command storeResultTo: (__autoreleasing NSData **) dataP withMaxSize: (NSUInteger) maxSize
{
    const char *sockPath = [kSOCK_PATH cStringUsingEncoding: NSUTF8StringEncoding];
    size_t sockPathSize = strlen(sockPath) + (size_t) 1U;
    struct sockaddr_un *su;
    assert(sockPathSize < sizeof su->sun_path);
    socklen_t sun_len = (socklen_t) (sizeof *su) + (socklen_t) sockPathSize;
    su = calloc(1U, sun_len);
    su->sun_family = AF_UNIX;
    memcpy(su->sun_path, sockPath, sockPathSize);
    su->sun_len = SUN_LEN(su);
    CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, PF_UNIX, SOCK_DGRAM, IPPROTO_IP, 0, NULL, NULL);
    CFSocketSetSocketFlags(socket, CFSocketGetSocketFlags(socket) & ~kCFSocketCloseOnInvalidate);
    int fd = CFSocketGetNative(socket);
    NSData *address = [NSData dataWithBytes: su length: SUN_LEN(su)];
    CFSocketError err = CFSocketConnectToAddress(socket, (__bridge CFDataRef) address, 30.0);
    free(su);
    if (err != kCFSocketSuccess) {
        CFRelease(socket);
        return FALSE;
    }
    NSFileHandle *fh = [[[NSFileHandle alloc] initWithFileDescriptor: fd closeOnDealloc: TRUE] autorelease];
    CFRelease(socket);
    NSData *data = [command dataUsingEncoding: NSUTF8StringEncoding];
    NSAssert(data.length <= UINT32_MAX, @"data.length > UINT32_MAX");
    uint32_t dataLen = (uint32_t) data.length;
    [fh writeData: [NSData dataWithBytes: &dataLen length: sizeof dataLen]];
    [fh writeData: data];
    if (dataP && maxSize) {
        *dataP = [fh readDataOfLength: maxSize];
    }
    [fh closeFile];

    return TRUE;
}

- (BOOL) sendCommandToConfigUpdater: (NSString *) command
{
    return [self sendCommandToConfigUpdater: command storeResultTo: nil withMaxSize: 0U];
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

- (NSString *) getSupportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = nil;
    NSError *error = nil;
    BOOL isDirectory;

    for (path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath: path isDirectory: &isDirectory] == FALSE || isDirectory == FALSE) {
            continue;
        }
        path = [path stringByAppendingPathComponent: kDNSCRYPT_PREFPANE_SUPPORT_DIR];
        if ([[NSFileManager defaultManager] createDirectoryAtPath: path withIntermediateDirectories: TRUE attributes: nil error: &error] == TRUE) {
            return path;
        }
    }
    NSLog(@"Error: [%@]", error);
    return nil;
}

- (NSString *) getPrefPaneConfigFile
{
    NSString *supportDirectory = [self getSupportDirectory];
    if (! supportDirectory) {
        return nil;
    }
    return [supportDirectory stringByAppendingPathComponent: kDNSCRYPT_PREFPANE_FILE];
}

- (BOOL) savePrefPaneConfig
{
    NSString *prefPaneConfigFile = [self getPrefPaneConfigFile];
    if (prefPaneConfigFile == nil) {
        return FALSE;
    }
    NSDictionary *config = [[[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSNumber numberWithBool: useHTTPSPort], @"useHTTPSPort",
                            [NSNumber numberWithBool: enableInsecure], @"enableInsecure",
                            nil] autorelease];
    return [config writeToFile: prefPaneConfigFile atomically: YES];
}

- (void) setReadOnly: (BOOL) readOnly {
    enableOpenDNSButton.enabled = !readOnly;
    enableDNSCryptButton.enabled = !readOnly;
    useHTTPSButton.enabled = !readOnly;    
    enableInsecureDNSButton.enabled = !readOnly;
}

- (BOOL) loadPrefPaneConfig
{
    NSString *prefPaneConfigFile = [self getPrefPaneConfigFile];
    if (prefPaneConfigFile == nil) {
        return FALSE;
    }
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile: prefPaneConfigFile];
    if (config == nil) {
        return FALSE;
    }
    NSNumber *useHTTPSPort_ = [config objectForKey: @"useHTTPSPort"];
    if ([useHTTPSPort_ isKindOfClass: [NSNumber class]]) {
        useHTTPSPort = [useHTTPSPort_ boolValue];
    }
    NSNumber *enableInsecure_ = [config objectForKey: @"enableInsecure"];
    if ([enableInsecure_ isKindOfClass: [NSNumber class]]) {
        enableInsecure = [enableInsecure_ boolValue];
    }
    SInt32 OSXversionMajor, OSXversionMinor;
    if (Gestalt(gestaltSystemVersionMajor, &OSXversionMajor) == noErr && Gestalt(gestaltSystemVersionMinor, &OSXversionMinor) == noErr &&
       OSXversionMajor == 10 && OSXversionMinor >= 7) {
        if ([self sendCommandToConfigUpdater: @"dc.w $4E71"] == FALSE) {
            [self setReadOnly: YES];
        } else {
            [self setReadOnly: FALSE];
        }
    }
    return TRUE;
}

- (void) initializeCheckBoxesWithState: (DNSConfigurationState) currentState
{
    [self loadPrefPaneConfig];
    switch (currentState) {
        case kDNS_CONFIGURATION_OPENDNS:
            enableOpenDNSButton.state = NSOnState;
            enableDNSCryptButton.state = NSOffState;
            break;

        case kDNS_CONFIGURATION_LOCALHOST:
            enableOpenDNSButton.state = NSOnState;
            enableDNSCryptButton.state = NSOnState;
            if (useHTTPSPort) {
                useHTTPSButton.state = NSOnState;
            }
            break;

        default:
            enableOpenDNSButton.state = NSOffState;
            enableDNSCryptButton.state = NSOffState;
    }
    if (enableInsecure) {
        enableInsecureDNSButton.state = NSOnState;
    }
}

- (BOOL) updateStatusWithCurrentConfig
{
    DNSConfigurationState currentState = kDNS_CONFIGURATION_UNKNOWN;
    NSArray *resolversForLocalhost = [NSArray arrayWithObjects: kRESOLVER_IP_LOCALHOST, nil];
    NSArray *resolversForOpenDNS = [NSArray arrayWithObjects: kRESOLVER_IP_OPENDNS1, kRESOLVER_IP_OPENDNS2, nil];

    NSError *err;
    NSString *resolvConf = [NSString stringWithContentsOfFile: @"/etc/resolv.conf" encoding: NSISOLatin1StringEncoding error: &err];
    if (resolvConf) {
        NSMutableArray *resolvers = [[[NSMutableArray alloc] init] autorelease];
        NSMutableString *resolversString = [[[NSMutableString alloc] init] autorelease];
        NSArray *lines = [resolvConf componentsSeparatedByString: @"\n"];
        for (NSString *line in lines) {
            line = [line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *entry = [line componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            if (![[entry objectAtIndex: 0U] isEqualToString: @"nameserver"]) {
                continue;
            }
            NSString *resolver = [entry objectAtIndex: 1U];
            [resolvers addObject: resolver];
            [resolversString appendFormat: @"%s%@", (resolversString.length > 0 ? "\n" : ""), resolver];
        }
        if ([self resolversForService: resolvers includeResolvers: resolversForLocalhost]) {
            currentState = kDNS_CONFIGURATION_LOCALHOST;
        } else if ([self resolversForService: resolvers includeResolvers: resolversForOpenDNS]) {
            currentState = kDNS_CONFIGURATION_OPENDNS;
        } else {
            currentState = kDNS_CONFIGURATION_VANILLA;
        }
        if ([resolversString isEqualToString: kRESOLVER_IP_LOCALHOST]) {
            NSString *dnsCryptString;

            if (useHTTPSPort == NO) {
                dnsCryptString = NSLocalizedString(@"%@\nusing DNSCrypt", @"Current resolver when DNSCrypt has been enabled");
            } else {
                dnsCryptString = NSLocalizedString(@"%@\nusing DNSCrypt/HTTPS", @"Current resolver when DNSCrypt has been enabled on the HTTPS port");
            }
            resolversString = [NSString stringWithFormat: dnsCryptString, kDNSCRYPT_RESOLVER];
        }
        currentResolverTextField.stringValue = resolversString;
    }

    NSBundle *bundle = [NSBundle bundleWithIdentifier: @"com.opendns.osx.DNSCrypt"];
    switch (currentState) {
        case kDNS_CONFIGURATION_UNKNOWN:
            statusText.stringValue = NSLocalizedString(@"No network", @"Status");
            statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_red.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_VANILLA:
            statusText.stringValue = NSLocalizedString(@"Unprotected", @"Status");
            statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_red.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_OPENDNS:
            statusText.stringValue = NSLocalizedString(@"Unprotected", @"Status");
            statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_yellow.png"]] autorelease];
            break;
        case kDNS_CONFIGURATION_LOCALHOST:
            statusText.stringValue = NSLocalizedString(@"Protected", @"Status");
            statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"shield_green.png"]] autorelease];
            break;
        default:
            return FALSE;
    }

    if (checkBoxesHaveBeenInitialized == NO) {
        [self initializeCheckBoxesWithState: currentState];
    }
    return TRUE;
}

- (void) showSpinners {
    NSBundle *bundle = [NSBundle bundleWithIdentifier: kBUNDLE_IDENTIFIER];

    statusText.stringValue = @"";
    statusImageView.image = [[[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"ajax-loader.gif"]] autorelease];
    currentResolverTextField.stringValue = @"";
}

- (void) periodicallyUpdateStatusWithCurrentConfig {
    [self updateStatusWithCurrentConfig];
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(periodicallyUpdateStatusWithCurrentConfig) object: nil];
    [self performSelector: @selector(periodicallyUpdateStatusWithCurrentConfig) withObject:nil afterDelay: 0.7];
}

- (void) mainViewDidLoad
{
    state = kDNS_CONFIGURATION_UNKNOWN;
    [self ensureConfigUpdaterIsRunning];
    [self periodicallyUpdateStatusWithCurrentConfig];
    [previewNotesWebView setDrawsBackground:false];

    NSString *version = kDNSCRYPT_PACKAGE_VERSION;
    NSString *softwareBlurbFormat = NSLocalizedString(@"This software (v: %@) encrypts DNS packets between your computer and OpenDNS.  This prevents man-in-the-middle attacks and snooping of DNS traffic by ISPs or others.", @"Description of what the package does - %@ is replaced by the version number");
    NSString *provideFeedback = NSLocalizedString(@"Please help by providing feedback!", @"Ask for feedback");
    NSString *describeTCPWorkaround = NSLocalizedString(@"If you have a firewall or other middleware mangling your packets, try enabling DNSCrypt with TCP over port 443.", @"Describe what the TCP/443 checkbox does");
    NSString *describeFallback = NSLocalizedString(@"If you prefer reliability over security, enable fallback to insecure DNS.", @"Describe what the 'fallback to insecure mode' checkbox does");

    NSMutableString *htmlString = [NSMutableString stringWithString: @"<html><body style=\"font-family:Helvetica, sans-serif; font-size: 11px; color: #333; margin: 0px; padding: 2px 0px;\">"];

    [htmlString appendFormat: softwareBlurbFormat, version];
    [htmlString appendString: @"<br/><br/>"];
    [htmlString appendString: @"<strong>"];
    [htmlString appendString: provideFeedback];
    [htmlString appendString: @"</strong>"];
    [htmlString appendString: @"<ul style=\"list-style-position: inside; list-style-type: square; padding-left: 0px; margin-top: 0; margin-bottom: 0; \">"];
    [htmlString appendFormat: @"<li>%@</li>", describeTCPWorkaround];
    [htmlString appendFormat: @"<li>%@</li>", describeFallback];
    [htmlString appendString: @"</ul>"];
    [htmlString appendString: @"</body></html>"];
    [[previewNotesWebView mainFrame] loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"file:///"]];

    [feedbackWebView setDrawsBackground:false];
    [feedbackWebView setShouldUpdateWhileOffscreen:true];
    [feedbackWebView setUIDelegate:self];
    NSString *feedbackURLText = [NSString stringWithString:@"http://dnscrypt.opendns.com/feedback.php"];
    [[feedbackWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:feedbackURLText]]];

    [releaseNotesWebView setDrawsBackground:false];
    [releaseNotesWebView setShouldUpdateWhileOffscreen:true];
    [releaseNotesWebView setUIDelegate:self];
    NSString *releaseNotesURLText = [NSString stringWithString:@"http://dnscrypt.opendns.com/releasenotes.php"];
    [[releaseNotesWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:releaseNotesURLText]]];

    [aboutWebView setDrawsBackground:false];
    [aboutWebView setShouldUpdateWhileOffscreen:true];
    [aboutWebView setUIDelegate:self];
    NSString *aboutURLText = [NSString stringWithString:@"http://dnscrypt.opendns.com/about.php"];
    [[aboutWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:aboutURLText]]];

}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    // disable right-click context menu
    return nil;
}

- (void) resetCheckBoxesHaveBeenInitialized
{
    checkBoxesHaveBeenInitialized = NO;
}

- (BOOL) updateConfig
{
    checkBoxesHaveBeenInitialized = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(resetCheckBoxesHaveBeenInitialized) object: nil];
    [self performSelector: @selector(resetCheckBoxesHaveBeenInitialized) withObject: self afterDelay:kCHECKBOXES_FREEZE_DELAY];
    [self ensureConfigUpdaterIsRunning];
    if (enableDNSCryptButton.state == NSOffState) {
        if (enableOpenDNSButton.state == NSOffState) {
            [self sendCommandToConfigUpdater: @"CONFIG VANILLA"];
            [self sendCommandToConfigUpdater: @"PROXY STOP"];
            state = kDNS_CONFIGURATION_VANILLA;
        } else {
            [self sendCommandToConfigUpdater: @"CONFIG OPENDNS"];
            [self sendCommandToConfigUpdater: @"PROXY STOP"];
            state = kDNS_CONFIGURATION_OPENDNS;
        }
    } else {
        NSString *proxyStartCommand;

        if (useHTTPSPort == NO) {
            proxyStartCommand = @"PROXY START --resolver-address=" kDNSCRYPT_RESOLVER;
        } else {
            proxyStartCommand = @"PROXY START --tcp-port=443 --resolver-address=" kDNSCRYPT_RESOLVER;
        }
        [self sendCommandToConfigUpdater: proxyStartCommand];
        [self sendCommandToConfigUpdater: @"CONFIG LOCALHOST"];
        state = kDNS_CONFIGURATION_LOCALHOST;
    }
    [self periodicallyUpdateStatusWithCurrentConfig];
    [self showSpinners];
    [self savePrefPaneConfig];

    return TRUE;
}

- (BOOL) updateInsecure {
    [self ensureConfigUpdaterIsRunning];
    if (enableInsecure) {
        [self sendCommandToConfigUpdater: @"FALLBACK ON"];
    } else {
        [self sendCommandToConfigUpdater: @"FALLBACK OFF"];
    }
    [self savePrefPaneConfig];

    return TRUE;
}

- (IBAction)enableOpenDNSButtonPressed:(NSButton *)sender
{
    if (sender.state == NSOffState && enableDNSCryptButton.state != NSOffState) {
        enableDNSCryptButton.state = NSOffState;
        useHTTPSButton.state = NSOffState;
    }
    [self updateConfig];
}

- (IBAction)enableDNSCryptButtonPressed:(NSButton *)sender
{
    if (sender.state == NSOnState && enableOpenDNSButton.state != NSOnState) {
        enableOpenDNSButton.state = NSOnState;
    } else if (sender.state == NSOffState) {
        useHTTPSButton.state = NSOffState;
    }
    [self updateConfig];
}

- (IBAction)enableInsecureDNSButtonPressed:(NSButton *)sender
{
    if (sender.state == NSOnState) {
        enableInsecure = YES;
    } else {
        enableInsecure = NO;
    }
    [self updateInsecure];
}

- (IBAction)enableHTTPSButtonPressed:(NSButton *)sender
{
    if (sender.state == NSOnState) {
        useHTTPSPort = YES;
    } else {
        useHTTPSPort = NO;
    }
    if (useHTTPSPort == YES) {
        enableDNSCryptButton.state = NSOnState;
        enableOpenDNSButton.state = NSOnState;
    }
    [self updateConfig];
}

- (IBAction)openDNSLinkPushed:(NSButton *)sender
{
    (void) sender;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: kOPENDNS_URL]];
}


@end
