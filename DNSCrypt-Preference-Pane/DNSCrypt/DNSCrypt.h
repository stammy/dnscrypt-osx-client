//
//  DNSCrypt.h
//  DNSCrypt
//
//  Created by OpenDNS, Inc. on 8/11/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <WebKit/WebKit.h>

#define kDNSCRYPT_PACKAGE_VERSION @"0.9"

#define KDNSCRYPT_CONFIG_UPDATER_LABEL @"com.opendns.osx.DNSCryptConfigUpdater"
#define KDNSCRYPT_PROXY_LABEL @"com.opendns.osx.DNSCryptProxy"

#define KLAUNCHCTL_PATH @"/bin/launchctl"

#define kSOCK_GRAND_PARENT_DIR @"/var/run"
#define kSOCK_PARENT_DIR kSOCK_GRAND_PARENT_DIR @"/com.opendns.osx.DNSCryptConfigUpdater"
#define kSOCK_PATH kSOCK_PARENT_DIR @"/sock"

#define kDNSCRYPT_PREFPANE_SUPPORT_DIR @"DNSCrypt Prefpane"
#define kDNSCRYPT_PREFPANE_FILE @"PrefPane.plist"

#define kRESOLVER_IP_LOCALHOST @"127.0.0.1"
#define kRESOLVER_IP_OPENDNS1  @"208.67.220.220"
#define kRESOLVER_IP_OPENDNS2  @"208.67.222.222"

#define kOPENDNS_URL @"http://www.opendns.com"

#define kBUNDLE_IDENTIFIER @"com.opendns.osx.DNSCrypt"

#define kDNSCRYPT_RESOLVER @"208.67.220.220"

#define kCHECKBOXES_FREEZE_DELAY 5.5

typedef enum {
    kDNS_CONFIGURATION_UNKNOWN, kDNS_CONFIGURATION_VANILLA, kDNS_CONFIGURATION_LOCALHOST, kDNS_CONFIGURATION_OPENDNS
} DNSConfigurationState;

@interface DNSCrypt : NSPreferencePane {
    AuthorizationRef auth;
}

@property (weak) IBOutlet NSButton *enableOpenDNSButton;
@property (weak) IBOutlet NSButton *enableDNSCryptButton;
@property (weak) IBOutlet NSTextField *currentResolverTextField;
@property (weak) IBOutlet NSButton *enableInsecureDNSButton;
@property (weak) IBOutlet NSImageView *statusImageView;
@property (weak) IBOutlet NSTextField *statusText;
@property (weak) IBOutlet NSButton *useHTTPSButton;
@property (weak) IBOutlet WebView *previewNotesWebView;
@property (weak) IBOutlet WebView *releaseNotesWebView;
@property (weak) IBOutlet WebView *feedbackWebView;
@property (weak) IBOutlet WebView *aboutWebView;

- (void) mainViewDidLoad;

- (IBAction)enableOpenDNSButtonPressed:(NSButton *)sender;
- (IBAction)enableDNSCryptButtonPressed:(NSButton *)sender;
- (IBAction)enableInsecureDNSButtonPressed:(NSButton *)sender;
- (IBAction)enableHTTPSButtonPressed:(NSButton *)sender;
- (IBAction)openDNSLinkPushed:(NSButton *)sender;



@end
