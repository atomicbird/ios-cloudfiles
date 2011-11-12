//
//  RSContainer.m
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/25/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSContainer.h"
#import "RSClient.h"
#import "RSStorageObject.h"

#define $S(format, ...) [NSString stringWithFormat:format, ## __VA_ARGS__]

@implementation RSContainer

@synthesize bytes, count, name, metadata;

- (id)init {
    self = [super init];
    if (self) {
        self.metadata = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Get Objects

- (NSURLRequest *)getObjectsRequest {
    
    return [self.client storageRequest:$S(@"/%@?format=json", self.name)];
    
}

//limit: For an integer value n, limits the number of results to at most n values. marker Given a string value x, return object names greater in value than the specified marker.
//prefix: For a string value x, causes the results to be limited to object names beginning with the substring x.
//path: For a string value x, return the object names nested in the pseudo path (assuming preconditions are met - see below).
//delimiter: For a character c, return all the object names nested in the container (without the need for the directory marker objects).
- (NSURLRequest *)getObjectsRequest:(NSDictionary *)params {

    NSMutableString *paramString = [[NSMutableString alloc] initWithString:@"?format=json"];
    
    for (NSString *key in params) {
        
        [paramString appendFormat:@"%@=%@", key, [params valueForKey:key]];
        
    }
    
    NSMutableURLRequest *request = [self.client storageRequest:$S(@"/%@%@", self.name, paramString)];
    return request;
}

- (void)getObjects:(void (^)(NSArray *objects, NSError *jsonError))successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self.client sendAsynchronousRequest:@selector(getObjectsRequest) sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        NSError *jsonError = nil;
        NSArray *dictionaries = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if (successHandler) {
            successHandler([RSStorageObject arrayFromJSONDictionaries:dictionaries parent:self], jsonError);
        }
        
    } failureHandler:failureHandler];
    
}

- (NSURLRequest *)uploadObjectRequest:(RSStorageObject *)object {
    
    NSMutableURLRequest *request = [self.client storageRequest:$S(@"/%@/%@", self.name, object.name) httpMethod:@"PUT"];
    
    for (NSString *key in object.metadata) {
        [request addValue:[object.metadata valueForKey:key] forHTTPHeaderField:$S(@"X-Object-Meta-", key)];
    }
    [request addValue:$S(@"%i", [object.data length]) forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:object.data];
        
    return request;
}

- (void)uploadObject:(RSStorageObject *)object success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self.client sendAsynchronousRequest:@selector(uploadObjectRequest:) object:object sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        object.etag = [[response allHeaderFields] valueForKey:@"ETag"];        
        object.parent = self;

        if (successHandler) {
            successHandler();
        }
        
    } failureHandler:failureHandler];
    
}

- (void)uploadObject:(RSStorageObject *)object fromFile:(NSString *)path success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    object.data = [NSData dataWithContentsOfFile:path];
    [self uploadObject:object success:successHandler failure:failureHandler];
    
}

- (NSURLRequest *)deleteObjectRequest:(RSStorageObject *)object {

    return [self.client storageRequest:$S(@"/%@/%@", self.name, object.name) httpMethod:@"DELETE"];
    
}

- (void)deleteObject:(RSStorageObject *)object success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self.client sendAsynchronousRequest:@selector(deleteObjectRequest:) object:object sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {        
        if (successHandler) {
            successHandler();        
        }
    } failureHandler:failureHandler];
    
}


@end
