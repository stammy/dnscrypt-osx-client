//
//  DNSGlobalSettings.h
//  dns-updater
//
//  Created by OpenDNS, Inc. on 10/24/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#define kONLY_CHANGE_SERVICES_WITH_A_BSD_INTERFACE 1

@interface DNSGlobalSettings : NSObject

- (NSArray *) getActiveResolvers __attribute((ns_returns_retained));
- (BOOL) isRunningWithResolvers: (NSArray *) resolvers;
- (BOOL) isRunningWithResolversInResolversList: (NSArray *) resolversList;
- (BOOL) setResolvers: (NSArray *) resolvers;
- (BOOL) revertResolvers;
- (BOOL) backupExceptResolversList: (NSArray *) resolversList;

@end
