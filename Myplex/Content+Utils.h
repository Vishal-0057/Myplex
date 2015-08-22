//
//  Card+Utils.h
//  Myplex
//
//  Created by Igor Ostriz on 9/24/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Content.h"


__unused static NSString *kNotificationCardsRefreshed = @"CardsRefreshed";
__unused static NSString *kNotificationCardDetailsRefreshed = @"CardDetailsRefreshed";
__unused static NSString *kNotificationCardImageDownloaded = @"CardImageDownloaded";
__unused static NSString *kNotificationCardImageProgressBar = @"CardImageProgress";

__unused static NSString *kNotificationReviewsRefreshed = @"ReviewsRefreshed";
__unused static NSString *kNotificationCommentsRefreshed = @"CommentsRefreshed";

__unused static NSString *kNotificationMatchStatusRefreshed = @"MatchStatusRefreshed";


@interface Content (Utils)

@property (nonatomic, readonly) NSString *baseDescription;
@property (nonatomic, readonly) NSString *extendedDescription;

@property (nonatomic, readonly) NSArray *sortedImages;

@property (nonatomic, assign) NSInteger currentImageIndex;

+ (NSArray *)__searchArrayResults; // to be removed - debugging only

+(void)updateCardsDeleteStatus;

+ (NSArray *)getRecommendedCards;
+ (void)refreshRecommendedCards;
+ (void)refreshMoreRecommendedCards;                            // fetch next page

+ (NSArray *)getCardsWithType:(NSString *)type;
+ (void)refreshCardsWithType:(NSString *)type;
+ (void)refreshMoreCardsWithType:(NSString *)type;              // fetch next page

+ (NSArray *)getCardsForSearchWithQuery:(NSString *)query;
+ (void)refreshCardsForSearchWithQuery:(NSString *)query;
+ (void)refreshMoreCardsForSearchWithQuery:(NSString *)query;   // fetch next page

+ (NSArray *)getFavoriteCards;
+ (void)refreshFavoriteCards;
+ (void)refreshMoreFavoriteCards;

+ (NSArray *)getPurchasedCards;
+ (void)refreshPurchasedCards;
+ (void)refreshMorePurchasedCards;


- (void)refreshSimilarContent;
-(void)refreshMatchStatus;

- (Image *)imageSuitableForBrowse;

- (void)setComment:(NSString *)comment;
- (void)setReview:(NSString *)review andRate:(CGFloat)rate;

- (void)toggleFavorite;

// formatters
- (NSString *)getPurchaseString;
- (NSDecimalNumber *)lowestPrice;
- (NSString *)durationAsString;

- (void)getCommentsRemotely;
- (void)getReviewsRemotely;

+(NSArray *)fetchExpiredContentIds:(NSArray *)ids;

@end
