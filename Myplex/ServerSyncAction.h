//
//  ServerSyncAction.h
//  Myplex
//
//  Created by Igor Ostriz on 8/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerSyncAction <NSObject>

- (void)performSyncSinceDate: (NSDate*)lastSyncDate completionHandler: (void (^)(NSDictionary*, NSError*))block;
- (NSDictionary*)remoteKeyMappings;
- (NSDictionary*)remoteKeyTransforms;

@optional

- (void)performPostSyncActions: (NSManagedObjectContext*)context;

@end
