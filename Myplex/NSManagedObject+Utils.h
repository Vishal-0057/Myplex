//
//  ModelUtils.h
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RemoteKeySanitizer <NSObject>

- (NSString*)sanitizeRemoteKey: (NSString*)key;
- (NSDictionary*)sanitizeRemoteKeys: (NSDictionary*)remoteKeys;

@end

@interface NSManagedObject (Utils)

+ (id)createNewInManagedObjectContext:(NSManagedObjectContext *) managedObjecContext;
+ (id)modelFromJSONData:(id)jsonData forEntityName:(NSString*)entityName inContext:(NSManagedObjectContext*)moc keySanitizer:(id <RemoteKeySanitizer>)sanitizer;
+ (NSManagedObject*)updateOrCreateFromJSONData:(NSDictionary*)jsonData inContext:(NSManagedObjectContext*)moc;
+ (NSManagedObject*)updateOrCreateFromJSONData:(NSDictionary*)jsonData inContext:(NSManagedObjectContext*)moc uniqueSanitizedKey:(NSString *)unique save:(BOOL)save;
+ (id)fetchFirstObjectHaving:(id)obj forKey:(NSString *)key inManagedObjectContext:(NSManagedObjectContext *)moc;

- (void)updateFromJSONData:(id)jsonData inContext:(NSManagedObjectContext*)moc keySanitizer:(id <RemoteKeySanitizer>)sanitizer;
- (BOOL)validateForInsertOrUpdate:(NSError **)error;
- (BOOL)isNew;


//  Subclasses that use this category MUST override entityName.
+ (NSString*)entityName;
+ (NSManagedObject*)fetchByRemoteId:(NSString*)remoteId context:(NSManagedObjectContext*)moc;

+ (id <RemoteKeySanitizer>)keySanitizer;


- (void)assign:(id)obj forKey:(id)key;

@end
