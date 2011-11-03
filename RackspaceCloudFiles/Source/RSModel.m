//
//  RSModel.m
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/26/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSModel.h"
#import "RSClient.h"

@implementation RSModel

@synthesize parent;

#pragma mark - JSON

- (RSClient *)client {
    id client = self.parent;
    
    while (client && ![client isKindOfClass:[RSClient class]]) {
        client = [client performSelector:@selector(parent)];
    }

    return client;
}

- (id)initWithJSONDictionary:(NSDictionary *)jsonDict {
    if (self = [self init]) {
        [self setValuesForKeysWithDictionary:jsonDict];
    }
    return self;
}

+ (NSArray *)arrayFromJSONDictionaries:(NSArray *)jsonDictionaries parent:(id)parent {

    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[jsonDictionaries count]];
    for (NSDictionary *dict in jsonDictionaries) {
        
        id object = [[[self class] alloc] initWithJSONDictionary:dict];
        [object performSelector:@selector(setParent:) withObject:parent];        
        [array addObject:object];

    }
    
    return [NSArray arrayWithArray:array];
    
}

#pragma mark - HTTP



#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: parent: %@", [super description], self.parent];
}

@end
