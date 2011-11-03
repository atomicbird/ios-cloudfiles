//
//  RSClient.m
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/25/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSClient.h"
#import <objc/message.h>

#define $S(format, ...) [NSString stringWithFormat:format, ## __VA_ARGS__]

@implementation RSClient

@synthesize username, apiKey, authURL, authenticated, authToken, storageURL, cdnManagementURL;
@synthesize containerCount, totalBytesUsed;

#pragma mark - Constructors

- (id)initWithProvider:(RSProviderType)provider username:(NSString *)aUsername apiKey:(NSString *)anApiKey {
    
    self = [super init];
    if (self) {
        if (provider == RSProviderTypeRackspaceUS) {
            self.authURL = [NSURL URLWithString:@"https://auth.api.rackspacecloud.com/v1.0"];
        } else if (provider == RSProviderTypeRackspaceUK) {
            self.authURL = [NSURL URLWithString:@"https://lon.auth.api.rackspacecloud.com/v1.0"];
        }
        self.username = aUsername;
        self.apiKey = anApiKey;
    }
    return self;
    
}

- (id)initWithAuthURL:(NSURL *)anAuthURL username:(NSString *)aUsername apiKey:(NSString *)anApiKey {
    
    self = [super init];
    if (self) {
        self.authURL = anAuthURL;
        self.username = aUsername;
        self.apiKey = anApiKey;
    }
    return self;

}


#pragma mark - Common

- (NSMutableURLRequest *)storageRequest:(NSString *)path httpMethod:(NSString *)httpMethod {
    
    NSURL *url = [NSURL URLWithString:$S(@"%@%@", self.storageURL, [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding])];    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:httpMethod];
    [request addValue:self.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
    
}

- (NSMutableURLRequest *)storageRequest:(NSString *)path {
    
    return [self storageRequest:path httpMethod:@"GET"];
    
}

- (NSMutableURLRequest *)cdnRequest:(NSString *)path httpMethod:(NSString *)httpMethod {
    
    NSURL *url = [NSURL URLWithString:$S(@"%@%@", self.cdnManagementURL, [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding])];    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:httpMethod];
    [request addValue:self.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
    
}

- (NSMutableURLRequest *)cdnRequest:(NSString *)path {
    
    return [self cdnRequest:path httpMethod:@"GET"];
    
}

- (void)sendAsynchronousRequest:(SEL)requestSelector object:(id)object sender:(id)sender successHandler:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))successHandler failureHandler:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {

    // if the client hasn't been authenticated yet, this method will attempt to auth first,
    // then send the request.  if auth retry fails, the failureHandler is called
    
    // this method takes a selector instead of an actual NSURLRequest object because if the
    // account isn't authenticated, the request will likely be an invalid URL,
    // such as "NULL/<path>".  after authentication, the selector is called again to create
    // a valid request
    
    if (self.authenticated) {

        // TODO: make sure you're using the appropriate NSOperationQueue
        [NSURLConnection sendAsynchronousRequest:objc_msgSend(sender, requestSelector, object) queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {    

            NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
            
            if (response.statusCode >= 200 && response.statusCode <= 299) {
                if (successHandler) {
                    successHandler(response, data, error);            
                }
            } else {  
                
                if (failureHandler) {
                    failureHandler(response, data, error);
                }
            }
            
        }];
        
    } else {
        
        [self authenticate:^{

            [self sendAsynchronousRequest:requestSelector object:object sender:self successHandler:successHandler failureHandler:failureHandler];
            
        } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
            
            failureHandler(response, data, error);
            
        }];
        
    }
    
}

- (void)sendAsynchronousRequest:(SEL)requestSelector sender:(id)sender successHandler:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))successHandler failureHandler:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:requestSelector object:nil sender:sender successHandler:successHandler failureHandler:failureHandler];
    
}

#pragma mark - Authentication

- (NSURLRequest *)authenticationRequest {

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.authURL];
    [request addValue:self.username forHTTPHeaderField:@"X-Auth-User"];
    [request addValue:self.apiKey forHTTPHeaderField:@"X-Auth-Key"];
    return request;
    
}

- (void)authenticate:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    NSURLRequest *request = [self authenticationRequest];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {    
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
        
        if (response.statusCode >= 200 && response.statusCode <= 299) {            
        
            NSDictionary *headers = [response allHeaderFields];
            self.authToken = [headers objectForKey:@"X-Auth-Token"];
            self.storageURL = [headers objectForKey:@"X-Storage-Url"];
            self.cdnManagementURL = [headers objectForKey:@"X-Cdn-Management-Url"];
            self.authenticated = YES;
            successHandler();
            
        } else {
            
            // let's make a new NSError telling the user auth failed and provide the underlying
            // error.  we're making our own NSError because this code may be called from other
            // methods, so we want to be sure that the user knows that auth failing is why
            // an error occurs
            
            if (error != NULL) {

                NSString *description = $S(@"Authentication Failed for %@ at %@", self.username, self.authURL);
                int errCode = EAUTHFAILURE;
                
                // Make underlying error.
                NSError *underlyingError = [[NSError alloc] initWithDomain:error.domain
                                                                       code:errno userInfo:nil];
                // Make and return custom domain error.
                NSArray *objArray = [NSArray arrayWithObjects:description, underlyingError, nil];
                NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSUnderlyingErrorKey, nil];
                NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
                
                NSError *myError = [[NSError alloc] initWithDomain:RSErrorDomain
                                                       code:errCode userInfo:eDict];
                
                failureHandler(response, data, myError);
                
            } else {
            
                failureHandler(response, data, error);
                
            }
            
        }
        
    }];
    
}

#pragma mark - Get Account Metadata

- (NSURLRequest *)getAccountMetadataRequest {
    
    return [self storageRequest:@"" httpMethod:@"HEAD"];
    
}

- (void)getAccountMetadata:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(getAccountMetadataRequest) sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {

        NSDictionary *headers = [response allHeaderFields];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        self.containerCount = [[formatter numberFromString:[headers objectForKey:@"X-Account-Container-Count"]] unsignedIntegerValue];
        self.totalBytesUsed = [[formatter numberFromString:[headers objectForKey:@"X-Account-Bytes-Used"]] unsignedIntegerValue];
        successHandler();
    
    } failureHandler:failureHandler];
    
}

#pragma mark - Get Containers

- (NSURLRequest *)getContainersRequest {
    
    return [self storageRequest:@"?format=json"];
    
}

- (NSURLRequest *)getContainersRequestWithLimit:(NSUInteger)limit marker:(NSString *)marker {
    
    NSString *path = @"?format=json";
    
    if (limit && marker) {
        path = $S(@"?format=json&limit=%i&marker=%@", limit, marker);
    }
    
    if (limit) {
        path = $S(@"?format=json&marker=%@", [marker stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    }
    
    if (marker) {
        path = $S(@"?format=json&limit=%i", limit);
    }
    
    return [self storageRequest:path];
    
}

- (void)getContainers:(void (^)(NSArray *containers, NSError *jsonError))successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(getContainersRequest) sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        NSError *jsonError = nil;
        NSArray *containerDictionaries = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                
        successHandler([RSContainer arrayFromJSONDictionaries:containerDictionaries parent:self], jsonError);
        
    } failureHandler:failureHandler];
    
}

#pragma mark - Create Container

- (NSURLRequest *)createContainerRequest:(RSContainer *)container {
    
    NSMutableURLRequest *request = [self storageRequest:$S(@"/%@", [container valueForKey:@"name"]) httpMethod:@"PUT"];
    if ([container.metadata count] > 0) {
        
        for (NSString *key in container.metadata) {
            [request addValue:[container.metadata valueForKey:key] forHTTPHeaderField:$S(@"X-Container-Meta-%@", key)];
        }
             
    }
    return request;
    
}

- (void)createContainer:(id)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(createContainerRequest:) object:container sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {        
        successHandler();        
    } failureHandler:failureHandler];
    
}

#pragma mark - Delete Container

- (NSURLRequest *)deleteContainerRequest:(id)container {
    
    return [self storageRequest:$S(@"/%@", [container valueForKey:@"name"]) httpMethod:@"DELETE"];

}

- (void)deleteContainer:(id)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(deleteContainerRequest:) object:container sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {        
        successHandler();        
    } failureHandler:failureHandler];

}

#pragma mark - Get Container Metadata

- (NSURLRequest *)getContainerMetadataRequest:(RSContainer *)container {
    
    return [self storageRequest:$S(@"/%@", [container valueForKey:@"name"]) httpMethod:@"HEAD"];

}

- (void)getContainerMetadata:(RSContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(getContainerMetadataRequest:) object:container sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        NSDictionary *headers = [response allHeaderFields];
        
        for (NSString *key in headers) {
            
            if ([key hasPrefix:@"X-Container-Meta-"]) {
                
                [container.metadata setValue:[headers valueForKey:key] forKey:[key substringFromIndex:17]];
                
            }
        }
        
        successHandler();        
    } failureHandler:failureHandler];
    
}

#pragma mark - Get CDN Containers

- (NSURLRequest *)getCDNContainersRequest {
    
    return [self cdnRequest:@"?format=json"];
    
}

- (NSURLRequest *)getCDNContainersRequestWithLimit:(NSUInteger)limit marker:(NSString *)marker {

    // TODO: DRY this up
    
    NSString *path = @"?format=json&enabled_only=true";
    
    if (limit && marker) {
        path = $S(@"?format=json&enabled_only=true&limit=%i&marker=%@", limit, marker);
    }
    
    if (limit) {
        path = $S(@"?format=json&enabled_only=true&marker=%@", [marker stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    }
    
    if (marker) {
        path = $S(@"?format=json&enabled_only=true&limit=%i", limit);
    }
    
    return [self cdnRequest:path];
    
}

- (void)getCDNContainers:(void (^)(NSArray *containers, NSError *jsonError))successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(getCDNContainersRequest) sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        NSError *jsonError = nil;
        NSArray *containerDictionaries = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        successHandler([RSCDNContainer arrayFromJSONDictionaries:containerDictionaries parent:self], jsonError);
        
    } failureHandler:failureHandler];
    
}

#pragma mark - Get Container Metadata

- (NSURLRequest *)getCDNContainerMetadataRequest:(RSCDNContainer *)container {
    
    return [self storageRequest:$S(@"/%@", [container valueForKey:@"name"]) httpMethod:@"HEAD"];
    
}

- (void)getCDNContainerMetadata:(RSCDNContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(getCDNContainerMetadataRequest:) object:container sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        NSDictionary *headers = [response allHeaderFields];
        
        for (NSString *key in headers) {
            
            if ([key hasPrefix:@"X-Container-Meta-"]) {
                
                [container.metadata setValue:[headers valueForKey:key] forKey:[key substringFromIndex:17]];
                
            }
        }
        
        successHandler();        
    } failureHandler:failureHandler];
    
}

#pragma mark CDN Enable Container

- (NSURLRequest *)cdnEnableContainerRequest:(RSContainer *)container {

    return [self cdnRequest:$S(@"/%@", container.name) httpMethod:@"PUT"];
    
}

- (void)cdnEnableContainer:(RSContainer *)container success:(void (^)(RSCDNContainer *container))successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(cdnEnableContainerRequest:) object:container sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        NSDictionary *headers = [response allHeaderFields];

        RSCDNContainer *cdnContainer = [[RSCDNContainer alloc] init];        
        cdnContainer.name = container.name;
        cdnContainer.ttl = kRSDefaultTTL;
        cdnContainer.cdn_enabled = YES;
        cdnContainer.log_retention = NO;
        cdnContainer.cdn_uri = [headers valueForKey:@"X-CDN-URI"];
        cdnContainer.cdn_ssl_uri = [headers valueForKey:@"X-CDN-SSL-URI"];
        cdnContainer.cdn_streaming_uri = [headers valueForKey:@"X-CDN-STREAMING-URI"];
        
        successHandler(cdnContainer);
        
    } failureHandler:failureHandler];
    
}

#pragma mark Update CDN Container (5.2.4)

- (NSURLRequest *)updateCDNContainerRequest:(RSCDNContainer *)container {
    
    NSMutableURLRequest *request = [self cdnRequest:$S(@"/%@", container.name) httpMethod:@"POST"];
    
    [request addValue:$S(@"%i", container.ttl) forHTTPHeaderField:@"X-TTL"];
    [request addValue:container.cdn_enabled ? @"True": @"False" forHTTPHeaderField:@"X-CDN-Enabled"];
    [request addValue:container.log_retention ? @"True": @"False" forHTTPHeaderField:@"X-Log-Retention"];
    
    return request;
    
}

- (void)updateCDNContainer:(RSCDNContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(cdnEnableContainerRequest:) object:container sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        successHandler();        
    } failureHandler:failureHandler];

}

#pragma mark Purge CDN Container (5.2.3)

- (NSURLRequest *)purgeCDNContainerRequest:(RSCDNContainer *)container {
    
    return [self cdnRequest:$S(@"/%@", container.name) httpMethod:@"DELETE"];
    
}

- (NSURLRequest *)purgeCDNContainerRequest:(RSCDNContainer *)container emailAddresses:(NSArray *)emailAddresses {
    
    NSMutableURLRequest *request = [self cdnRequest:$S(@"/%@", container.name) httpMethod:@"DELETE"];
    [request addValue:[emailAddresses componentsJoinedByString:@", "] forHTTPHeaderField:@"X-Purge-Email"];
    return request;
    
}

- (void)purgeCDNContainer:(RSCDNContainer *)container success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self sendAsynchronousRequest:@selector(purgeCDNContainerRequest:) object:container sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        successHandler();        
    } failureHandler:failureHandler];
    
}


@end
