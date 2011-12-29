//
//  ProxySpawner.h
//  dns-updater
//
//  Created by OpenDNS, Inc. on 10/27/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KLAUNCHCTL_PATH @"/bin/launchctl"
#define kDNSCRYPT_PROXY_USER @"nobody"
#define KDNSCRYPT_PROXY_LABEL @"com.opendns.osx.DNSCryptProxy"
#define kDNSCRYPT_PROXY_PATH @"/usr/local/sbin/dnscrypt-proxy"

@interface ProxySpawner : NSObject {
    NSArray *_arguments;
}

@property (strong) NSArray *arguments;

- (BOOL) startWithArguments: (NSArray *) suppliedArguments;
- (BOOL) stop;

@end
