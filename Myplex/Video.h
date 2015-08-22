//
//  Video.h
//  Myplex
//
//  Created by Igor Ostriz on 31/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * bitrate;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * resolution;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Content *owner;

@end
