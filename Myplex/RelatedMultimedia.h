//
//  RelatedMultimedia.h
//  Myplex
//
//  Created by Igor Ostriz on 31/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface RelatedMultimedia : NSManagedObject

@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) Content *content;
@property (nonatomic, retain) Content *owner;

@end
