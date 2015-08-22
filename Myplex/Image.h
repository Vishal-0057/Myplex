//
//  Image.h
//  Myplex
//
//  Created by Igor Ostriz on 18/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * content;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSString * resolution;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Content *owner;

@end
