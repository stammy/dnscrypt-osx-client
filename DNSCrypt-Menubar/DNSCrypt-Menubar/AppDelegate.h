//
//  AppDelegate.h
//  DNSCrypt-Menubar
//
//  Created by OpenDNS, Inc. on 10/31/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kDNSCRYPT_PREFPANE_APP_PATH @"/Library/PreferencePanes/DNSCrypt.prefPane"
#define kDNSCRYPT_USR_BASE_DIR kDNSCRYPT_PREFPANE_APP_PATH @"/Contents/Resources/usr"
#define kDNSCRIPT_SCRIPTS_BASE_DIR kDNSCRYPT_USR_BASE_DIR @"/scripts"
#define kDNSCRYPT_VAR_BASE_DIR @"/Library/Application Support/DNSCrypt"
#define kDNSCRYPT_CONTROL_DIR kDNSCRYPT_VAR_BASE_DIR @"/control"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSMenu *dnscryptMenu;
@property (strong) NSStatusItem *statusItem;
@property (strong) IBOutlet NSMenuItem *versionMenuItem;

#define kREFRESH_DELAY 2.0
#define kCHECKBOXES_AFTER_CHANGE_DELAY 8.0
#define kMAX_TRIES_AFTER_CHANGE (30 / kREFRESH_DELAY)

typedef enum {
    kDNS_CONFIGURATION_UNKNOWN, kDNS_CONFIGURATION_VANILLA, kDNS_CONFIGURATION_LOCALHOST, kDNS_CONFIGURATION_OPENDNS
} DNSConfigurationState;

@property (strong) IBOutlet NSMenuItem *statusResolversMenuItem;
@property (strong) IBOutlet NSMenuItem *statusConfigurationMenuItem;
@property (strong) IBOutlet NSMenuItem *familyShieldMenuItem;
@property (strong) IBOutlet NSMenuItem *dnscryptMenuItem;
@property (strong) IBOutlet NSMenuItem *fallbackMenuItem;
@property (strong) IBOutlet NSMenuItem *opendnsMenuItem;

- (IBAction)preferencesMenuItemPushed:(NSMenuItem *)sender;
- (IBAction)dnscryptMenuItemPushed:(NSMenuItem *)sender;
- (IBAction)familyShieldMenuItemPushed:(NSMenuItem *)sender;
- (IBAction)fallbackMenuItemPushed:(NSMenuItem *)sender;
- (IBAction)opendnsMenuItemPushed:(NSMenuItem *)sender;

@end
