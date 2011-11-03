//
//  RSContainer.h
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/25/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSModel.h"

@class RSStorageObject;

/** The RSContainer class represents a container in your Cloud Files account.  
 *  A container is a storage compartment for your data and provides a way for you
 *  to organize your data.  You can think of a container as a folder, but unlike a folder,
 *  it cannot be nested.
 *
 *  Files stored in your account must be stored in a container.
 */
@interface RSContainer : RSModel

/** The number of bytes used in the container */
@property (nonatomic) NSUInteger bytes;

/** The number of files stored in the container */
@property (nonatomic) NSUInteger count;

/** The name of the container */
@property (nonatomic, strong) NSString *name;

/** Optional metadata associated with the container.  Keys and values for the metadata
 *  are strings.
 */
@property (nonatomic, strong) NSMutableDictionary *metadata;

#pragma mark Get Objects

/** Returns a request object that represents a request to retrieve a list of objects in the container */
- (NSURLRequest *)getObjectsRequest;

/** Returns a request object that represents a request to retrieve a list of objects in the container.
 *
 *  Possible parameters:
 *
 *  limit: For an integer value n, limits the number of results to at most n values. marker Given a string value x, return object names greater in value than the specified marker.
 *
 *  prefix: For a string value x, causes the results to be limited to object names beginning with the substring x.
 *
 *  path: For a string value x, return the object names nested in the pseudo path (assuming preconditions are met - see below).
 *
 *  delimiter: For a character c, return all the object names nested in the container (without the need for the directory marker objects).
 *  @param params Request parameters
 */
- (NSURLRequest *)getObjectsRequest:(NSDictionary *)params;

/** Retrieves a list of objects in the container.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)getObjects:(void (^)(NSArray *objects, NSError *jsonError))successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

/** Returns a request object that represents a request to upload a file into the container 
 *  @param object The file to upload
 */
- (NSURLRequest *)uploadObjectRequest:(RSStorageObject *)object;

/** Uploads a file into the container.
 *  @param object The file to upload
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)uploadObject:(RSStorageObject *)object success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

/** Uploads a file into the container from the local filesystem.
 *  @param object The file to upload
 *  @param path The path for the file's data on the local filesystem
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)uploadObject:(RSStorageObject *)object fromFile:(NSString *)path success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

/** Returns a request object that represents a request to delete a file in the container 
 *  @param object The file to delete
 */
- (NSURLRequest *)deleteObjectRequest:(RSStorageObject *)object;

/** Deletes a file in the container.
 *  @param object The file to delete
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)deleteObject:(RSStorageObject *)object success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

@end
