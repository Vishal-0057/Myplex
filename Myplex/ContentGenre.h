//
//  ContentGenre.h
//  Myplex
//
//  Created by Igor Ostriz on 20/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content, Genre;

@interface ContentGenre : NSManagedObject

@property (nonatomic, retain) Content *owner;
@property (nonatomic, retain) Genre *genre;

@end
