//
//  RSCDNContainer.h
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/27/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSModel.h"

@class RSStorageObject;

/** The RSCDNContainer class represents a CDN-enabled container in your Cloud Files account.  
 *  A container is a storage compartment for your data and provides a way for you
 *  to organize your data.  You can think of a container as a folder, but unlike a folder,
 *  it cannot be nested.
 *
 *  Files stored in your account must be stored in a container.
 *  
 *  Files in CDN-enabled containers are accessible to the public via the CDN URL.
 */
@interface RSCDNContainer : RSModel

/** The name of the container */
@property (nonatomic, strong) NSString *name;

/** `YES` if the container is currently CDN-enabled */
@property (nonatomic) BOOL cdn_enabled;

/** The time to live for the container */
@property (nonatomic) NSInteger ttl;

/** `YES` if CDN access logging is enabled.  Logs are stored in the `.CDN_ACCESS_LOGS` container
 *  in your account.
 */
@property (nonatomic) BOOL log_retention;

/** The HTTP URI to the container */
@property (nonatomic, strong) NSURL *cdn_uri;

/** The SSL (HTTPS) URI to the container */
@property (nonatomic, strong) NSURL *cdn_ssl_uri;

/** The streaming URI to the container */
@property (nonatomic, strong) NSURL *cdn_streaming_uri;

/** Optional metadata associated with the container.  Keys and values for the metadata
 *  are strings.
 */
@property (nonatomic, strong) NSMutableDictionary *metadata;

#pragma mark Purge CDN Object

/** Returns a request object that represents a request to purge a file from the CDN.
 *  @param object The file to purge
 */
- (NSURLRequest *)purgeCDNObjectRequest:(RSStorageObject *)object;

/** Returns a request object that represents a request to purge a file from the CDN.
 *  @param object The file to purge
 *  @param emailAddresses An array of NSString objects representing email addresses to notify when the container is purged
 */
- (NSURLRequest *)purgeCDNObjectRequest:(RSStorageObject *)object emailAddresses:(NSArray *)emailAddresses;

/** Purges a file from the CDN.
 *  @param object The file to purge
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)purgeCDNObject:(RSStorageObject *)object success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

@end
