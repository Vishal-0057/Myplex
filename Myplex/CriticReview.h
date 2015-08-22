//
//  CriticReview.h
//  Myplex
//
//  Created by Igor Ostriz on 31/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface CriticReview : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * review;
@property (nonatomic, retain) Content *owner;

@end
