//
//  RSCDNContainer.m
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/27/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSCDNContainer.h"
#import "RSStorageObject.h"
#import "RSClient.h"

#define $S(format, ...) [NSString stringWithFormat:format, ## __VA_ARGS__]

@implementation RSCDNContainer

@synthesize name, cdn_enabled, ttl, log_retention, cdn_uri, cdn_ssl_uri, cdn_streaming_uri, metadata;

- (id)init {
    self = [super init];
    if (self) {
        self.metadata = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSURLRequest *)purgeCDNObjectRequest:(RSStorageObject *)object {
    
    return [self.client cdnRequest:$S(@"/%@/%@", self.name, object.name) httpMethod:@"DELETE"];
    
}

- (NSURLRequest *)purgeCDNObjectRequest:(RSStorageObject *)object emailAddresses:(NSArray *)emailAddresses {
    
    NSMutableURLRequest *request = [self.client cdnRequest:$S(@"/%@/%@", self.name, object.name) httpMethod:@"DELETE"];
    [request addValue:[emailAddresses componentsJoinedByString:@", "] forHTTPHeaderField:@"X-Purge-Email"];
    return request;
    
}

- (void)purgeCDNObject:(RSStorageObject *)object success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self.client sendAsynchronousRequest:@selector(purgeCDNObjectRequest:) object:object sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if (successHandler) {
            successHandler();        
        }
    } failureHandler:failureHandler];
    
}

@end
