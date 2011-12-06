//
//  ProxySpawner.m
//  dns-updater
//
//  Created by OpenDNS, Inc. on 10/27/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import "ProxySpawner.h"

@implementation ProxySpawner

- (BOOL) registerLaunchdLabelWithArguments: (NSArray *) arguments
{
    NSArray *launchdBaseArguments = [NSArray arrayWithObjects: @"submit", @"-l", KDNSCRYPT_PROXY_LABEL, @"--", kDNSCRYPT_PROXY_PATH, nil];
    NSArray *launchdArguments = [launchdBaseArguments arrayByAddingObjectsFromArray: arguments];
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = KLAUNCHCTL_PATH;
    task.arguments = launchdArguments;
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    [task launch];
    [task waitUntilExit];

    return TRUE;
}

- (BOOL) unregisterLaunchdLabel
{
    NSArray *launchdArguments = [NSArray arrayWithObjects: @"remove", KDNSCRYPT_PROXY_LABEL, nil];
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = KLAUNCHCTL_PATH;
    task.arguments = launchdArguments;
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    [task launch];
    [task waitUntilExit];

    return TRUE;
}

- (BOOL) argumentsAreWhiteListed: (NSArray *) arguments {
    NSArray *whiteListedPrefixes = [NSArray arrayWithObjects: @"--tcp-port=443", @"--resolver-address=208.67.", nil];
    BOOL found;
    
    for (NSString *argument in arguments) {
        found = NO;
        for (NSString *whiteListedPrefix in whiteListedPrefixes) {
            if ([argument hasPrefix: whiteListedPrefix]) {
                found = YES;
                break;
            }
        }
        if (! found) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) startWithArguments: (NSArray *) arguments;
{
    if ([self argumentsAreWhiteListed: arguments] == NO) {
        return FALSE;        
    }
    NSArray *proxyBaseArguments = [NSArray arrayWithObjects: @"--user", kDNSCRYPT_PROXY_USER, nil];
    NSArray *proxyArguments = [proxyBaseArguments arrayByAddingObjectsFromArray: arguments];
    [self registerLaunchdLabelWithArguments: proxyArguments];

    NSArray *launchdArguments = [NSArray arrayWithObjects: @"start", KDNSCRYPT_PROXY_LABEL, nil];
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = KLAUNCHCTL_PATH;
    task.arguments = launchdArguments;
    [task launch];
    [task waitUntilExit];

    return TRUE;
}

- (BOOL) stop
{
    NSArray *launchdArguments = [NSArray arrayWithObjects: @"stop", KDNSCRYPT_PROXY_LABEL, nil];
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = KLAUNCHCTL_PATH;
    task.arguments = launchdArguments;
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    [task launch];
    [task waitUntilExit];

    [self unregisterLaunchdLabel];

    return TRUE;
}

@end
