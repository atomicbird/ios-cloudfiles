//
//  RackspaceCloudFilesTests.m
//  RackspaceCloudFilesTests
//
//  Created by Mike Mayo on 11/1/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RackspaceCloudFilesTests.h"
#import "RSClient.h"

@implementation RackspaceCloudFilesTests

@synthesize client, container, object, waiting, timeoutFailureString;

#pragma mark - Utilities

- (void)waitForTestCompletion {
    self.waiting = YES;
	
	NSTimeInterval startTime = [[NSDate date] timeIntervalSinceReferenceDate];
	while (self.waiting) {		
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
		
		// Don't let the download take longer than we're allowed
		NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceReferenceDate] - startTime;
		if (elapsedTime > (30.0)) {
			NSString* failContext = timeoutFailureString;
			if (failContext == nil) {
				failContext = @"Timed out trying to perform test.";
			}
			NSString* testFailString = [NSString stringWithFormat:@"%@ %@", failContext, @"DCJ - Get more info about the running test in here?"];
            STFail(testFailString);
			self.waiting = NO;
			break;
		}
	}
}

- (void)stopWaiting {
    self.waiting = NO;
}

- (void)createContainer:(void (^)(RSContainer *))successHandler {
    
    RSContainer *c = [[RSContainer alloc] init];
    c.name = @"RSCloudFilesSDK-Test";
    
    [self.client createContainer:c success:^{
        successHandler(c);
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Create container failed.");
    }];    
}

- (void)loadContainer:(void (^)())successHandler {
    
    [self.client getContainers:^(NSArray *containers, NSError *jsonError) {
        
        for (RSContainer *c in containers) {
            
            if ([c.name isEqualToString:@"RSCloudFilesSDK-Test"]) {
                self.container = c;
                successHandler();
            }
            
        }
        
        STAssertNotNil(self.container, @"Loading container failed.");
        
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Load container failed.");
    }];
    
}

- (void)deleteContainer:(void (^)())successHandler {
    
    [self.client deleteContainer:self.container success:^{
        [self stopWaiting];
        successHandler();
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {        
        [self stopWaiting];
        STFail(@"delete container failed");
    }];    
}

- (void)createObject:(void (^)(RSStorageObject *))successHandler {
    
    RSStorageObject *o = [[RSStorageObject alloc] init];
    o.name = @"test.txt";
    o.content_type = @"text/plain";    
    o.data = [@"This is a test." dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.container uploadObject:o success:^{
        self.object = o;
        successHandler(o);
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Create object failed.");
    }];
    
}

- (void)deleteObject:(void (^)())successHandler {
    
    [self.container deleteObject:self.object success:^{
        successHandler();
    }failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"delete object failed");
    }];    
    
}

- (void)cdnEnableContainer:(void (^)(RSCDNContainer *))successHandler {
    
    [self.client cdnEnableContainer:self.container success:^(RSCDNContainer *cdnContainer) { 
        successHandler(cdnContainer);
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"CDN enable container failed.");
    }];
    
}

#pragma mark - Test Setup

// setUp and tearDown are called with each individual test

- (void)setUp {
        
    [super setUp];    
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"RackspaceCloudFilesTests" ofType:@"plist"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSURL *url = [NSURL URLWithString:[settings valueForKey:@"auth_url"]];
    NSString *username = [settings valueForKey:@"username"];
    NSString *apiKey = [settings valueForKey:@"api_key"];
    
    self.client = [[RSClient alloc] initWithAuthURL:url username:username apiKey:apiKey];
    
    [self createContainer:^(RSContainer *c) {
        [self loadContainer:^{        
            [self createObject:^(RSStorageObject *o) {
                [self stopWaiting];
                self.object = o;
            }];
        }];
    }];
    
    [self waitForTestCompletion];
    
}

- (void)tearDown {
    
    [self waitForTestCompletion];    
    
    [self deleteObject:^{
        
        [self deleteContainer:^{
            
            [self stopWaiting];
            
        }];
        
    }];
    
    [self waitForTestCompletion];    
    [super tearDown];
    
}

#pragma mark - Tests

- (void)testAuthentication {
    
    [self.client authenticate:^{
        [self stopWaiting];
        STAssertNotNil(self.client.authToken, @"Client should have an auth token");
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Authentication failed.");
    }];
    
}

- (void)testGetAccountMetadata {
    
    [self.client getAccountMetadata:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Get Account Metadata failed.");
    }];
    
}

- (void)testGetContainers {
    
    [self.client getContainers:^(NSArray *containers, NSError *jsonError) {
        [self stopWaiting];
        STAssertNotNil(containers, @"getContainers should return an array");
        STAssertNil(jsonError, @"getContainers should not return a JSON error");
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Get Containers failed.");
    }];
    
}

- (void)testGetContainerMetadata {
    
    [self.client getContainerMetadata:self.container success:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Get container metadata failed.");            
    }];
    
}

- (void)testPurgeCDNContainer {
    
    [self cdnEnableContainer:^(RSCDNContainer *cdnContainer) {
        
        [self.client purgeCDNContainer:cdnContainer success:^{
            
            [self stopWaiting];
            
        } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
            [self stopWaiting];
            
            NSDictionary *headers = [response allHeaderFields];
            
            // you can only purge once every 3600 seconds, so if you get a
            // X-Purge-Failed-Reason header, that's an acceptable failure
            if (![headers valueForKey:@"X-Purge-Failed-Reason"]) {
                
                STFail(@"Purge CDN container failed. Response code: %i - %@", [response statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);  
                
            }
            
        }];
        
    }];
    
}

- (void)testUpdateCDNContainer {
    
    [self cdnEnableContainer:^(RSCDNContainer *cdnContainer) {
        
        cdnContainer.ttl = 1000;
        
        [self.client updateCDNContainer:cdnContainer success:^{
            
            [self stopWaiting];
            
        } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
            [self stopWaiting];
            STFail(@"Update CDN container failed. Response code: %i - %@", [response statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);  
        }];
        
    }];
    
}

- (void)testGetObjects {
    
    [self.container getObjects:^(NSArray *objects, NSError *jsonError) {
        
        [self stopWaiting];
        STAssertNotNil(objects, @"getObjects should return an array");
        STAssertNil(jsonError, @"getObjects should not return a JSON error");
        
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Get objects failed");
    }];
    
}


- (void)testGetObjectData {
    
    self.object.data = nil; // clear out the data to make sure we're getting it from the API
    
    [self.object getObjectData:^{
        
        [self stopWaiting];
        STAssertNotNil(object.data, @"object data should not be nil");
        
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        [self stopWaiting];
        STFail(@"get object data failed");
        
    }];
    
}

- (void)testGetObjectMetadata {
    
    self.object.metadata = [[NSMutableDictionary alloc] initWithCapacity:1];
    [self.object.metadata setValue:@"Mike" forKey:@"Name"];
    
    [self.object updateMetadata:^{
        
        // let's clear it out, and then get it to make sure it comes back from the API                
        [self.object.metadata removeAllObjects];
        
        [self.object getMetadata:^{
            
            [self stopWaiting];
            STAssertEqualObjects([self.object.metadata valueForKey:@"Name"], @"Mike", @"Object metadata should be set");            
            
        } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
            [self stopWaiting];
            STFail(@"get object metadata failed");
        }];
        
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"update object metadata failed: %i", [response statusCode]);
    }];
    
}

- (void)testUpdateObjectMetadata {
    
    [self.object.metadata setValue:@"Mike" forKey:@"Name"];
    
    [self.object updateMetadata:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"update object metadata failed");
    }];
    
}

- (void)testCDNEnableContainer {
    
    [self cdnEnableContainer:^(RSCDNContainer *cdnContainer) { 
        [self stopWaiting];
        STAssertNotNil(cdnContainer, @"CDN container should not be nil.");
    }];
    
}

@end
