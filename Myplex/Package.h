//
//  Package.h
//  Myplex
//
//  Created by Igor Ostriz on 04/12/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content, PriceDetail, PromotionDetail;

@interface Package : NSManagedObject

@property (nonatomic, retain) NSString * bbDescription;
@property (nonatomic, retain) NSString * commercialModel;
@property (nonatomic, retain) NSString * contentId;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSNumber * couponFlag;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSNumber * packageIndicator;
@property (nonatomic, retain) NSString * packageName;
@property (nonatomic, retain) NSString * packageId;
@property (nonatomic, retain) NSNumber * renewalFlag;
@property (nonatomic, retain) NSString * validityPeriod;
@property (nonatomic, retain) NSSet *owners;
@property (nonatomic, retain) NSSet *priceDetails;
@property (nonatomic, retain) NSSet *promotionDetails;
@end

@interface Package (CoreDataGeneratedAccessors)

- (void)addOwnersObject:(PriceDetail *)value;
- (void)removeOwnersObject:(PriceDetail *)value;
- (void)addOwners:(NSSet *)values;
- (void)removeOwners:(NSSet *)values;

- (void)addPriceDetailsObject:(PriceDetail *)value;
- (void)removePriceDetailsObject:(PriceDetail *)value;
- (void)addPriceDetails:(NSSet *)values;
- (void)removePriceDetails:(NSSet *)values;

- (void)addPromotionDetailsObject:(PromotionDetail *)value;
- (void)removePromotionDetailsObject:(PromotionDetail *)value;
- (void)addPromotionDetails:(NSSet *)values;
- (void)removePromotionDetails:(NSSet *)values;

@end
