//
//  CertifiedRating.h
//  Myplex
//
//  Created by Igor Ostriz on 15/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface CertifiedRating : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * rating;
@property (nonatomic, retain) Content *owner;

@end
