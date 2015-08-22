//
//  Tag.h
//  Myplex
//
//  Created by Igor Ostriz on 31/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * qualifier;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) Content *owner;

@end
