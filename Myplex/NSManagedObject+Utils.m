//
//  ModelUtils.m
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//


#import "NSDate+ServerDateFormat.h"
#import "NSManagedObject+Utils.h"
#import "NSString+MakeCamelCase.h"
#import "StandardKeySanitizer.h"

@implementation NSManagedObject (Utils)

+ (id <RemoteKeySanitizer>)keySanitizer
{
	return [StandardKeySanitizer keySanitizer];
}

+ (NSString*)entityName
{
	return NSStringFromClass([self class]);
}

+ (id)modelFromJSONData:(id)jsonData forEntityName:(NSString*)entityName inContext:(NSManagedObjectContext*)moc keySanitizer:(id <RemoteKeySanitizer>)sanitizer
{
	NSManagedObject* theObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
	
	[theObject updateFromJSONData:jsonData inContext:moc keySanitizer:sanitizer];
	
	return theObject;
}


+ (id)createNewInManagedObjectContext:(NSManagedObjectContext *) managedObjecContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:managedObjecContext];
}

+ (id)fetchFirstObjectHaving:(id)obj forKey:(NSString *)key inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSString* entityName = [self entityName];
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
	fetchRequest.returnsObjectsAsFaults = NO;
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, obj];

    NSManagedObject *rvobj = nil;
	NSError* error = nil;
	NSArray* fetchedItems = [moc executeFetchRequest:fetchRequest error:&error];
	if ([fetchedItems count] > 0) {
        rvobj = fetchedItems[0];
    }
    else {
		NSLog(@"Error fetching entity of type %@, error = %@", entityName, error);
    }

    return rvobj;
}

- (BOOL)isNew
{
    NSDictionary *vals = [self committedValuesForKeys:nil];
    return [vals count] == 0;
}

- (BOOL)validateForInsertOrUpdate:(NSError **)error
{
    if ([self isNew]) {
        return [self validateForInsert:error];
    }
    return [self validateForUpdate:error];
}

//- (void)updateRelationship:(NSString *)entity fromJSONData:(id)jsonData inContext:(NSManagedObjectContext *)moc
//{
//    NSDictionary* entityAttributes = self.entity.attributesByName;
//	NSDictionary* relationships = self.entity.relationshipsByName;
//    
//	NSDictionary* jsonDict = (NSDictionary*)jsonData;
//	[jsonDict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
//        NSString* sanitizedKey = [[[self class] keySanitizer] sanitizeRemoteKey:key];
//        
//        
//        
//    }];
//    
//}

- (void)updateFromJSONData:(id)jsonData inContext:(NSManagedObjectContext*)moc keySanitizer:(id <RemoteKeySanitizer>)sanitizer
{
	NSDictionary* entityAttributes = self.entity.attributesByName;
	NSDictionary* relationships = self.entity.relationshipsByName;
	
	NSDictionary* jsonDict = (NSDictionary*)jsonData;
    
    if ([jsonDict isKindOfClass:[NSDictionary class]]) {
        [jsonDict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            
            NSString* sanitizedKey = sanitizer ? [sanitizer sanitizeRemoteKey:key] : key;
            
            NSAttributeDescription* attributeDescription = [entityAttributes objectForKey:sanitizedKey];
            NSRelationshipDescription* relationshipDescription = [relationships objectForKey:sanitizedKey];
            
            //  Ignore attributes that are not present in the model's entity description.
            if (attributeDescription) {
                [self assign:obj forKey:sanitizedKey];
            } else if(relationshipDescription) {
                if (relationshipDescription.isToMany) {
                    
                    NSArray* theArray;
                    if ([obj isKindOfClass:[NSArray class]]) {
                        theArray = (NSArray*)obj;
                    }
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        theArray = obj[@"values"];
                    }
                    if ([theArray isEqual:[NSNull null]]) {
                        theArray = @[];
                    }
                    
                    NSMutableSet* relationshipTargets = [NSMutableSet setWithCapacity:theArray.count];
                    NSString* entityName = relationshipDescription.destinationEntity.name;
                    
                    [theArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSManagedObject* target = nil;
                        
                        //  Handle simple string relationships as a convenience.  Anything more complicated cannot be handled at this level.
                        if( [obj isKindOfClass:[NSString class]]) {
                            //  A simple string type
                            //  TODO: speed up this lookup.
                            
                            NSString* attributeName = [[relationshipDescription.destinationEntity.attributesByName allKeys] objectAtIndex:0];
                            
                            //  Do not duplicate entries for one-string entity types.
                            
                            NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
                            NSString* predicateString = [NSString stringWithFormat:@"%@ = \"%@\"", attributeName, obj];
                            NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
                            fetchRequest.predicate = predicate;
                            
                            NSError* error;
                            NSArray* fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
                            if (!fetchedObjects) {
                                NSLog(@"%@", error);
                            } else if ([fetchedObjects count] == 0) {
                                //obj = @{ attributeName: obj }; //commenting because "Valued stored to 'obj' is never read.
                            } else {
                                target = fetchedObjects[0];
                            }
                        }
                        //                    else {
                        //                        // try to fetch recursivly
                        //                        // if target has remoteId, try to update it, else remove data and replace with new
                        //                        NSDictionary *targetAttr = relationshipDescription.destinationEntity.attributesByName;
                        //                        if (targetAttr[@"remoteId"]) {
                        //                            // update
                        //                            target = [NSClassFromString(relationshipDescription.destinationEntity.name) updateOrCreateFromJSONData:obj inContext:moc save:FALSE];
                        //                        }
                        //                        else {
                        //                            // create new, but first erase all existing
                        //                            target = [NSManagedObject modelFromJSONData:obj forEntityName:relationshipDescription.destinationEntity.name inContext:moc keySanitizer:sanitizer];
                        //                        }
                        //                    }
                        
                        if (target) {
                            [relationshipTargets addObject:target];
                        }
                    }];
                    
                    [self setValue:relationshipTargets forKey:sanitizedKey];
                }
            }
        }];
    }
}

+ (NSManagedObject*)updateOrCreateFromJSONData:(NSDictionary*)jsonData inContext:(NSManagedObjectContext*)moc
{
    return [self updateOrCreateFromJSONData:jsonData inContext:moc uniqueSanitizedKey:@"remoteId" save:TRUE];
}

+ (NSManagedObject*)updateOrCreateFromJSONData:(NSDictionary*)jsonData inContext:(NSManagedObjectContext*)moc uniqueSanitizedKey:(NSString *)uniqueKey save:(BOOL)save
{
	NSDictionary* sanitizedData = [[self keySanitizer] sanitizeRemoteKeys:jsonData];
	NSString* remoteId = [sanitizedData objectForKey:uniqueKey];
	NSString* entityName = [self entityName];
	
	//  TODO: perhaps refactor and query in batches for efficiency.
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
	fetchRequest.returnsObjectsAsFaults = NO;
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueKey, remoteId];
	
    NSManagedObject *obj = nil;
	NSError* error = nil;
	NSArray* fetchedItems = [moc executeFetchRequest:fetchRequest error:&error];
	if (!fetchedItems) {
		NSLog(@"Error fetching entity of type %@, error = %@", entityName, error);
		return nil;
	} else {
		if ([fetchedItems count] == 0) {
			obj = [self modelFromJSONData:jsonData forEntityName:entityName inContext:moc keySanitizer:[self keySanitizer]];
			[moc insertObject:obj];
		}
		else {
			//  Assume unique remoteIds
			obj = [fetchedItems objectAtIndex:0];
			[obj updateFromJSONData:jsonData inContext:moc keySanitizer:[self keySanitizer]];
		}
	}
	
    if (save) {
        BOOL didSave = [moc save:&error];
        if (!didSave) {
            NSLog(@"Error saving entity of type %@, error = %@", entityName, error);
            return nil;
        }
    }
    return obj;
}

+ (NSManagedObject*)fetchByRemoteId:(NSString*)remoteId context:(NSManagedObjectContext*)moc
{
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteId = %@", remoteId];
	
	NSError* error;
	NSArray* objects = [moc executeFetchRequest:fetchRequest error:&error];
	if (!objects) {
		NSLog(@"%@", error);
		return nil;
	} else {
		return objects.count ? objects[0] : nil;
	}
}

- (void)assign:(id)obj forKey:(id)key
{
    NSAttributeDescription *desc = self.entity.attributesByName[key];
    
    // convert number to string
    if (desc.attributeType == NSStringAttributeType && [obj isKindOfClass:[NSNumber class]]) {
        obj = [obj stringValue];
    }
    
    // convert string to date
    if (desc.attributeType == NSDateAttributeType   && [obj isKindOfClass:[NSString class]]) {
        obj = [NSDate formatStringToDate:obj];
    }
    
    // null case
    if (obj == [NSNull null]) {
        obj = nil;
    }
    
    // simple array case
    if ([obj isKindOfClass:[NSArray class]]) {
        obj = (NSArray *)obj;
        obj = [obj componentsJoinedByString:@","];
    }
    
    if ([obj isKindOfClass:[NSString class]] && desc.attributeType != NSStringAttributeType) {
        NSLog(@"unexpected attribute");
        return;
    }
    [self setValue:obj forKey:key];
}


@end

