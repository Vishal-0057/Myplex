//
//  NSManagedObjectContext+Utils.m
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "AppDelegate.h"
#import "NSError+Utils.h"
#import "NSManagedObjectContext+Utils.h"

@implementation NSManagedObjectContext (Utils)

+ (NSManagedObjectContext *)parentManagedObjectContext
{
    return [((AppDelegate *)[UIApplication sharedApplication].delegate) managedObjectContext];
}

+ (NSManagedObjectContext *)childUIManagedObjectContext
{
    static NSManagedObjectContext *_moc = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _moc.parentContext = [self parentManagedObjectContext];
    });
    return _moc;
//    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    moc.parentContext = [self parentManagedObjectContext];
//    return moc;
}

+ (NSManagedObjectContext *)tempManagedObjectContext
{
//    static NSManagedObjectContext *_moc = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        _moc.parentContext = [self childUIManagedObjectContext];
//    });
//    return _moc;

    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    moc.parentContext = [self parentManagedObjectContext];
    moc.parentContext = [self childUIManagedObjectContext];
    return moc;
}


- (void)savePropagate
{
    [self performBlock:^{
        NSError *error = nil;
        if ([self save:&error]) {
            [self.parentContext savePropagate];
        }
        else
            [error logDetailedError];
    }];
}

- (void)savePropagateWait
{
    [self performBlockAndWait:^{
        NSError *error = nil;
        if ([self save:&error]) {
            [self.parentContext savePropagateWait];
        }
        else
            [error logDetailedError];
    }];
}



- (NSArray *)fetchObjectsForEntityName:(NSString *)name withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:self];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.returnsObjectsAsFaults = NO;
    [request setEntity:entity];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]], @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), [stringOrPredicate name]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", error.localizedDescription];
    }
    
    return results;
}
@end
