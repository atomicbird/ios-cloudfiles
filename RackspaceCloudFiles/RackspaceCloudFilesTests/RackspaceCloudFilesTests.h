//
//  RackspaceCloudFilesTests.h
//  RackspaceCloudFilesTests
//
//  Created by Mike Mayo on 11/1/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class RSClient, RSContainer, RSCDNContainer, RSStorageObject;

@interface RackspaceCloudFilesTests : SenTestCase

@property (nonatomic, strong) RSClient *client;
@property (nonatomic, strong) RSContainer *container;
@property (nonatomic, strong) RSStorageObject *object;
@property (nonatomic) BOOL waiting;
@property (nonatomic, strong) NSString *timeoutFailureString;

@end
