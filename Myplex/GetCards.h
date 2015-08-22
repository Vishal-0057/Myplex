//
//  GetCards.h
//  Myplex
//
//  Created by Igor Ostriz on 9/20/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Content;
@interface GetCards : NSObject

@property (nonatomic, assign) NSUInteger pageSize;

+ (NSUInteger)defaultPageSize;

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc;

- (void)getRecommendedCardsPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray *array, NSError *error))block;
- (void)getCardsWithType:(NSString *)type andPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray*, NSError*))block;
- (void)getCardsWithQuery:(NSString *)query andPage:(NSUInteger)index andCompletionHandler:(void(^)(NSArray*, NSError*))block;
- (void)getFavoriteCardsPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray *array, NSError *error))block;
- (void)getPurchasedCardsPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray *array, NSError *error))block;

- (void)toggleFavoriteForRemoteId:(NSString *)remoteId andCompletionHandler:(void(^)(NSError *error))block;

- (void)getDetailsForRemoteId:(NSString *)remoteId andCompletionHandler:(void(^)(id object, NSError *error))block;
- (void)getSimilarContentForContent:(Content *)content andCompletionHandler:(void(^)(NSArray *array, NSError *error))block;
- (void)getMatchStatusForContent:(Content *)content andCompletionHandler:(void(^)(id matchStatus, NSError *error))block;

@end
