//
//  NSManagedObjectContext+Utils.h
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Utils)

+ (NSManagedObjectContext *)parentManagedObjectContext;
+ (NSManagedObjectContext *)childUIManagedObjectContext;
+ (NSManagedObjectContext *)tempManagedObjectContext;

- (void)savePropagate;
- (void)savePropagateWait;

- (NSArray *)fetchObjectsForEntityName:(NSString *)name withPredicate:(id)stringOrPredicate, ...;



@end
