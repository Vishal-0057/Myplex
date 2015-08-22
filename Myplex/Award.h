//
//  Award.h
//  Myplex
//
//  Created by Igor Ostriz on 31/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface Award : NSManagedObject

@property (nonatomic, retain) NSDate * awardDate;
@property (nonatomic, retain) NSString * baseDescription;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) Content *owner;

@end
