//
//  main.m
//  dns-updater
//
//  Created by OpenDNS, Inc. on 10/24/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNSUpdater.h"
#import "ProxySpawner.h"
#import "SocketListener.h"

static DNSUpdater *dnsUpdater;

static void restoreVanilla(void)
{
    dnsUpdater.enableSaveSettings = NO;
    if (dnsUpdater) {
        NSLog(@"Restoring vanilla configuration");
        dnsUpdater.wantedState = kDNS_CONFIGURATION_VANILLA;
        [dnsUpdater update];
        dnsUpdater = nil;
    }
}

static void sigQuitHandler(int sig)
{
    (void) sig;
    restoreVanilla();
    exit(0);
}

int main(void)
{
    @autoreleasepool {
        nice(10);
        ProxySpawner *proxySpawner = [[ProxySpawner alloc] init];
        dnsUpdater = [[DNSUpdater alloc] initWithProxySpawner: proxySpawner];
        SocketListener *socketListener = [[SocketListener alloc] initWithDNSUpdater: dnsUpdater andProxySpawner: proxySpawner];
        [socketListener createListener];

        signal(SIGPIPE, SIG_IGN);
        signal(SIGALRM, sigQuitHandler);
        signal(SIGHUP,  sigQuitHandler);
        signal(SIGINT,  sigQuitHandler);
        signal(SIGQUIT, sigQuitHandler);
        signal(SIGTERM, sigQuitHandler);
        signal(SIGXCPU, sigQuitHandler);
        [dnsUpdater start];
        [dnsUpdater loadDNSSettings];
        [[NSRunLoop currentRunLoop] run];
        restoreVanilla();
    }    
    return 0;
}

