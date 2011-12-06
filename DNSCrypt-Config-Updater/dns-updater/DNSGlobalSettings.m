//
//  DNSGlobalSettings.m
//  dns-updater
//
//  Created by OpenDNS, Inc. on 10/24/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import "DNSGlobalSettings.h"

@implementation DNSGlobalSettings

- (BOOL) forceDHCPUpdate
{
    NSLog(@"Forcing DHCP update");
    NSArray *interfaces = (__bridge_transfer NSArray *) SCNetworkInterfaceCopyAll();
    for (id interface_ in interfaces) {
        SCNetworkInterfaceRef interface = (__bridge SCNetworkInterfaceRef) interface_;
        SCNetworkInterfaceForceConfigurationRefresh(interface);
    }
    return TRUE;
}

- (BOOL) applyToNetworkServices: (BOOL (^)(SCDynamicStoreRef fs, NSString *service, NSDictionary *properties, NSArray *serverAddresses)) cb
{
    SCDynamicStoreRef ds = SCDynamicStoreCreate(NULL, CFSTR("dnscrypt"), NULL, NULL);
#ifdef kONLY_CHANGE_SERVICES_WITH_A_BSD_INTERFACE
    NSArray *services = (__bridge_transfer NSArray *) SCDynamicStoreCopyKeyList(ds, CFSTR("(State|Setup):/Network/Service/.+/DNS"));
#else
    NSArray *services = (__bridge_transfer NSArray *) SCDynamicStoreCopyKeyList(ds, CFSTR("(State|Setup):/Network/(Service/.+|Global)/DNS"));
#endif
    BOOL ret = TRUE;
    for (NSString *service in services) {
#ifdef kONLY_CHANGE_SERVICES_WITH_A_BSD_INTERFACE
        NSArray *elements = [service componentsSeparatedByString: @"/"];
        if (elements.count < 4U) {
            continue;
        }
        NSString *serviceId = [elements objectAtIndex: 3U];
        NSString *interfacePath = [NSString stringWithFormat: @"Setup:/Network/Service/%@/Interface", serviceId];
        NSDictionary *interfaceProperties = (__bridge_transfer NSDictionary *) SCDynamicStoreCopyValue(ds, (__bridge CFStringRef) interfacePath);
        if (interfaceProperties == nil || ! [interfaceProperties isKindOfClass: [NSDictionary class]]) {
            continue;
        }
        NSString *bsdInterface = [interfaceProperties objectForKey: @"DeviceName"];
        if (bsdInterface == nil) {
            continue;
        }
        NSLog(@"Found BSD interface: [%@]", bsdInterface);
#endif
        NSDictionary *properties = (__bridge_transfer NSDictionary *) SCDynamicStoreCopyValue(ds, (__bridge CFStringRef) service);
        if (properties == nil || ! [properties isKindOfClass: [NSDictionary class]]) {
            continue;
        }
        NSArray *serverAddresses = [properties objectForKey: @"ServerAddresses"];
        if (serverAddresses == nil || ! [serverAddresses isKindOfClass: [NSArray class]]) {
            continue;
        }
        ret &= cb(ds, service, properties, serverAddresses);
    }
    CFRelease(ds);

    return ret;
}

- (BOOL) setResolvers: (NSArray *) resolvers
{
    [self applyToNetworkServices: ^BOOL(SCDynamicStoreRef ds, NSString *service, NSDictionary *properties, NSArray *serverAddresses) {
        NSMutableDictionary *newProperties = [NSMutableDictionary dictionaryWithDictionary: properties];
        [newProperties setObject: resolvers forKey: @"ServerAddresses"];
        SCDynamicStoreSetValue(ds, (__bridge CFStringRef) service, (__bridge CFDictionaryRef) newProperties);
        return TRUE;
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName: @"CONFIGURATION_CHANGED" object: self userInfo: nil];

    return TRUE;
}

- (BOOL) revertResolvers
{
    [self applyToNetworkServices: ^BOOL(SCDynamicStoreRef ds, NSString *service, NSDictionary *properties, NSArray *serverAddresses) {
        NSDictionary *propertiesWithBackup = [properties objectForKey: @"DNSCryptBackup"];
        if (propertiesWithBackup == nil || ! [propertiesWithBackup isKindOfClass: [NSDictionary class]]) {
            return FALSE;
        }
        NSArray *backupedServerAddresses = [propertiesWithBackup objectForKey: @"ServerAddresses"];
        if (backupedServerAddresses == nil || ! [backupedServerAddresses isKindOfClass: [NSArray class]]) {
            return FALSE;
        }
        NSMutableDictionary *newProperties = [NSMutableDictionary dictionaryWithDictionary: properties];
        [newProperties setObject: backupedServerAddresses forKey: @"ServerAddresses"];
        SCDynamicStoreSetValue(ds, (__bridge CFStringRef) service, (__bridge CFDictionaryRef) newProperties);
        return TRUE;
    }];

    [self forceDHCPUpdate];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CONFIGURATION_CHANGED" object: self userInfo: nil];

    return TRUE;
}

- (NSArray *) getActiveResolvers
{
    NSError *err;
    NSString *resolvConf = [NSString stringWithContentsOfFile: @"/etc/resolv.conf" encoding: NSISOLatin1StringEncoding error: &err];
    NSMutableArray *resolvers = [[NSMutableArray alloc] init];
    if (! resolvConf) {
        return resolvers;
    }
    NSArray *lines = [resolvConf componentsSeparatedByString: @"\n"];
    for (NSString *line_ in lines) {
        NSString *line = [line_ stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *entry = [line componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        if (![[entry objectAtIndex: 0U] isEqualToString: @"nameserver"]) {
            continue;
        }
        NSString *resolver = [entry objectAtIndex: 1U];
        [resolvers addObject: resolver];
    }
    return resolvers;
}

- (BOOL) resolversForService: (NSArray *) serverAddresses areInResolversList: (NSArray *) resolversList
{
    for (NSArray *resolvers in resolversList) {
        if ([serverAddresses isEqualToArray: resolvers]) {
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL) isRunningWithResolvers: (NSArray *) resolvers
{
    NSArray *activeResolvers = [self getActiveResolvers];

    return [activeResolvers isEqualToArray: resolvers];
}

- (BOOL) isRunningWithResolversInResolversList: (NSArray *) resolversList
{
    NSArray *activeResolvers = [self getActiveResolvers];

    return [self resolversForService: activeResolvers areInResolversList: resolversList];
}

- (BOOL) backupExceptResolversList: (NSArray *) resolversList
{
    [self applyToNetworkServices: ^BOOL(SCDynamicStoreRef ds, NSString *service, NSDictionary *properties, NSArray *serverAddresses) {
        if ([self resolversForService: serverAddresses areInResolversList: resolversList]) {
            return FALSE;
        }
        NSMutableDictionary *propertiesWithBackup = [NSMutableDictionary dictionaryWithDictionary: properties];
        NSDictionary *serverAddressesBackup = [NSDictionary dictionaryWithObject: serverAddresses forKey: @"ServerAddresses"];
        [propertiesWithBackup setObject: serverAddressesBackup forKey: @"DNSCryptBackup"];
        SCDynamicStoreSetValue(ds, (__bridge CFStringRef) service, (__bridge CFDictionaryRef) propertiesWithBackup);
        return TRUE;
    }];

    return TRUE;
}

@end
