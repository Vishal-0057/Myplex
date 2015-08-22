//
//  PriceDetail.h
//  Myplex
//
//  Created by Igor Ostriz on 13/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PriceDetail : NSManagedObject

@property (nonatomic, retain) NSNumber * doubleConfirmation;
@property (nonatomic, retain) NSString * paymentChannel;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSNumber * webBased;
@property (nonatomic, retain) NSString * name;

@end
