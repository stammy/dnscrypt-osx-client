//
//  AppDelegate.h
//  DNSCrypt-Menubar
//
//  Created by OpenDNS, Inc. on 10/31/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kRESOLVER_IP_LOCALHOST @"127.0.0.1"
#define kRESOLVER_IP_OPENDNS1  @"208.67.220.220"
#define kRESOLVER_IP_OPENDNS2  @"208.67.222.222"
#define kDNSCRYPT_RESOLVER     @"208.67.220.220"

#define kDNSCRYPT_PREFPANE_APP_PATH @"/Library/PreferencePanes/DNSCrypt.prefPane"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSMenu *dnscryptMenu;
@property (strong) NSStatusItem *statusItem;
@property (strong) IBOutlet NSMenuItem *versionMenuItem;

typedef enum {
    kDNS_CONFIGURATION_UNKNOWN, kDNS_CONFIGURATION_VANILLA, kDNS_CONFIGURATION_LOCALHOST, kDNS_CONFIGURATION_OPENDNS
} DNSConfigurationState;

@property (strong) IBOutlet NSMenuItem *statusResolversMenuItem;
@property (strong) IBOutlet NSMenuItem *statusConfigurationMenuItem;

- (IBAction)preferencesMenuItemPushed:(NSMenuItem *)sender;

@end
