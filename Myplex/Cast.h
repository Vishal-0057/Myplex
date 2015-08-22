//
//  Cast.h
//  Myplex
//
//  Created by shiva on 2/1/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface Cast : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSData * content;
@property (nonatomic, retain) NSDate * dob;
@property (nonatomic, retain) NSDate * dod;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *owners;
@end

@interface Cast (CoreDataGeneratedAccessors)

- (void)addOwnersObject:(Content *)value;
- (void)removeOwnersObject:(Content *)value;
- (void)addOwners:(NSSet *)values;
- (void)removeOwners:(NSSet *)values;

@end
