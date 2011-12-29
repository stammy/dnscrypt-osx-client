//
//  DNSUpdater.h
//  dns-updater
//
//  Created by OpenDNS, Inc. on 10/26/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import "ProxySpawner.h"

typedef enum {
    kDNS_CONFIGURATION_UNKNOWN, kDNS_CONFIGURATION_VANILLA, kDNS_CONFIGURATION_LOCALHOST, kDNS_CONFIGURATION_OPENDNS
} DNSConfigurationState;

#define kRESOLVER_IP_LOCALHOST @"127.0.0.1"
#define kRESOLVER_IP_OPENDNS1  @"208.67.220.220"
#define kRESOLVER_IP_OPENDNS2  @"208.67.222.222"
#define kRESOLVER_IP_DNSCRYPT  @"208.67.220.220"

#define kHOST_NAME_FOR_PROBES  @"myip.opendns.com"

#define kINTERVAL_BETWEEN_CONFIG_UPDATES 2.5
#define kINTERVAL_BETWEEN_DELAYED_PROBES (60.0 * 15.0)
#define kDELAY_BETWEEN_ASYNC_RESOLUTION_ATTEMPTS 0.5
#define kINTERVAL_BETWEEN_ASYNC_RESOLUTION_RETRIES 1.0
#define kINTERVAL_BEFORE_ASYNC_RESOLUTION 5.0
#define kASYNC_RESOLUTION_TIMEOUT 10.0

#define kASYNC_RESOLUTION_MAX_ATTEMPTS 3U

#define kDNSCRYPT_APPLICATION_SUPPORT_DIR @"DNSCrypt Updater"
#define kDNS_SETTINGS_FILE @"settings-v1.plist"

@interface DNSUpdater : NSObject {
    DNSConfigurationState state;
    DNSConfigurationState _wantedState;
    BOOL _enableFallback;
    BOOL enableSaveSettings;
}

@property (assign) DNSConfigurationState state;
@property (assign) BOOL enableSaveSettings;
@property (readwrite) DNSConfigurationState wantedState;
@property (readwrite) BOOL enableFallback;

- (id) initWithProxySpawner: (ProxySpawner *) proxySpawner;
- (void) start;
- (void) periodicallyUpdate;
- (void) update;
- (BOOL) saveDNSSettings;
- (BOOL) loadDNSSettings;

@end
