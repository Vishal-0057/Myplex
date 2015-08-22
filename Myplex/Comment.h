//
//  Comment.h
//  Myplex
//
//  Created by Igor Ostriz on 15/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) Content *owner;

@end
