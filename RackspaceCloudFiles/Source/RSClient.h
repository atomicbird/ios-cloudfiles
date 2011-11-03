//
//  RSClient.h
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/25/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSContainer.h"
#import "RSCDNContainer.h"
#import "RSStorageObject.h"

#define kRSDefaultTTL 259200

#define EAUTHFAILURE 1 /* Authentication failed */
static NSString *RSErrorDomain = @"RSErrorDomain";

/** Rackspace API provider types */
typedef enum {
    RSProviderTypeRackspaceUS,
    RSProviderTypeRackspaceUK
} RSProviderType;

/**
 The RSClient class is the root class for the Rackspace Cloud Files SDK.  You use it to authenticate 
 with your account and work with containers and CDN containers.  You must have a RSClient object available 
 in your code to use the other classes.
 
 Your username is the username you use to login to http://manage.rackspacecloud.com, and your API Key 
 is available in the My Account section of http://manage.rackspacecloud.com.  If you are a UK user, 
 pass `RSProviderTypeRackspaceUK` to the provider argument in the constructor.  If you are using 
 OpenStack Swift, you can provide your own authentication URL.
 
 Once you have created your object, you can optionally authenticate before performing any operations.  
 If you do not authenticate, the client will authenticate for you before performing any other 
 API operations. 
 */
@interface RSClient : RSModel

#pragma mark - Properties

/** The username for this account */
@property (nonatomic, strong) NSString *username;

/** The API Key for this account.  For Rackspace Cloud accounts, this is available in the
 *  My Account section of https://manage.rackspacecloud.com.
 */
@property (nonatomic, strong) NSString *apiKey;

/** The authentication URL for the API */
@property (nonatomic, strong) NSURL *authURL;

/** This property is set to YES when the client object has authenticated with the API. */
@property (nonatomic) BOOL authenticated;

/** The authentication token returned by the authentication API.  The auth token is used
 *  to authenticate for other API options, but it is ephemeral, so you still need to authenticate
 *  at the beginning of a session with your username and API key.
 */
@property (nonatomic, strong) NSString *authToken;

/** Base URL string for the Cloud Files Storage API */
@property (nonatomic, strong) NSString *storageURL;

/** Base URL string for the Cloud Files CDN Management API */
@property (nonatomic, strong) NSString *cdnManagementURL;

/** The total number of containers in this account */
@property (nonatomic) NSUInteger containerCount;

/** The total number of bytes stored in this account */
@property (nonatomic) NSUInteger totalBytesUsed;

#pragma mark - Constructors

/** Creates a RSClient object with the specified provider, username, and API key. 
 *  @provider The cloud provider to use
 *  @param username Your username
 *  @param apiKey Your API key, available in the My Account section of http://manage.rackspacecloud.com for Rackspace Cloud accounts
 */
- (id)initWithProvider:(RSProviderType)provider username:(NSString *)username apiKey:(NSString *)apiKey;

/** Creates a RSClient object with the specified auth URL, username, and API key. 
 *  @param authURL The URL to use for authentication
 *  @param username Your username
 *  @param apiKey Your API key, available in the My Account section of http://manage.rackspacecloud.com for Rackspace Cloud accounts
 */
- (id)initWithAuthURL:(NSURL *)authURL username:(NSString *)username apiKey:(NSString *)apiKey;

#pragma mark - Common

/** Returns a request to the Storage API with the given path and HTTP method 
 *  @param path The path in the API.  Example: /containers
 *  @param httpMethod The HTTP method to use
 */
- (NSMutableURLRequest *)storageRequest:(NSString *)path httpMethod:(NSString *)httpMethod;

/** Returns a GET request to the Storage API with the given path 
 *  @param path The path in the API.  Example: /containers
 */
- (NSMutableURLRequest *)storageRequest:(NSString *)path;

/** Returns a request to the CDN Management API with the given path and HTTP method 
 *  @param path The path in the API.  Example: /containers
 *  @param httpMethod The HTTP method to use
 */
- (NSMutableURLRequest *)cdnRequest:(NSString *)path httpMethod:(NSString *)httpMethod;

/** Returns a GET request to the CDN Management API with the given path 
 *  @param path The path in the API.  Example: /containers
 */
- (NSMutableURLRequest *)cdnRequest:(NSString *)path;

/** Asynchronously sends a HTTP request with callbacks for success and failure responses.
 *  @param requestSelector A selector to retrieve the HTTP request to send
 *  @param object Optional argument for the requestSelector
 *  @param sender The object that owns the requestSelector
 *  @param successHandler A block that will be executed if the request is successfully executed and returns a HTTP response code in the 2xx block (200-299)
 *  @param failureHandler A block that will be executed if the request is not successfully executed or returns a HTTP response code outside of the 2xx block (for example, a 404 Not Found response)
 */
- (void)sendAsynchronousRequest:(SEL)requestSelector object:(id)object sender:(id)sender successHandler:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))successHandler failureHandler:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

/** Asynchronously sends a HTTP request with callbacks for success and failure responses.
 *  @param requestSelector A selector to retrieve the HTTP request to send
 *  @param sender The object that owns the requestSelector
 *  @param successHandler A block that will be executed if the request is successfully executed and returns a HTTP response code in the 2xx block (200-299)
 *  @param failureHandler A block that will be executed if the request is not successfully executed or returns a HTTP response code outside of the 2xx block (for example, a 404 Not Found response)
 */
- (void)sendAsynchronousRequest:(SEL)requestSelector sender:(id)sender successHandler:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))successHandler failureHandler:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark - Authentication

/** Returns a request object that represents an authentication request to the API */
- (NSURLRequest *)authenticationRequest;

/** Authenticates with the API.  If you do not authenticate before performing any API operations,
 *  RSClient will authenticate for you.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)authenticate:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark - Storage Services

#pragma mark Get Account Metadata

/** Returns a request object that represents a request for account metadata */
- (NSURLRequest *)getAccountMetadataRequest;

/** Retrieves account metadata (number of containers and total bytes used) from the API.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)getAccountMetadata:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark Get Containers

/** Returns a request object that represents a request for an account's containers */
- (NSURLRequest *)getContainersRequest;

/** Returns a request object that represents a request for an account's containers.
 *  @param limit The maximum number of containers to return
 *  @param marker Pass a value here to return object names greater than the marker you specify
 */
- (NSURLRequest *)getContainersRequestWithLimit:(NSUInteger)limit marker:(NSString *)marker;

/** Retrieves a list of containers in your account.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)getContainers:(void (^)(NSArray *containers, NSError *jsonError))successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark Create Container

/** Returns a request object that represents a request to create a container 
 *  @param container The container to create
 */
- (NSURLRequest *)createContainerRequest:(RSContainer *)container;

/** Creates a container in your account.
 *  @param container The container to create
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)createContainer:(RSContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark Delete Container

/** Returns a request object that represents a request to delete a container 
 *  @param container The container to delete
 */
- (NSURLRequest *)deleteContainerRequest:(RSContainer *)container;

/** Deletes a container from your account.
 *  @param container The container to delete
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)deleteContainer:(RSContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark Get Container Metadata

/** Returns a request object that represents a request to retrieve a container's metadata 
 *  @param container The container to get metadata
 */
- (NSURLRequest *)getContainerMetadataRequest:(RSContainer *)container;

/** Retrieves a container's metadata.
 *  @param container The container to get metadata
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)getContainerMetadata:(RSContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark - CDN Services

#pragma mark CDN Enable Container

/** Returns a request object that represents a request to CDN enable a container 
 *  @param container The container to CDN enable
 */
- (NSURLRequest *)cdnEnableContainerRequest:(RSContainer *)container;

/** CDN enables a container.
 *  @param container The container to CDN enable
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)cdnEnableContainer:(RSContainer *)container success:(void (^)(RSCDNContainer *container))successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark Get CDN Containers

/** Returns a request object that represents a request to retrieve a list of CDN containers in your account */
- (NSURLRequest *)getCDNContainersRequest;

/** Returns a request object that represents a request to retrieve a list of CDN containers in your account 
 *  @param limit The maximum number of containers to return
 *  @param marker Pass a value here to return object names greater than the marker you specify
 */
- (NSURLRequest *)getCDNContainersRequestWithLimit:(NSUInteger)limit marker:(NSString *)marker;

/** Retrieves a list of CDN containers in your account.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)getCDNContainers:(void (^)(NSArray *containers, NSError *jsonError))successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark Get CDN Container Metadata

/** Returns a request object that represents a request to retrieve a CDN container's metadata
 *  @param container The container to get metadata
 */
- (NSURLRequest *)getCDNContainerMetadataRequest:(RSCDNContainer *)container;

/** Retrieves a CDN container's metadata.
 *  @param container The container to retrieve metadata
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)getCDNContainerMetadata:(RSCDNContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark Purge CDN Container

/** Returns a request object that represents a request to purge a container from the CDN
 *  @param container The container to purge
 */
- (NSURLRequest *)purgeCDNContainerRequest:(RSCDNContainer *)container;

/** Returns a request object that represents a request to purge a container from the CDN
 *  @param container The container to purge
 *  @param emailAddresses An array of NSString objects representing email addresses to notify when the container is purged
 */
- (NSURLRequest *)purgeCDNContainerRequest:(RSCDNContainer *)container emailAddresses:(NSArray *)emailAddresses;

/** Purges a CDN container from the CDN.
 *  @param container The container to purge
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)purgeCDNContainer:(RSCDNContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

#pragma mark Update CDN Container

/** Returns a request object that represents a request to update a container.
 *  @param container The container to purge
 */
- (NSURLRequest *)updateCDNContainerRequest:(RSCDNContainer *)container;

/** Updates a CDN container.  You can update TTL, Log Retention settings, and whether or not the container should still be CDN enabled.
 *  @param container The container to update
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)updateCDNContainer:(RSCDNContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

@end
