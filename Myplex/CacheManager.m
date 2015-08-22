//
//  CacheManager.m
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheManager.h"
#import "NSManagedObject+Utils.h"

@implementation CacheManager
{
    NSManagedObjectContext *_managedObjectContext;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
 	self = [super init];
	if (self) {
		_managedObjectContext = moc;
	}
	
	return self;
}

- (NSInteger)getTotalSize
{
    NSArray *allStores = [_managedObjectContext.persistentStoreCoordinator persistentStores];
    unsigned long long totalBytes = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSPersistentStore *store in allStores) {
        if (![store.URL isFileURL]) continue; // only file URLs are compatible with NSFileManager
        NSString *path = [[store URL] path];
        NSLog(@"persistent store path: %@",path);
        // NSDictionary has a category to assist with NSFileManager attributes
        totalBytes += [[fileManager attributesOfItemAtPath:path error:NULL] fileSize];
    }
    
    return totalBytes;
}

+ (uint64_t)getFreeSpace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

- (void)cleanupCacheIfBiggerThan:(NSInteger)maxSize reduceBy:(NSInteger)percentage
{
    // check for master constraint
    if ([self getTotalSize] < maxSize) {
        return;
    }
    
    NSInteger thresholdA = maxSize;
    NSInteger thresholdB = thresholdA * (1.- percentage/100.);
    
    // first naive implementation of a cache cleanup mechanism
    while ([self getTotalSize] > thresholdB) {
        // reduce biggest size contributor
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:nil];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];

        //NSEntityDescription *entity = [NSEntityDescription entityForName:[Content entityName] inManagedObjectContext:_managedObjectContext];
        NSFetchRequest *request = [NSFetchRequest new];
        //[request setEntity:entity];
        [request setPredicate:predicate];
        [request setSortDescriptors:@[descriptor]];
        [request setFetchLimit:10];

        NSError *error;
        NSArray *content = [_managedObjectContext executeFetchRequest:request error:&error];
        if (content && content.count) {
            
//            for (Content *c in content) {
//                // TODO: for each content delete local cache files first
//
//            
//                // now eliminate object from cache
//                [_managedObjectContext deleteObject:c];
//                
//                // all related objects that refer to object should be updated/deleted
//            }
            
            [_managedObjectContext save:&error];
            if (error) {
                NSLog(@"Error deleting content: %@", error.localizedDescription);
            }
        }
    }
}


@end
