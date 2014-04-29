
#import <PreferencePanes/PreferencePanes.h>
#import <WebKit/WebKit.h>
#import "CHCSVParser/CHCSVParser.h"

#define kDNSCRYPT_PACKAGE_VERSION @"1.0.1"

#define kDNSCRYPT_PREFPANE_APP_PATH @"/Library/PreferencePanes/DNSCrypt.prefPane"
#define kDNSCRYPT_USR_BASE_DIR kDNSCRYPT_PREFPANE_APP_PATH @"/Contents/Resources/usr"
#define kDNSCRIPT_BIN_BASE_DIR kDNSCRYPT_USR_BASE_DIR @"/bin"
#define kDNSCRIPT_SCRIPTS_BASE_DIR kDNSCRYPT_USR_BASE_DIR @"/scripts"
#define kDNSCRYPT_VAR_BASE_DIR @"/Library/Application Support/DNSCrypt"
#define kDNSCRYPT_CONTROL_DIR kDNSCRYPT_VAR_BASE_DIR @"/control"

#define kDNSCRYPT_QUERY_LOG_FILE @"/var/log/dnscrypt-query.log"
#define kDNSCRYPT_BLACKLIST_IPS_TMP_FILE kDNSCRYPT_CONTROL_DIR @"/blacklist-ips.tmp"
#define kDNSCRYPT_BLACKLIST_DOMAINS_TMP_FILE kDNSCRYPT_CONTROL_DIR @"/blacklist-domains.tmp"
#define kDNSCRYPT_EXCEPTIONS_TMP_FILE kDNSCRYPT_CONTROL_DIR @"/exceptions.tmp"

#define kBUNDLE_IDENTIFIER @"com.github.dnscrypt-osxclient.DNSCrypt"

#define kRESOLVERS_LIST_FILE @"/usr/local/share/dnscrypt-proxy/dnscrypt-resolvers.csv"

#define kREFRESH_DELAY 2.0
#define kCHECKBOXES_AFTER_CHANGE_DELAY 8.0
#define kMAX_TRIES_AFTER_CHANGE (30 / kREFRESH_DELAY)

typedef enum {
    kDNS_CONFIGURATION_UNKNOWN, kDNS_CONFIGURATION_VANILLA, kDNS_CONFIGURATION_LOCALHOST
} DNSConfigurationState;

@interface DNSCrypt : NSPreferencePane {
    AuthorizationRef auth;
    
    NSTabView *_tabView;
    NSTabViewItem *_aboutTabViewItem;
    NSTabViewItem *_releaseNotesTabViewItem;
    
    NSButton *_dnscryptButton;
    NSButton *_fallbackButton;
    
    NSTextField *_currentResolverTextField;
    NSImageView *_statusImageView;
    NSTextField *_statusText;
    WebView *_releaseNotesWebView;
    WebView *_aboutWebView;
    NSTextFieldCell *_staticResolversTextField;
    NSTextField *_blacklistIPsTextField;
    NSTextField *_blacklistDomainsTextField;
    NSTextField *_exceptionsTextField;
    WebView *_helpWebView;
    NSButton *_viewLogButton;
    NSButton *_queryLoggingButton;
    NSPopUpButton *_resolverNamesButton;
}
@property (nonatomic, strong) IBOutlet NSTabView *tabView;
@property (nonatomic, strong) IBOutlet NSTabViewItem *aboutTabViewItem;
@property (nonatomic, strong) IBOutlet NSTabViewItem *releaseNotesTabViewItem;

@property (nonatomic, strong) IBOutlet NSButton *dnscryptButton;
@property (nonatomic, strong) IBOutlet NSButton *fallbackButton;

@property (nonatomic, strong) IBOutlet NSTextField *currentResolverTextField;
@property (nonatomic, strong) IBOutlet NSImageView *statusImageView;
@property (nonatomic, strong) IBOutlet NSTextField *statusText;
@property (nonatomic, strong) IBOutlet WebView *releaseNotesWebView;
@property (nonatomic, strong) IBOutlet WebView *aboutWebView;
@property (nonatomic, strong) IBOutlet NSTextFieldCell *staticResolversTextField;
@property (nonatomic, strong) IBOutlet NSTextField *blacklistIPsTextField;
@property (nonatomic, strong) IBOutlet NSTextField *blacklistDomainsTextField;
@property (nonatomic, strong) IBOutlet NSTextField *exceptionsTextField;
@property (nonatomic, strong) IBOutlet WebView *helpWebView;
@property (nonatomic, strong) IBOutlet NSButton *viewLogButton;
@property (nonatomic, strong) IBOutlet NSButton *queryLoggingButton;

@property (nonatomic, strong) IBOutlet NSPopUpButton *resolverNamesButton;
@property (nonatomic, strong) IBOutlet NSTextField *locationText;

@property (nonatomic, strong) IBOutlet NSButton *providerLink;

@property (nonatomic, strong) IBOutlet NSTextFieldCell *descriptionText;

- (void) mainViewDidLoad;

- (IBAction)dnscryptButtonPressed:(NSButton *)sender;
- (IBAction)fallbackButtonPressed:(NSButton *)sender;

- (IBAction)providerLinkPushed:(NSButton *)sender;
- (IBAction)uninstallPushed:(NSButton *)sender;
- (IBAction)staticResolversTextFieldChanged:(NSTextField *)sender;
- (IBAction)queryLoggingButtonPressed:(NSButtonCell *)sender;
- (IBAction)viewLogButtonPushed:(NSButton *)sender;
- (IBAction)blacklistIPsUpdated:(NSTextField *)sender;
- (IBAction)blacklistDomainsUpdated:(NSTextField *)sender;
- (IBAction)exceptionsUpdated:(NSTextField *)sender;
- (IBAction)helpButtonPressed:(NSButton *)sender;
- (IBAction)resolversNamesPopupButtonPressed:(NSPopUpButton *)sender;

@end
