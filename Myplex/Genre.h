//
//  Genre.h
//  Myplex
//
//  Created by Igor Ostriz on 20/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Genre : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * remoteId;

@end
