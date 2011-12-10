//
//  SocketListener.h
//  dns-updater
//
//  Created by OpenDNS, Inc. on 10/26/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import "DNSUpdater.h"
#import "ProxySpawner.h"

#define kSOCK_GRAND_PARENT_DIR @"/var/run"
#define kSOCK_PARENT_DIR kSOCK_GRAND_PARENT_DIR @"/com.opendns.osx.DNSCryptConfigUpdater"
#define kSOCK_PATH kSOCK_PARENT_DIR @"/sock"
#define kSOCK_GROUP_NAME "admin"
#define kSOCK_PARENT_DIR_PERMS 0710
#define kSOCK_PERMS 0660
#define kSOCK_REFRESH_RATE 5.0
#define kREF_OWNER_FILE @"/dev/console"

@interface SocketListener : NSObject

- (id) initWithDNSUpdater: (DNSUpdater *) updater andProxySpawner: (ProxySpawner *) proxySpawner;
- (BOOL) createListener;
- (BOOL) updateSocketPerms;

@end
