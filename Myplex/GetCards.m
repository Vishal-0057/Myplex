//
//  GetCards.m
//  Myplex
//
//  Created by Igor Ostriz on 9/20/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "AppData.h"
#import "Cast.h"
#import "CertifiedRating.h"
#import "Comment.h"
#import "Content+Utils.h"
#import "ContentGenre.h"
#import "Genre.h"
#import "GetCards.h"
#import "Image.h"
#import "Image+Utils.h"
#import "NSDate+ServerDateFormat.h"
#import "NSError+Utils.h"
#import "NSManagedObject+Utils.h"
#import "NSManagedObjectContext+Utils.h"
#import "Package.h"
#import "PriceDetail.h"
#import "Purchase.h"
#import "RecommendedContent.h"
#import "RelatedMultimedia.h"
#import "ServerStandardRequest.h"
#import "SimilarContent.h"
#import "StandardKeySanitizer.h"
#import "UIImage+Utils.h"
#import "UserReview.h"
#import "Video+Utils.h"




@implementation GetCards
{
    NSManagedObjectContext* _managedObjectContext;
}

+ (NSUInteger)defaultPageSize
{
    return 10;
}


- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc
{
	self = [super init];
	if (self) {
		_managedObjectContext = moc;
        _pageSize = [GetCards defaultPageSize];
	}
	
	return self;
}

- (NSArray *)cards
{
    return [_managedObjectContext fetchObjectsForEntityName:@"Content" withPredicate:nil];
}



// https://api-beta.myplex.in/content/v2/recommendations/?clientKey=dcb11454ccdafdd4706c7186d37abd2ff96cd02dc998d1111d16d4778a797f85&level=dynamic
- (void)getRecommendedCardsPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray *array, NSError *error))block;
{
    NSString *path = @"content/recommendations/";
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"level":@"dynamic", @"startIndex":@(page), @"pageSize":@(self.pageSize)};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        if (error) {
            block(nil, error);
        } else {
            
            NSArray *objects = jsonData[@"results"];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[objects count]];
            
            [_managedObjectContext performBlock:^{
                
                for (id object in objects) {
                    
                    Content *c = [self parseDynamicData:object];
                    
                    //                    NSString *remoteId = object[@"_id"];
                    //                    Content *c = (Content *)[Content fetchByRemoteId:remoteId context:_managedObjectContext];
                    //                    if (!c) {
                    //                        c = [Content createNewInManagedObjectContext:_managedObjectContext];
                    //                        c.remoteId = remoteId;
                    //                    }
                    //
                    // Check if RecommendedContent exist
                    NSPredicate *p = [NSPredicate predicateWithFormat:@"content.remoteId == %@", c.remoteId];
                    NSArray *chk  = [_managedObjectContext fetchObjectsForEntityName:[RecommendedContent entityName] withPredicate:p];
                    if ([chk count] == 0) {
                        RecommendedContent *rc = [RecommendedContent createNewInManagedObjectContext:_managedObjectContext];
                        rc.content = c;
                    }
                    
                    [array addObject:c];
                    
                }
                NSError *error;
                [_managedObjectContext save:&error];
                [error logDetailedError];
                
                
                block(array, nil);
                
                
                
                
            }];
            
        }
    }];
}

// https://api-beta.myplex.in/user/v2/content/195/favorite/?clientKey=0157d098bcbbfa635e7159789075839c67213f84af51dbbb8bd875d3f6f28bae
- (void)toggleFavoriteForRemoteId:(NSString *)remoteId andCompletionHandler:(void(^)(NSError *error))block
{
    NSString *path = [NSString stringWithFormat:@"user/content/%@/favorite/", remoteId];
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void) [[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeCreate completionHandler:^(id jsonData, NSError* error) {
        
        block(error);
        
    }];
}


// https://api-beta.myplex.in/user/v2/contentList/favorites/?clientKey=0157d098bcbbfa635e7159789075839c67213f84af51dbbb8bd875d3f6f28bae
- (void)getFavoriteCardsPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray *array, NSError *error))block
{
    NSString *path = @"user/contentList/favorites/";
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"startIndex":@(page), @"pageSize":@(self.pageSize)};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        if (error) {
            block(nil, error);
        } else {
            
            NSArray *objects = jsonData[@"results"];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[objects count]];
            
            [_managedObjectContext performBlock:^{
                
                
                // remove all favorites for now
                NSArray *ar = [_managedObjectContext fetchObjectsForEntityName:[Content entityName] withPredicate:@"favorite == YES" ];
                [ar enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    Content *cc = (Content *)obj;
                    cc.favorite = @NO;
                }];
                for (id object in objects) {

                    NSString *remoteId = object[@"_id"];
                    Content *c = (Content *)[Content fetchByRemoteId:remoteId context:_managedObjectContext];
                    if (!c) {
                        c = [Content createNewInManagedObjectContext:_managedObjectContext];
                        c.remoteId = remoteId;
                        // fill array with items that need fetching
                        [array addObject:c];
                    }
                    c.favorite = @YES;
                }

                NSError *error;
                [_managedObjectContext save:&error];
                [error logDetailedError];
                
                block(array, nil);
                
            }];
        }
    }];
}


// https://api-beta.myplex.in/user/v2/contentList/purchased/?clientKey=0157d098bcbbfa635e7159789075839c67213f84af51dbbb8bd875d3f6f28bae
- (void)getPurchasedCardsPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray *array, NSError *error))block
{
    NSString *path = @"user/contentList/purchased/";
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"startIndex":@(page), @"pageSize":@(self.pageSize)};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        if (error) {
            block(nil, error);
        } else {
            
            NSArray *objects = [jsonData[@"results"] valueForKey:@"_id"];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[objects count]];
            
            // remove duplicates
            objects = [[NSSet setWithArray:objects] allObjects];
            
            [_managedObjectContext performBlock:^{
                
                // remove all purchased for now
                NSArray *ar = [_managedObjectContext fetchObjectsForEntityName:[Content entityName] withPredicate:@"purchased == YES" ];
                [ar enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    Content *cc = (Content *)obj;
                    cc.purchased = @NO;
                }];
                for (id object in objects) {
                    
                    NSString *remoteId = object;
                    Content *c = (Content *)[Content fetchByRemoteId:remoteId context:_managedObjectContext];
                    if (!c) {
                        c = [Content createNewInManagedObjectContext:_managedObjectContext];
                        c.remoteId = remoteId;
                        // fill array with items that need fetching
                        [array addObject:c];
                    }
                    c.purchased = @YES;
                }
                
                NSError *error;
                [_managedObjectContext save:&error];
                [error logDetailedError];
                
                block(array, nil);
                
            }];
        }
    }];
}


- (void)getCardsWithType:(NSString *)type andPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray*, NSError*))block
{
    NSString *path = @"content/contentList/";
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"type":type?:@"", @"level":@"dynamic", @"startIndex":@(page), @"pageSize":@(self.pageSize)};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        if (error) {
            block(nil, error);
        } else {
            
            NSArray *objects = jsonData[@"results"];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[objects count]];
            
            [_managedObjectContext performBlock:^{
                
                for (id object in objects)
                {
                    Content *c = [self parseDynamicData:object];
                    [array addObject:c];
                }
                
                NSError *error;
                [_managedObjectContext save:&error];
                [error logDetailedError];
                
                block(array, nil);
                
            }];
        }
    }];
}



// http://dev.myplex.in/content/v2/search/?startIndex=0
- (void)getCardsWithQuery:(NSString *)query andPage:(NSUInteger)page andCompletionHandler:(void(^)(NSArray*, NSError*))block
{
    if (![query length]) {
        query = @"*";
    }
    
    NSString *path = @"content/search/";
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"query":query, @"level":@"dynamic", @"type":@"movie", @"startIndex":@(page), @"pageSize":@(self.pageSize)};
    
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        if (error) {
            block(nil, error);
        } else {
            
            NSArray *objects = jsonData[@"results"];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[objects count]];
            
            [_managedObjectContext performBlock:^{
                
                for (id object in objects)
                {
                   // NSString *remoteId = object[@"_id"];
                    
//                    Content *c = (Content *)[Content fetchByRemoteId:remoteId context:_managedObjectContext];
//                    if (!c) {
//                        c = [Content createNewInManagedObjectContext:_managedObjectContext];
//                        c.remoteId = remoteId;
//                    }
                    Content *c = [self parseDynamicData:object];
                    [array addObject:c];
                }
                
                NSError *error;
                [_managedObjectContext save:&error];
                [error logDetailedError];
                
                block(array, nil);
                
            }];
        }
    }];
}






- (void)getDetailsForRemoteId:(NSString *)remoteId andCompletionHandler:(void (^)(id, NSError *))block
{
    NSString *path = [NSString stringWithFormat:@"content/contentDetail/%@/", remoteId];
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"level":@"static"};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        if (error) {
            block(nil, error);
        } else {
            
            NSArray *objects = jsonData[@"results"];
            if (![objects count]) {
                return;
            }
            
            [_managedObjectContext performBlockAndWait:^{
                
                NSMutableArray *ar = [[NSMutableArray alloc] initWithCapacity:[objects count]];
                for (id object in objects) {
                    Content *mo = [self createOrUpdateContent:object save:NO];
                    
                    // update similarContent
                    NSArray *similars = object[@"similarContent"][@"values"];
                    [mo removeSimilarContent:mo.similarContent];
                    for (id similar in similars) {
                        
                        Content *co = [self createOrUpdateContent:similar save:YES];
                        
                        SimilarContent *sc = [SimilarContent createNewInManagedObjectContext:_managedObjectContext];
                        sc.content = co;
                        sc.owner = mo;
                        
                        [mo addSimilarContentObject:sc];
                    }
                    
                    if ([self isNotNull:mo]) {
                        [ar addObject:mo];  
                    }
                    
                    NSError *error;
                    [_managedObjectContext save:&error];
                    [error logDetailedError];
                }
                
                
                block(ar, nil);
                
                
            }];
        }
    }];
}


- (void)getSimilarContentForContent:(Content *)content andCompletionHandler:(void(^)(NSArray *array, NSError *error))block
{
    NSString *path = [NSString stringWithFormat:@"content/similar/%@/", content.remoteId];
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"level":@"devicemin", @"field":@"title"};
    
    // normalize content if comming from different managedContextObject
    if (content.managedObjectContext != _managedObjectContext) {
        content = (Content *)[Content fetchByRemoteId:content.remoteId context:_managedObjectContext];
    }
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        if (error) {
            block(nil, error);
        } else {
            //NSArray *similars = jsonData[@"similarContent"][@"values"];
            NSArray *similars = jsonData[@"results"];
            NSMutableArray *similarObjects = [NSMutableArray array];
            [_managedObjectContext performBlockAndWait:^{
                if ([similars count]) {
                    [content removeSimilarContent:content.similarContent];
                }
                for (id similar in similars) {
                    
                    Content *co = [self createOrUpdateContent:similar save:YES];
                    SimilarContent *sc = [SimilarContent createNewInManagedObjectContext:_managedObjectContext];
                    sc.content = co;
                    sc.owner = content;
                    
                    [content addSimilarContentObject:sc];
                    
                    if ([self isNotNull:sc]) {
                        [similarObjects addObject:sc];
                    }
                }
                NSError *error;
                [_managedObjectContext save:&error];
                [error logDetailedError];
                
            }];
            
            block(similarObjects, nil);
        }
        
    }];
}

- (void)getMatchStatusForContent:(Content *)content andCompletionHandler:(void(^)(id matchStatus, NSError *error))block
{
    NSString *path = [NSString stringWithFormat:@"content/content/%@/matchStatus/", content.remoteId];
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"pretty":@"1"};
    
    // normalize content if comming from different managedContextObject
    if (content.managedObjectContext != _managedObjectContext) {
        content = (Content *)[Content fetchByRemoteId:content.remoteId context:_managedObjectContext];
    }
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        if (error) {
            block(nil, error);
        } else {
            //NSArray *similars = jsonData[@"similarContent"][@"values"];
            NSDictionary *matchStatus = jsonData[@"results"][@"matchStatus"];
            [_managedObjectContext performBlockAndWait:^{
                content.matchStatus = matchStatus;
                NSError *error;
                [_managedObjectContext save:&error];
                [error logDetailedError];
                
            }];
            
            block(matchStatus, nil);
        }
        
    }];
}


- (Content *)createOrUpdateContent:(id)jsonData save:(BOOL)save
{
    Content *co = (Content *)[Content updateOrCreateFromJSONData:jsonData inContext:_managedObjectContext uniqueSanitizedKey:@"remoteId" save:NO];
    
    // update additional fields
    [co updateFromJSONData:jsonData[@"content"] inContext:_managedObjectContext keySanitizer:[Content keySanitizer]];
    
    // genres
    NSArray *genres = jsonData[@"content"][@"genre"];
    if (genres) {
        [co removeGenres:co.genres];
        for (id genre in genres) {
            Genre *gen = (Genre *)[Genre updateOrCreateFromJSONData:genre inContext:_managedObjectContext uniqueSanitizedKey:@"remoteId" save:NO];

            ContentGenre *cg = [ContentGenre createNewInManagedObjectContext:_managedObjectContext];
            cg.owner = co;
            cg.genre = gen;
            [co addGenresObject:cg];
        }
    }
        
    // certifiedRatings
    NSDictionary *certRat = jsonData[@"content"][@"certifiedRatings"];
    if (certRat) {
        [co removeCertifiedRatings:co.certifiedRatings];
        NSArray *certifiedRatings = certRat[@"values"];
        for (id certifiedRating in certifiedRatings) {
            CertifiedRating *rating = [CertifiedRating createNewInManagedObjectContext:_managedObjectContext];
            rating.name = certifiedRating[@"name"];
            rating.rating = certifiedRating[@"rating"];
            rating.owner = co;
            
            [co addCertifiedRatingsObject:rating];
        }
    }
    
    [co updateFromJSONData:jsonData[@"generalInfo"] inContext:_managedObjectContext keySanitizer:[Content keySanitizer]];
    if (co.type == nil) {
        co.type = @"movie";
    }
    

    // update images
    NSArray *imgs = jsonData[@"images"][@"values"];
    for (id img in imgs) {
        
        BOOL continue_ = YES;
        // allow only images suitable for browse (16:9) & 2:3 for download
        if ([img[@"resolution"] isEqualToString:@"960x540"] || [img[@"type"] isEqualToString:@"thumbnail"])
            continue_ = NO;
        
        if (continue_)
            continue;
        
        Image *image = (Image *)[Image updateOrCreateFromJSONData:img inContext:_managedObjectContext uniqueSanitizedKey:@"url" save:NO];
                
        // find existing image
        if ([image isContainedIn:co.images]) {
            continue;
        }
        [co addImagesObject:image];
    }
    
    
    // comments count
    id comments = jsonData[@"comments"];
    if (comments) {
        co.commentsCount = comments[@"numComments"];
    }
    
    // user ratings count and average
    id userReviews = jsonData[@"userReviews"];
    if (userReviews) {
        co.userRatingsCount = userReviews[@"numUsersRated"];
        if (userReviews[@"averageRating"]) {
            co.averageRating = userReviews[@"averageRating"];
        } else {
            co.averageRating = [NSNumber numberWithFloat:0.0f];
        }
    }
    
    NSError *error = nil;
    if (![co validateForInsertOrUpdate:&error]) {
        [error logDetailedError];
        
        // ignore object in managed object context
        [_managedObjectContext deleteObject:co];
        
        return nil;
    }
    
    if (save) {
        [_managedObjectContext save:&error];
        [error logDetailedError];
    }
    
    // update videos
    NSArray *vids = jsonData[@"videos"][@"values"];
    for (id vid in vids) {
        Video *video = (Video *)[Video updateOrCreateFromJSONData:vid inContext:_managedObjectContext uniqueSanitizedKey:@"url" save:NO];
        
        // find existing image
        if ([video isContainedIn:co.videos]) {
            continue;
        }
        
        if ([video validateForInsertOrUpdate:&error]) {
            [co addVideosObject:video];
        }
    }
    
    // update related Multimedia
    NSArray *relatedMultimedia = jsonData[@"relatedMultimedia"][@"values"];
    [co removeRelatedMultimedia:co.relatedMultimedia];
    for (id media in relatedMultimedia) {
        
        Content *content = [self createOrUpdateContent:media save:YES];
        if (!content && media[@"_id"]) {
            NSString *remoteId = media[@"_id"];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"remoteId = %@", remoteId];
            NSArray *ar = [_managedObjectContext fetchObjectsForEntityName:[Content entityName] withPredicate:pred];
            if (![ar count]) {
                continue;
                
            }
            content = ar[0];
        }
        if (content) {
            
            RelatedMultimedia *rm = [RelatedMultimedia createNewInManagedObjectContext:_managedObjectContext];
            if ([self isNotNull:media[@"content"][@"categoryName"]]) {
                rm.categoryName = media[@"content"][@"categoryName"];
            }
            rm.content = content;
            rm.owner = co;
            if ([rm validateForInsertOrUpdate:&error]) {
                [co addRelatedMultimediaObject:rm];
            }
        }
        
    }
    
    // update cast
    [co removeCasts:co.casts];
    NSArray *casts = jsonData[@"relatedCast"][@"values"];
    for (id cast in casts) {
//        if ([cast[@"name"] isEqualToString:@"Tom Hanks"]) {
//            NSLog(@"Stop for testing");
//        }
        //Cast *ca = (Cast *)[Cast updateOrCreateFromJSONData:cast inContext:_managedObjectContext uniqueSanitizedKey:@"remoteId" save:NO];
         Cast *ca = (Cast *)[Cast modelFromJSONData:cast forEntityName:[Cast entityName] inContext:_managedObjectContext keySanitizer:[Cast keySanitizer]];
        
        // find existing image
        if ([co.casts containsObject:ca]) {
            continue;
        }
        if ([ca validateForInsertOrUpdate:&error]) {
            [co addCastsObject:ca];
        }
    }
    
    
    // update packages
    NSArray *packages = jsonData[@"packages"];
    if (packages) {
        [co removePackages:co.packages];
        for (id pack in packages) {
            Package *pa = (Package *)[Package updateOrCreateFromJSONData:pack inContext:_managedObjectContext uniqueSanitizedKey:@"packageId" save:NO];
            
            NSArray *priceDetails = pack[@"priceDetails"];
            for (id priced in priceDetails) {
                PriceDetail *pd = (PriceDetail *)[PriceDetail modelFromJSONData:priced forEntityName:[PriceDetail entityName] inContext:_managedObjectContext keySanitizer:[PriceDetail keySanitizer]];
                [pa addPriceDetailsObject:pd];
            }
            
            if ([pa validateForInsertOrUpdate:&error]) {
                [co addPackagesObject:pa];
            }
        }
    }
    
    
    NSDictionary *cud = jsonData[@"currentUserData"];
    if (cud) {
        co.currentUserRating = cud[@"rating"];
        co.favorite = cud[@"favorite"];
        
        packages = [co.packages allObjects];
        NSArray *purchases = cud[@"purchase"];
        for (id purchase in purchases) {
            Purchase *pch = (Purchase *)[Purchase modelFromJSONData:purchase forEntityName:[Purchase entityName] inContext:_managedObjectContext keySanitizer:[Purchase keySanitizer]];
            pch.isReceiptValidated = @YES;
            // find package from previous array "packages"
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.packageId = %@", purchase[@"packageId"]];
            NSArray *ar = [packages filteredArrayUsingPredicate:pred];
            if ([ar count]) {
                pch.package = ar[0];
            }
            pch.content = co;
            
            if ([pch validateForInsertOrUpdate:&error]) {
                [co addPurchasesObject:pch];
            }
        }
        
    }
    
    if (![co validateForInsertOrUpdate:&error]) {
        [error logDetailedError];
        
        // ignore object in managed object context
        [_managedObjectContext deleteObject:co];
        
        return nil;
    }
    if (save) {
        NSError *error;
        [_managedObjectContext save:&error];
        [error logDetailedError];
    }
    
    return co;
}



- (Content *)parseDynamicData:(id)object
{
    NSString *remoteId = object[@"_id"];
    Content *c = (Content *)[Content fetchByRemoteId:remoteId context:_managedObjectContext];
    if (!c) {
        c = [Content createNewInManagedObjectContext:_managedObjectContext];
        c.remoteId = remoteId;
    }
    
    // Comments
    NSDictionary *comments = object[@"comments"];
    if (comments) {
        [c removeComments:c.comments];
        
        c.commentsCount = comments[@"numComments"];

        NSArray *comms = comments[@"values"];
        for (id com in comms) {
            Comment *comment = [Comment createNewInManagedObjectContext:_managedObjectContext];
            comment.comment = com[@"comment"];
            comment.userName = com[@"name"];
            comment.timestamp = [NSDate formatStringToDate:com[@"timestamp"]];
            comment.userId = [com[@"userId"] stringValue];
            
            [c addCommentsObject:comment];
        }
    }
    
    // User reviews
    NSDictionary *userReviews = object[@"userReviews"];
    if (userReviews) {
        [c removeUserReviews:c.userReviews];
        NSNumber *rating = userReviews[@"averageRating"];
        c.averageRating = rating;
        c.userRatingsCount = userReviews[@"numUsersRated"];

        NSArray *reviews = userReviews[@"values"];
        for (id review in reviews) {
            UserReview *rev = [UserReview createNewInManagedObjectContext:_managedObjectContext];
            rev.userName = review[@"username"];
            rev.userId = [review[@"userId"] stringValue];
            rev.timestamp = [NSDate formatStringToDate:object[@"timestamp"]];
            rev.review = [review[@"review"] isEqual:[NSNull null]] ? @"" : review[@"review"];
            rev.rating = review[@"rating"];
            rev.owner = c;
            
            [c addUserReviewsObject:rev];
        }
    }
    
    // packages
    
    NSArray *packages = object[@"packages"];
    if ([packages count]) {
        [c removePackages:c.packages];
        for (id package in packages) {
            //for debugging
            if ([package[@"packageId"] isEqualToString:@"S005"]) {
                NSLog(@"Stop");
            }
            //
            
            //We might link same package with distinct contents, so have to delete the old package for each content.
//            Package *oldPack = (Package *)[Package fetchByRemoteId:package[@"packageId"] context:_managedObjectContext];
//            if (oldPack) {
//                [_managedObjectContext deleteObject:oldPack];
//            }
            //Package *pack = (Package *)[Package modelFromJSONData:package forEntityName:[Package entityName] inContext:_managedObjectContext keySanitizer:nil];
            Package *pack = (Package *)[Package updateOrCreateFromJSONData:package inContext:_managedObjectContext uniqueSanitizedKey:@"packageId" save:NO];
            //Package *pack = (Package *)[Package createNewInManagedObjectContext:_managedObjectContext];
            NSArray *pd = package[@"priceDetails"];
            if (pd) {
                for (id priceDetail in pd) {
                    PriceDetail *price = [PriceDetail createNewInManagedObjectContext:_managedObjectContext];
                    price.doubleConfirmation = priceDetail[@"doubleConfirmation"];
                    price.name = priceDetail[@"name"];
                    price.paymentChannel = priceDetail[@"paymentChannel"];
                    price.price = priceDetail[@"price"];
                    price.webBased = priceDetail[@"webBased"];
                    
                    [pack addPriceDetailsObject:price];
                }
            }
            [pack addOwnersObject:(id)c];
            //pack.owner = c;
            
            [c addPackagesObject:pack];
        }
    }
    
    // Current user data
    NSDictionary *currentUserData = object[@"currentUserData"];
    if (currentUserData) {
        c.favorite = currentUserData[@"favorite"];
        c.currentUserRating = currentUserData[@"rating"];
        
        packages = [c.packages allObjects];
        
        //remove all purchases assosiated with this content because its dynamic data if purchse expired at server we shoud remove it.
        //[c removePurchases:c.purchases];
        //c.purchased = @NO;
        //check for purchases and update the database.
        NSArray *purchases = currentUserData[@"purchase"];
        if ([purchases count]) {
            [c removePurchases:c.purchases];
            for (id purchase in purchases) {
                
//                NSArray *purchases_ = [_managedObjectContext fetchObjectsForEntityName:@"Purchase" withPredicate:[NSPredicate predicateWithFormat:@"self.package.packageId == %@",purchase[@"packageId"]]];
//                
//                BOOL isPurchaceValid = NO;
//                
//                for (Purchase *purchase_ in purchases_) {
//                    
//                    if ([self isNotNull:purchase_.validity]) {
//                        isPurchaceValid = [self isPurchaseValid:purchase_.validity];
//                    }
//                }
//                
//                if (isPurchaceValid) {
//                    continue;
//                }
                
                Purchase *pur = (Purchase *)[Purchase modelFromJSONData:purchase forEntityName:[Purchase entityName] inContext:_managedObjectContext keySanitizer:[Purchase keySanitizer]];
                pur.content = c;
                pur.isReceiptValidated = @YES;
                // find package from previous array "packages"
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.packageId = %@", purchase[@"packageId"]];
                NSArray *ar = [packages filteredArrayUsingPredicate:pred];
                if ([ar count]) {
                    pur.package = ar[0];
                }
                //updated content purchased flag to true as we got the purchases for this content.
                c.purchased = @YES;
                NSError *error;
                if ([pur validateForInsertOrUpdate:&error]) {
                    [c addPurchasesObject:pur];
                }
            }
        }
    }

    return c;
}

@end
