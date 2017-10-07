
#import <Cocoa/Cocoa.h>

#define kDNSCRYPT_PREFPANE_APP_PATH @"/Library/PreferencePanes/DNSCrypt.prefPane"
#define kDNSCRYPT_USR_BASE_DIR kDNSCRYPT_PREFPANE_APP_PATH @"/Contents/Resources/usr"
#define kDNSCRIPT_SCRIPTS_BASE_DIR kDNSCRYPT_USR_BASE_DIR @"/scripts"
#define kDNSCRYPT_VAR_BASE_DIR @"/Library/Application Support/DNSCrypt"
#define kDNSCRYPT_CONTROL_DIR kDNSCRYPT_VAR_BASE_DIR @"/control"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *__weak _window;
    NSMenu *_dnscryptMenu;
    NSStatusItem *_statusItem;
    NSMenuItem *_versionMenuItem;
    NSMenuItem *_statusResolversMenuItem;
    NSMenuItem *_dnscryptMenuItem;
}

#define kREFRESH_DELAY 2.0
#define kCHECKBOXES_AFTER_CHANGE_DELAY 8.0
#define kMAX_TRIES_AFTER_CHANGE (30 / kREFRESH_DELAY)

typedef enum {
    kDNS_CONFIGURATION_UNKNOWN, kDNS_CONFIGURATION_VANILLA, kDNS_CONFIGURATION_LOCALHOST
} DNSConfigurationState;

@property (strong) NSStatusItem *statusItem;
@property (weak) NSWindow *window;

@property (strong) IBOutlet NSMenu *dnscryptMenu;
@property (strong) IBOutlet NSMenuItem *versionMenuItem;
@property (strong) IBOutlet NSMenuItem *statusResolversMenuItem;
@property (strong) IBOutlet NSMenuItem *dnscryptMenuItem;

- (IBAction)preferencesMenuItemPushed:(NSMenuItem *)sender;
- (IBAction)dnscryptMenuItemPushed:(NSMenuItem *)sender;
- (IBAction)hideMenubarIconMenuItemPushed:(NSMenuItem *)sender;

@end
