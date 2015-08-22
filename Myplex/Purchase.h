//
//  Purchase.h
//  Myplex
//
//  Created by shiva on 3/14/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content, Package;

@interface Purchase : NSManagedObject

@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * validity;
@property (nonatomic, retain) NSData * receipt;
@property (nonatomic, retain) NSNumber * isReceiptValidated;
@property (nonatomic, retain) Content *content;
@property (nonatomic, retain) Package *package;

@end
