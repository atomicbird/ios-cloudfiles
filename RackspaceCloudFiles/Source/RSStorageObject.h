//
//  RSStorageObject.h
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/27/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSModel.h"

/** The RSStorageObject class represents an object in a container.  An object is the basic
 *  storage entity and any optional metadata that represents the files you store in the
 *  Cloud Files system.
 *
 *  Cloud Files has a limit on the size of a single uploaded object; by default this is 5 GB.
 *  To upload files larger than 5 GB, you must upload it in segments.  More information on how
 *  to do this is available at http://docs.rackspace.com
 */
@interface RSStorageObject : RSModel

/** The name of the file */
@property (nonatomic, strong) NSString *name;

/** MD5 checksum of the object's data */
@property (nonatomic, strong) NSString *hash;

/** The number of bytes in the file */
@property (nonatomic) NSUInteger bytes;

/** The content type of the file.  Example: text/plain */
@property (nonatomic, strong) NSString *content_type;

/** The last modified date string returned in the API */
@property (nonatomic, strong) NSString *last_modified;

/** The last modified date of the file */
@property (nonatomic, readonly) NSDate *last_modified_date;

/** Optional metadata associated with the container.  Keys and values for the metadata
 *  are strings.
 */
@property (nonatomic, strong) NSMutableDictionary *metadata;

/** MD5 checksum of the object's data.  Returned only when getting object data. */
@property (nonatomic, strong) NSString *etag;

/** The contents of the file */
@property (nonatomic, strong) NSData *data;

/** Returns a request object that represents a request to retrieve a file's data */
- (NSURLRequest *)getObjectDataRequest;

/** Retrieves an object's data.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)getObjectData:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

/** Writes an object's data to a file on the local filesystem.
 *  @param path The path on the local filesystem
 *  @param atomically If `YES`, the data is written to a backup file, and then—assuming no errors occur—the backup file is renamed to the name specified by path; otherwise, the data is written directly to path.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)writeObjectDataToFile:(NSString *)path atomically:(BOOL)atomically success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

/** Returns a request object that represents a request to retrieve an object's metadata */
- (NSURLRequest *)getObjectMetadataRequest;

/** Retrieves the object's metadata.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)getMetadata:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

/** Returns a request object that represents a request to update an object's metadata */
- (NSURLRequest *)updateMetadataRequest;

/** Updates the object's metadata.
 *  @param successHandler Executes if successful
 *  @param failureHandler Executes if not successful
 */
- (void)updateMetadata:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler;

@end
