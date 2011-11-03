//
//  RSModel.h
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/26/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSClient;

@interface RSModel : NSObject

@property (nonatomic, strong) id parent;
@property (readonly) RSClient *client;

- (RSClient *)client;
- (id)initWithJSONDictionary:(NSDictionary *)jsonDict;
+ (NSArray *)arrayFromJSONDictionaries:(NSArray *)jsonDictionaries parent:(id)parent;

@end
