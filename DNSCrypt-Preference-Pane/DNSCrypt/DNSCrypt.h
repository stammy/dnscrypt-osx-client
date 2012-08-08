//
//  DNSCrypt.h
//  DNSCrypt
//
//  Created by OpenDNS, Inc. on 8/11/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <WebKit/WebKit.h>

#define kDNSCRYPT_PACKAGE_VERSION @"0.13"

#define kDNSCRYPT_PREFPANE_APP_PATH @"/Library/PreferencePanes/DNSCrypt.prefPane"
#define kDNSCRYPT_USR_BASE_DIR kDNSCRYPT_PREFPANE_APP_PATH @"/Contents/Resources/usr"
#define kDNSCRIPT_SCRIPTS_BASE_DIR kDNSCRYPT_USR_BASE_DIR @"/scripts"
#define kDNSCRYPT_VAR_BASE_DIR @"/Library/Application Support/DNSCrypt"
#define kDNSCRYPT_CONTROL_DIR kDNSCRYPT_VAR_BASE_DIR @"/control"

#define kOPENDNS_URL @"http://www.opendns.com"

#define kBUNDLE_IDENTIFIER @"com.opendns.osx.DNSCrypt"

#define kREFRESH_DELAY 2.0
#define kCHECKBOXES_AFTER_CHANGE_DELAY 8.0
#define kMAX_TRIES_AFTER_CHANGE (30 / kREFRESH_DELAY)

typedef enum {
    kDNS_CONFIGURATION_UNKNOWN, kDNS_CONFIGURATION_VANILLA, kDNS_CONFIGURATION_LOCALHOST, kDNS_CONFIGURATION_OPENDNS
} DNSConfigurationState;

@interface DNSCrypt : NSPreferencePane {
    AuthorizationRef auth;
}
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSTabViewItem *aboutTabViewItem;
@property (strong) IBOutlet NSTabViewItem *releaseNotesTabViewItem;

@property (strong) IBOutlet NSButton *dnscryptButton;
@property (strong) IBOutlet NSButton *opendnsButton;
@property (strong) IBOutlet NSButton *familyShieldButton;
@property (strong) IBOutlet NSButton *fallbackButton;

@property (strong) IBOutlet NSTextField *currentResolverTextField;
@property (strong) IBOutlet NSImageView *statusImageView;
@property (strong) IBOutlet NSTextField *statusText;
@property (strong) IBOutlet WebView *previewNotesWebView;
@property (strong) IBOutlet WebView *releaseNotesWebView;
@property (strong) IBOutlet WebView *feedbackWebView;
@property (strong) IBOutlet WebView *aboutWebView;

- (void) mainViewDidLoad;

- (IBAction)dnscryptButtonPressed:(NSButton *)sender;
- (IBAction)opendnsButtonPressed:(NSButton *)sender;
- (IBAction)familyShieldButtonPressed:(NSButton *)sender;
- (IBAction)fallbackButtonPressed:(NSButton *)sender;

- (IBAction)openDNSLinkPushed:(NSButton *)sender;

@end
