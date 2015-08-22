//
//  CacheManager.h
//  Myplex
//
//  Created by Igor Ostriz on 8/16/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc;

// returns total cache size
- (NSInteger)getTotalSize;
// returns free disk space
+ (uint64_t)getFreeSpace;


- (void)cleanupCacheIfBiggerThan:(NSInteger)maxSize reduceBy:(NSInteger)percentage;



@end
