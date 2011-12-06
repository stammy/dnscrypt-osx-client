//
//  SocketListener.m
//  dns-updater
//
//  Created by OpenDNS, Inc. on 10/26/11.
//  Copyright (c) 2011 OpenDNS, Inc. All rights reserved.
//

#include <sys/stat.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <grp.h>
#import "ProxySpawner.h"
#import "SocketListener.h"

@implementation SocketListener

DNSUpdater *_updater;
ProxySpawner *_proxySpawner;
NSMutableData *_commandBuffer;

- (id) initWithDNSUpdater: (DNSUpdater *) updater andProxySpawner: (ProxySpawner *)proxySpawner
{
    if (! (self = [super init])) {
        return nil;
    }
    _updater = updater;
    _proxySpawner = proxySpawner;
    _commandBuffer = [[NSMutableData alloc] init];
    
    return self;
}

- (BOOL) commandParseConfig: (NSArray *) commandAsComponents
{
    if (commandAsComponents.count != 2U) {
        return FALSE;
    }
    NSString *stateName = [commandAsComponents objectAtIndex: 1U];
    NSLog(@"Wanted state name: [%@]", stateName);
    if ([stateName isEqualToString: @"VANILLA"]) {
        _updater.wantedState = kDNS_CONFIGURATION_VANILLA;        
    } else if ([stateName isEqualToString: @"LOCALHOST"]) {
        _updater.wantedState = kDNS_CONFIGURATION_LOCALHOST;
    } else if ([stateName isEqualToString: @"OPENDNS"]) {
        _updater.wantedState = kDNS_CONFIGURATION_OPENDNS;
    } else {
        return FALSE;
    }
    if (_updater.state != _updater.wantedState) {
        [_updater periodicallyUpdate];
    }
    return TRUE;
}

- (BOOL) commandParseFallback: (NSArray *) commandAsComponents
{
    if (commandAsComponents.count < 2U) {
        return FALSE;
    }
    NSString *action = [commandAsComponents objectAtIndex: 1U];
    if ([action isEqualToString: @"OFF"]) {
        _updater.enableFallback = NO;
    } else if ([action isEqualToString: @"ON"]) {
        _updater.enableFallback = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName: @"CONFIGURATION_CHANGED" object: self userInfo: nil];
    }
    return FALSE;
}

- (BOOL) commandParseProxy: (NSArray *) commandAsComponents
{
    if (commandAsComponents.count < 2U) {
        return FALSE;
    }
    NSString *action = [commandAsComponents objectAtIndex: 1U];
    if ([action isEqualToString: @"STOP"]) {
        return [_proxySpawner stop];
    } else if ([action isEqualToString: @"START"]) {
        NSArray *suppliedArguments = [commandAsComponents subarrayWithRange: NSMakeRange(2U, commandAsComponents.count - 2U)];
        [_proxySpawner stop];
        return [_proxySpawner startWithArguments: suppliedArguments];
    }
    return FALSE;
}

- (BOOL) commandParse: (NSString *) command
{
    NSArray *commandAsComponents = [command componentsSeparatedByString: @" "];
    if (commandAsComponents.count <= 0U) {
        return FALSE;
    }
    NSString *action = [commandAsComponents objectAtIndex: 0U];
    if ([action isEqualToString: @"CONFIG"]) {
        return [self commandParseConfig: commandAsComponents];
    }
    if ([action isEqualToString: @"PROXY"]) {
        return [self commandParseProxy: commandAsComponents];
    }
    if ([action isEqualToString: @"FALLBACK"]) {
        return [self commandParseFallback: commandAsComponents];
    }
    return FALSE;
}

- (void) commandRead: (NSNotification *) notification
{
    NSFileHandle *fh = (NSFileHandle *) notification.object;
    NSData *chunk = [[notification userInfo] objectForKey: @"NSFileHandleNotificationDataItem"];
    [_commandBuffer appendData: chunk];
    uint32_t commandLen;
    for (;;) {
        if (_commandBuffer.length <= sizeof commandLen) {
            break;
        }
        memcpy(&commandLen, _commandBuffer.bytes, sizeof commandLen);
        if (_commandBuffer.length < commandLen + sizeof commandLen) {
            break;        
        }
        NSData *command_ = [_commandBuffer subdataWithRange: NSMakeRange(sizeof commandLen, commandLen)];
        NSData *remainingBuffer = [_commandBuffer subdataWithRange: NSMakeRange(commandLen + sizeof commandLen, _commandBuffer.length - commandLen - sizeof commandLen)];
        _commandBuffer = [[NSMutableData alloc] initWithData: remainingBuffer];    
        NSString *command = [[NSString alloc] initWithData: command_ encoding: NSUTF8StringEncoding];
        command = [command stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"Received command: [%@]", command);
        [self commandParse: command];
    }
    [fh readInBackgroundAndNotify];    
}

- (BOOL) createListener
{
    mode_t sockParentDirPerms = (mode_t) kSOCK_PARENT_DIR_PERMS;
    mode_t sockPerms = (mode_t) kSOCK_PERMS;
    const char *sockParentDir = [kSOCK_PARENT_DIR cStringUsingEncoding: NSUTF8StringEncoding];
    struct group *group = getgrnam(kSOCK_GROUP_NAME);
    if (group == NULL) {
        sockParentDirPerms = (mode_t) 0711;
        sockPerms = (mode_t) 0666;
    }
    const mode_t previousMask = umask((mode_t) 0177);
    umask((mode_t) 0);
    if (mkdir(sockParentDir, sockParentDirPerms) != 0) {
        if (errno != EEXIST) {
            NSLog(@"mkdir(): [%s]", strerror(errno));
            umask(previousMask);
            return FALSE;
        }
    } else {
        chmod(sockParentDir, sockParentDirPerms);        
    }
    if (group != NULL) {
        chown(sockParentDir, (uid_t) 0, group->gr_gid);
    }
    const char *sockPath = [kSOCK_PATH cStringUsingEncoding: NSUTF8StringEncoding];
    size_t sockPathSize = strlen(sockPath) + (size_t) 1U;
    struct sockaddr_un *su;
    assert(sockPathSize < sizeof su->sun_path);
    socklen_t sun_len = (socklen_t) (sizeof *su) + (socklen_t) sockPathSize;
    su = calloc(1U, sun_len);
    su->sun_family = AF_UNIX;
    memcpy(su->sun_path, sockPath, sockPathSize);    
    su->sun_len = SUN_LEN(su);    
    [[NSFileManager defaultManager] removeItemAtPath: kSOCK_PATH error: nil];
    CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, PF_UNIX, SOCK_DGRAM, IPPROTO_IP, 0, NULL, NULL);
    CFSocketSetSocketFlags(socket, CFSocketGetSocketFlags(socket) & ~kCFSocketCloseOnInvalidate);
    int fd = CFSocketGetNative(socket);
    NSData *address = [NSData dataWithBytes: su length: SUN_LEN(su)];
    if (CFSocketSetAddress(socket, (__bridge CFDataRef) address) != kCFSocketSuccess) {
        free(su);
        CFSocketInvalidate(socket);
        CFRelease(socket);
        NSLog(@"*** Could not bind to address");
        umask(previousMask);
        [[NSFileManager defaultManager] removeItemAtPath: kSOCK_PATH error: nil];

        return FALSE;
    }
    free(su);
    if (group != NULL) {
        chown(sockPath, (uid_t) 0, group->gr_gid);
    }
    chmod(sockPath, sockPerms);
    umask(previousMask);
    NSFileHandle *fh = [[NSFileHandle alloc] initWithFileDescriptor: fd closeOnDealloc: TRUE];
    CFRelease(socket);
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [fh readInBackgroundAndNotify];
    [center addObserver:self
               selector:@selector(commandRead:)
                   name:@"NSFileHandleReadCompletionNotification"
                 object:nil];
    return TRUE;
}

@end
