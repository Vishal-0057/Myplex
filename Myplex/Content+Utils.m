 ///
//  Card+Utils.m
//  Myplex
//
//  Created by Igor Ostriz on 9/24/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//


#import <objc/runtime.h>
#import "CommentReview.h"
#import "Content+Utils.h"
#import "NSError+Utils.h"
#import "GetCards.h"
#import "Image.h"
#import "NSManagedObject+Utils.h"
#import "NSManagedObjectContext+Utils.h"
#import "NSNotificationCenter+Utils.h"
#import "Package.h"
#import "PriceDetail.h"
#import "Purchase.h"
#import "RecommendedContent.h"
#import "SDWebImageDownloader.h"
#import "StandardKeySanitizer.h"
#import "UIAlertView+ReportError.h"
#import "UIAlertView+Blocks.h"
#import "Comment.h"
#import "AppData.h"
#import "UserReview.h"
#import "NSDate+ServerDateFormat.h"

@implementation Content (Utils)


//#define FETCH_ONE_BY_ONE


+ (id <RemoteKeySanitizer>)keySanitizer
{
    static StandardKeySanitizer *_sanitizer;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sanitizer = [[StandardKeySanitizer alloc] initWithKeys:@{
                        @"myplexDescription" : @"myPlexDescription",
                        @"description" : @"summary",
                        @"numUsersRated" : @"numUserRatings",
                        @"_type" : @"type",
                        // relations
                        @"genre" : @"genres",
                        @"relatedCast" : @"casts",
                        @"_expiresAt" : @"expiresAt"
                        }];
    });
    
	return _sanitizer;
}

+(void)updateCardsDeleteStatus {
    
    NSArray *contents = [[NSManagedObjectContext childUIManagedObjectContext] fetchObjectsForEntityName:[Content entityName] withPredicate:[NSPredicate predicateWithFormat:@"deleted==%@",@YES]];
    if ([contents count]) {
        [contents setValue:@NO forKey:@"deleted"];
        NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
        [tmp savePropagateWait];
    }
}

+ (NSArray *)getRecommendedCards
{
    // Fetch all
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.content.deleted = %@", @NO];
    
    NSArray *ar = [[NSManagedObjectContext childUIManagedObjectContext] fetchObjectsForEntityName:[RecommendedContent entityName] withPredicate:pred];
    
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"self.remoteId IN %@", [[ar valueForKey:@"content"] valueForKey:@"remoteId"]];
    ar = [[NSManagedObjectContext childUIManagedObjectContext] fetchObjectsForEntityName:[Content entityName] withPredicate:pred2];
//    ar = [ar valueForKey:@"content"];
    
    return [ar copy];
}


+ (void)refreshRecommendedCards
{
    NSArray *ar = [self getRecommendedCards];
    NSUInteger size = [ar count];
    if (size == 0) {
        [self refreshMoreRecommendedCards];
    }
    else {
        for (NSUInteger index = 0; index < size; index += [GetCards defaultPageSize]) {
            [self refreshRecommendedCardsFromIndex:index];
        }
    }
}

+ (void)refreshMoreRecommendedCards
{
    NSArray *ar = [self getRecommendedCards];
    [self refreshRecommendedCardsFromIndex:[ar count]];
}

+ (void)refreshRecommendedCardsFromIndex:(NSUInteger)index
{
    __block NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    
    NSUInteger page = index / getter.pageSize + 1;
    [getter getRecommendedCardsPage:page andCompletionHandler:^(NSArray *array, NSError *error) {
        
        if (!error) {
            [tmp savePropagateWait];
        }
        else {
            NSLog(@"Detailed error: %@", error.localizedDescription);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
        

#ifdef FETCH_ONE_BY_ONE
        // fetching one by one
        NSArray *ids = [array valueForKey:@"remoteId"];
        for (NSString *remoteId in ids) {
            [getter getDetailsForRemoteId:remoteId andCompletionHandler:^(id object, NSError *error) {
                [tmp savePropagateWait];
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
            }];
        }
#else
        // fetching all at once
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray *ids = [[array valueForKey:@"remoteId"] sortedArrayUsingSelector:@selector(compare:)];
            NSString *remoteIDs = [ids componentsJoinedByString:@","];
            
            ids = [self fetchExpiredContentIds:ids];
            
            if (ids.count > 0) {
                [getter getDetailsForRemoteId:remoteIDs andCompletionHandler:^(id object, NSError *error) {
                    [tmp savePropagateWait];
                    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
                }];
            }
        });
#endif
    }];
}


#pragma mark - Favorite cards
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//

+ (NSArray *)getFavoriteCards
{
    // Fetch all
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"deleted = %@ && favorite = %@", @NO, @YES];
    NSArray *ar = [[NSManagedObjectContext childUIManagedObjectContext] fetchObjectsForEntityName:[Content entityName] withPredicate:pred];
    return [ar copy];
}

+ (void)refreshFavoriteCards
{
    NSArray *ar = [self getFavoriteCards];
    NSUInteger size = [ar count];
    if (size == 0) {
        [self refreshMoreFavoriteCards];
    }
    else {
        for (NSUInteger index = 0; index < size; index += [GetCards defaultPageSize]) {
            [self refreshFavoriteCardsFromIndex:index];
        }
    }
}

+ (void)refreshMoreFavoriteCards
{
    NSArray *ar = [self getFavoriteCards];
    [self refreshFavoriteCardsFromIndex:[ar count]];
}

+ (void)refreshFavoriteCardsFromIndex:(NSUInteger)index
{
    __block NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    
    NSUInteger page = index / getter.pageSize + 1;
    [getter getFavoriteCardsPage:page andCompletionHandler:^(NSArray *array, NSError *error) {
        
        if (!error) {
            [tmp savePropagateWait];
        }
        else {
            NSLog(@"Detailed error: %@", error.localizedDescription);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
        
        
#ifdef FETCH_ONE_BY_ONE
        // fetching one by one
        NSArray *ids = [array valueForKey:@"remoteId"];
        for (NSString *remoteId in ids) {
            [getter getDetailsForRemoteId:remoteId andCompletionHandler:^(id object, NSError *error) {
                [tmp savePropagateWait];
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
            }];
        }
#else
        // fetching all at once
        NSArray *ids = [[array valueForKey:@"remoteId"] sortedArrayUsingSelector:@selector(compare:)];
        NSString *remoteIDs = [ids componentsJoinedByString:@","];
        
        ids = [self fetchExpiredContentIds:ids];

        if (ids.count > 0) {
            [getter getDetailsForRemoteId:remoteIDs andCompletionHandler:^(id object, NSError *error) {
                [tmp savePropagateWait];
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
            }];
        }
#endif
    }];
}

- (void)toggleFavorite
{
    NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    [getter toggleFavoriteForRemoteId:self.remoteId andCompletionHandler:^(NSError *error) {
        ;
    }];
    
}


#pragma mark - Purchased Cards
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//

+ (NSArray *)getPurchasedCards
{
    // Fetch all
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"deleted = %@ && purchased = %@", @NO, @YES];
    NSArray *ar = [[NSManagedObjectContext childUIManagedObjectContext] fetchObjectsForEntityName:[Content entityName] withPredicate:pred];
    return ar;
}
+ (void)refreshPurchasedCards
{
    NSArray *ar = [self getPurchasedCards];
    NSUInteger size = [ar count];
    if (size == 0) {
        [self refreshMorePurchasedCards];
    }
    else {
        //There is no pagination for purchased content, we will get all in one request.
//        for (NSUInteger index = 0; index < size; index += [GetCards defaultPageSize]) {
//            [self refreshPurchasedCardsFromIndex:index];
//        }
        [self refreshPurchasedCardsFromIndex:0];
    }
}
+ (void)refreshMorePurchasedCards
{
    NSArray *ar = [self getFavoriteCards];
    [self refreshPurchasedCardsFromIndex:[ar count]];
}
+ (void)refreshPurchasedCardsFromIndex:(NSUInteger)index
{
    __block NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    
    NSUInteger page = index / getter.pageSize + 1;
    [getter getPurchasedCardsPage:page andCompletionHandler:^(NSArray *array, NSError *error) {
        
        if (!error) {
            [tmp savePropagateWait];
        }
        else {
            NSLog(@"Detailed error: %@", error.localizedDescription);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
        
        
#ifdef FETCH_ONE_BY_ONE
        // fetching one by one
        NSArray *ids = [array valueForKey:@"remoteId"];
        for (NSString *remoteId in ids) {
            [getter getDetailsForRemoteId:remoteId andCompletionHandler:^(id object, NSError *error) {
                [tmp savePropagateWait];
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
            }];
        }
#else
        // fetching all at once
        NSArray *ids = [[array valueForKey:@"remoteId"] sortedArrayUsingSelector:@selector(compare:)];
        NSString *remoteIDs = [ids componentsJoinedByString:@","];
        
        ids = [self fetchExpiredContentIds:ids];

        if (remoteIDs.length > 0) {
            [getter getDetailsForRemoteId:remoteIDs andCompletionHandler:^(id object, NSError *error) {
                [tmp savePropagateWait];
                
                
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
            }];
        }
#endif
        
    }];
}




+ (NSArray *)getCardsWithType:(NSString *)type
{
    NSString *pred;
    if ([type length]) {
        //pred = [NSString stringWithFormat:@"type contains[c] \"%@\"", type];
        pred = [NSString stringWithFormat:@"type == \"%@\"", type];
    }
    
    NSArray *ar = [[NSManagedObjectContext childUIManagedObjectContext] fetchObjectsForEntityName:[Content entityName] withPredicate:pred];
    return ar;
}

+ (void)refreshCardsWithType:(NSString *)type
{
    NSArray *ar = [self getCardsWithType:type];
    NSUInteger size = [ar count];
    if (size == 0) {
        [self refreshMoreCardsWithType:type];
    }
    else {
        for (NSUInteger index = 0; index < size; index += [GetCards defaultPageSize]) {
            [self refreshCardsWithType:type fromIndex:index];
        }
//        for (NSUInteger index = 0; index < [GetCards defaultPageSize]; index += [GetCards defaultPageSize]) {
//            [self refreshCardsWithType:type fromIndex:index];
//        }
    }
}

+ (void)refreshMoreCardsWithType:(NSString *)type
{
    NSArray *ar = [self getCardsWithType:type];
    [self refreshCardsWithType:type fromIndex:[ar count]];
}

+ (void)refreshCardsWithType:(NSString *)type fromIndex:(NSUInteger)index
{
    __block NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    
    NSUInteger page = index / getter.pageSize + 1;
    [getter getCardsWithType:type andPage:page andCompletionHandler:^(NSArray *array, NSError *error) {
        
        if (!error) {
            [tmp savePropagateWait];
        }
        else {
            NSLog(@"Detailed error: %@", error.localizedDescription);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
        
        
#ifdef FETCH_ONE_BY_ONE
        // fetching one by one
        NSArray *ids = [array valueForKey:@"remoteId"];
        for (NSString *remoteId in ids) {
            [getter getDetailsForRemoteId:remoteId andCompletionHandler:^(id object, NSError *error) {
                [tmp savePropagateWait];
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
            }];
        }
#else
        // fetching all at once
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            NSArray *ids = [[array valueForKey:@"remoteId"] sortedArrayUsingSelector:@selector(compare:)];
            NSString *remoteIDs = [ids componentsJoinedByString:@","];
            
            ids = [self fetchExpiredContentIds:ids];
            
            if (ids.count > 0) {
                [getter getDetailsForRemoteId:remoteIDs andCompletionHandler:^(id object, NSError *error) {
                    [tmp savePropagateWait];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
                }];
            }
        });
#endif
        
    }];
}


#pragma mark Fetching ExpiredContentIds

+(NSArray *)fetchExpiredContentIds:(NSArray *)ids {
 
    NSArray *expiredContentIds = nil;
    if (ids.count > 0) {
        NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
        NSDate *date = [NSDate GMTDate];
        NSArray *contents = nil;
#if DEBUG
        contents = [tmp fetchObjectsForEntityName:@"Content" withPredicate:[NSPredicate predicateWithFormat:@"(remoteId IN %@)",ids]];
        NSArray *expiresAt = [contents valueForKey:@"expiresAt"];
        NSLog(@"ExpiresAt %@, system time %@",expiresAt,date);
#endif
        contents = [tmp fetchObjectsForEntityName:@"Content" withPredicate:[NSPredicate predicateWithFormat:@"(remoteId IN %@) && ((expiresAt < %@) || (expiresAt == NULL))",ids,date]];
        expiredContentIds = [contents valueForKey:@"remoteId"];
    }
    
    return expiredContentIds;
}



#pragma mark - Search

static NSString *_queryString;
static NSArray *_queryStringResults;

+ (NSArray *)__searchArrayResults
{
    return _queryStringResults;
}

+ (NSArray *)getCardsForSearchWithQuery:(NSString *)query
{
    NSString *pred;
    NSArray *ar;
    if ([query length] && ![query isEqualToString:_queryString]) {
        // fetch from local db
        pred = [NSString stringWithFormat:@"type contains[c] \"%@\" AND (title contains[c] \"%@\" OR ANY tags.name contains[c] \"%@\" OR ANY casts.name contains[c] \"%@\")", @"movie",query,query,query];
        ar = [[NSManagedObjectContext childUIManagedObjectContext] fetchObjectsForEntityName:[Content entityName] withPredicate:pred];
    } else {
        ar = _queryStringResults;
    }
    
    return [ar copy];
    
}

+ (void)refreshCardsForSearchWithQuery:(NSString *)query
{
    NSArray *ar = [self getCardsForSearchWithQuery:query];
    NSUInteger size = [ar count];
    if (size == 0) {
        [self refreshMoreCardsForSearchWithQuery:query];
    }
    else {
        //for (NSUInteger index = 0; index < size; index += [GetCards defaultPageSize]) {
        [self refreshCardsForSearchWithQuery:query fromIndex:1];
        //}
    }
}

+ (void)refreshMoreCardsForSearchWithQuery:(NSString *)query
{
    NSArray *ar = [self getCardsForSearchWithQuery:query];
    [self refreshCardsForSearchWithQuery:(NSString *)query fromIndex:[ar count]];
}

+ (void)refreshCardsForSearchWithQuery:(NSString *)query fromIndex:(NSUInteger)index
{
    __block NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    
    NSUInteger page = index / getter.pageSize + 1;

    [getter getCardsWithQuery:query andPage:page andCompletionHandler:^(NSArray *array, NSError *error) {
        
        if (!error && array.count > 0) {
            [tmp savePropagateWait];
        } else if(!array || !array.count){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [UIAlertView alertViewWithTitle:kAppTitle message:[NSString stringWithFormat:kSearchQueryNotFound,query]];
            });
            
        } else if(error){
            NSLog(@"Detailed error: %@", error.localizedDescription);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
        
        // fetching all at once
        NSArray *ids = [[array valueForKey:@"remoteId"] sortedArrayUsingSelector:@selector(compare:)];
        NSString *remoteIDs = [ids componentsJoinedByString:@","];
        
        ids = [self fetchExpiredContentIds:ids];

        if (ids.count > 0) {
            [getter getDetailsForRemoteId:remoteIDs andCompletionHandler:^(id object, NSError *error) {
                
                if (error) {
                    [UIAlertView showAlertWithError:error];
                }
                if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[Content class]]) {
                    
                    // save the data first
                    [tmp savePropagateWait];
                    // normalize result to array
                    object = [object isKindOfClass:[NSArray class]] ? object : @[object];
                    __block NSArray *newIDs = [object valueForKey:@"remoteId"];
                    
                    NSManagedObjectContext *mainMOC = [NSManagedObjectContext childUIManagedObjectContext];
                    [mainMOC performBlockAndWait:^{
                        // Existing IDs
                        NSArray *existingIDs = @[];
                        if ([_queryString isEqualToString:query]) {
                            existingIDs = [_queryStringResults valueForKey:@"remoteId"];
                        }
                        _queryString = query;
                        // remove duplicates
                        NSMutableSet *set = [NSMutableSet setWithArray:newIDs];
                        [set addObjectsFromArray:existingIDs];
                        
                        NSPredicate *pred = [NSPredicate predicateWithFormat:@"remoteId IN %@", set];
                        _queryStringResults = [mainMOC fetchObjectsForEntityName:[Content entityName] withPredicate:pred];
                    }];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardsRefreshed object:nil];
            }];
        }
    }];
}

#pragma mark - Description

- (NSString *)baseDescription
{
    //return self.briefDescription;
    return self.myPlexDescription ? self.myPlexDescription: self.briefDescription;
}

- (NSString *)extendedDescription
{
    //NSString *s = self.summary;
    
    NSString *r = self.myPlexDescription ? self.myPlexDescription : self.briefDescription/*self.studioDescription*/;
//    if (r.length > 0)
//        s = [s stringByAppendingString:[@"\n\nmyplex description \n" stringByAppendingString:r]];

    return r;
}


- (void)refreshCard
{
    NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    [getter getDetailsForRemoteId:self.remoteId andCompletionHandler:^(id object, NSError *error) {
        
        if (!error) {
            [tmp savePropagate];
        }
        else {
            NSLog(@"Detailed error: %@", error.localizedDescription);
        }
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardDetailsRefreshed object:nil];
    }];
}

#pragma mark - Match Stuats 
-(void)refreshMatchStatus {
    
    __block NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    [getter getMatchStatusForContent:self andCompletionHandler:^(id matchStatus, NSError *error) {
        if (!error) {
            [tmp savePropagate];
        }
        else {
            NSLog(@"Detailed error: %@", error.localizedDescription);
        }
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationMatchStatusRefreshed object:self];
    }];
}

#pragma mark - Similar Content

- (void)refreshSimilarContent
{
   __block NSManagedObjectContext *tmp = [NSManagedObjectContext tempManagedObjectContext];
    GetCards *getter = [[GetCards alloc] initWithManagedObjectContext:tmp];
    [getter getSimilarContentForContent:self andCompletionHandler:^(NSArray *array, NSError *error) {
        if (!error) {
            [tmp savePropagate];
        }
        else {
            NSLog(@"Detailed error: %@", error.localizedDescription);
        }
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCardDetailsRefreshed object:self];
    }];
}


#pragma mark - Comments

- (void)setComment:(NSString *)comment
{
    CommentReview *cr = [[CommentReview alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    [cr addComment:comment toContent:self.remoteId andCompletionHandler:^(id response, NSError *error) {
        if (error) {
            [UIAlertView showAlertWithError:error];
        } else if([self isNotNull:response] && [self isNotNull:comment]) {
            NSInteger commentsCount = self.commentsCount.integerValue;
            self.commentsCount = [NSNumber numberWithInteger:commentsCount++];
            
            Comment *comment_ = [Comment createNewInManagedObjectContext:self.managedObjectContext];
            comment_.comment = comment?:@"";
            comment_.userName = @"";
            comment_.timestamp = [NSDate date];
             if ([[[AppData shared]data][@"user"][@"userId"] isKindOfClass:[NSNumber class]]) {
                 comment_.userId = [[[AppData shared]data][@"user"][@"userId"]stringValue];
             } else {
                 comment_.userId = [[AppData shared]data][@"user"][@"userId"];
             }
            
            [self addCommentsObject:comment_];
            
            NSError *error;
            [self.managedObjectContext save:&error];
            [error logDetailedError];

            [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationCommentsRefreshed object:nil];
        }
    }];
}

- (void)getCommentsRemotely
{
    CommentReview *cr = [[CommentReview alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    [cr getCommentsOfContent:self.remoteId andCompletionHandler:^(id response, NSError *error) {
        if (error) {
            [UIAlertView showAlertWithError:error];
        }
        [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationCommentsRefreshed object:response];
    }];
    
}

#pragma mark - Reviews

- (void)getReviewsRemotely
{
    CommentReview *cr = [[CommentReview alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    [cr getReviewsOfContent:self.remoteId andCompletionHandler:^(id response, NSError *error) {
        if (error) {
            [UIAlertView showAlertWithError:error];
        }
        [[NSNotificationCenter defaultCenter]postNotificationNameOnMainThread:kNotificationReviewsRefreshed object:response];
    }];
    
}

- (void)setReview:(NSString *)review andRate:(CGFloat)rate
{
    CommentReview *cr = [[CommentReview alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    [cr addReview:review andRating:rate toContent:self.remoteId andCompletionHandler:^(id response, NSError *error) {
        if (error) {
            [UIAlertView showAlertWithError:error];
            return;
        } else if ([self isNotNull:response]) {
                        
            NSInteger reviewsCount = self.userRatingsCount.integerValue;
            self.userRatingsCount = [NSNumber numberWithInteger:reviewsCount++];
            
            if ([self isNotNull:review]) {
                NSSet *userReview = [self.userReviews filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"userId=='%@'",[[AppData shared]data][@"user"][@"userId"]]];
                UserReview *rev = [userReview anyObject];
                //[self removeUserReviewsObject:rev];
                //rev = nil;
                if ([self isNull:rev]) {
                    rev =  [UserReview createNewInManagedObjectContext:self.managedObjectContext];
                    [self addUserReviewsObject:rev];
                }
                rev.userName = @"";
                if ([[[AppData shared]data][@"user"][@"userId"] isKindOfClass:[NSNumber class]]) {
                    rev.userId = [[[AppData shared]data][@"user"][@"userId"]stringValue];
                } else {
                    rev.userId = [[AppData shared]data][@"user"][@"userId"];
                }
                rev.timestamp = [NSDate date];
                rev.review = review;
                rev.rating = [NSNumber numberWithFloat:rate];
                rev.owner = self;
            }

            NSError *error;
            [self.managedObjectContext save:&error];
            [error logDetailedError];
        }
        [[NSNotificationCenter defaultCenter] postNotificationNameOnMainThread:kNotificationReviewsRefreshed object:nil];
    }];
    
}

#pragma mark - Images

static const char* _sortedImagesKey = "sortedImagesKey";

- (NSArray *)sortedImages
{
    NSArray *r = objc_getAssociatedObject(self, _sortedImagesKey);
    if (!r || r.count != self.images.count) {
        r = [[self.images allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 valueForKey:@"type"] compare:[obj2 valueForKey:@"type"]];
            }];
        objc_setAssociatedObject(self, _sortedImagesKey, r, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return r;
}

- (Image *)imageSuitableForBrowse
{
    Image *current;
    CGFloat currentDelta = 2.;
    CGFloat minX = 3000;
    
    for (Image *img in self.images) {
        NSArray *ar = [img.resolution componentsSeparatedByString:@"x"];
        if ([ar count] != 2) {
            if (!current)
                current = img;
            continue;
        }
        CGFloat x = [ar[0] floatValue];
        CGFloat y = [ar[1] floatValue];
        
        if (!x || !y) {
            if (!current)
                current = img;
            continue;
        }
        
        CGFloat d = floorf((fabsf(x/y - 16./9.) + 0.0005) * 1000)/1000.;
        if (d < currentDelta || (d == currentDelta && x < minX)) {
            current = img;
            currentDelta = d;
            minX = x;
        }
    }
    
    return current;
}

#pragma mark - Pricing

- (NSDecimalNumber *)lowestPrice;
{
    NSDecimalNumber *low = [NSDecimalNumber notANumber];
    
    for (Package *p in self.packages) {
        NSSet *inappPrice = [p.priceDetails filteredSetUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"paymentChannel == 'INAPP'"]]];
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
        //NSArray *prices = [[p.priceDetails sortedArrayUsingDescriptors:@[sd]] valueForKey:@"price"];
        NSArray *prices = [[inappPrice sortedArrayUsingDescriptors:@[sd]] valueForKey:@"price"];
        if ([prices count]) {
            if ([self isNotNull:low] && ([low isEqualToNumber:[NSDecimalNumber notANumber]] || [low floatValue] > [prices[0] floatValue])) {
                low = prices[0];
            }
        }
    }
    
    if ([self isNotNull:low]) {
        return low;
    } else {
       return nil;
    }
}


- (NSString *)durationAsString
{
    NSInteger ti = (NSInteger)self.duration;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%2i:%02i:%02i", hours, minutes, seconds];
}

static NSString *kSoonString = @"Coming soon";
static NSString *kFreeString = @"Watch now for free";
static NSString *kWatchNowString = @"Watch now";
static NSString *kFromString = @"Starting from ₹ %@";

- (NSString *)getPurchaseString
{
    // is it payed for a content?
    BOOL isPurchaceValid = NO;
    for (Purchase *purchase_ in self.purchases) {
        if ([self isNotNull:purchase_.validity]) {
            isPurchaceValid = [self isPurchaseValid:purchase_.validity];
        }
    }
    if (self.purchased.boolValue /*&& isPurchaceValid*/)
        return kWatchNowString;

    NSDecimalNumber *price = [self lowestPrice];
    // no prices => Coming Soon...
    if ([price isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return kSoonString;
    }
    
    // price = 0
    if ([price floatValue] == 0) {
        return kFreeString;
    }
    
//    if ([self.type isEqualToString:@"movie"])
//        return kSoonString;
//    
//    if ([self.type isEqualToString:@"live"]) {
//        return [NSString stringWithFormat:kFromString, price];
//    }
    
    if ([self isNotNull:price]) {
        return [NSString stringWithFormat:kFromString, price];
    }
    return kSoonString;
}

- (BOOL)isPurchaseValid:(NSString *)purchaseValidity {
    
    BOOL purchaseValid = YES;
    
    NSDate *currentDate = [NSDate GMTDate];
    NSDate *purchaseExpirationDate = [NSDate formatStringToDate:purchaseValidity];
    if ([currentDate compare:purchaseExpirationDate] == NSOrderedDescending || !purchaseExpirationDate) {
        NSLog(@"currentDate is greater than purchaseValidity");
        purchaseValid = NO;
    }
    return purchaseValid;
}



static const char* _key = "imageIndex";

- (NSInteger)currentImageIndex
{
    id num = objc_getAssociatedObject(self, _key);
    if (num == nil) {
        [self setCurrentImageIndex:0];
    }
    return [num integerValue];
}

- (void)setCurrentImageIndex:(NSInteger)currentImageIndex
{
    objc_setAssociatedObject(self, _key, [NSNumber numberWithInteger:currentImageIndex], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didTurnIntoFault
{
    objc_removeAssociatedObjects(self);
}

- (void)willTurnIntoFault
{
    
}

@end
