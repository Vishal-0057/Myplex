//
//  LiveTV.h
//  Myplex
//
//  Created by Igor Ostriz on 31/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LiveTV : NSManagedObject

@property (nonatomic, retain) NSData * epg;

@end
