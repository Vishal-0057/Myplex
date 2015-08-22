//
//  Content.h
//  Myplex
//
//  Created by shiva on 3/18/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Award, Cast, CertifiedRating, Comment, ContentGenre, CriticReview, Image, OnSelectAction, Package, Purchase, RelatedMultimedia, SimilarContent, Tag, UserReview, Video;

@interface Content : NSManagedObject

@property (nonatomic, retain) NSNumber * averageRating;
@property (nonatomic, retain) NSString * briefDescription;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSNumber * currentUserRating;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * drmEnabled;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSNumber * elapsedTime;
@property (nonatomic, retain) NSDate * expiresAt;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * is3D;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * myPlexDescription;
@property (nonatomic, retain) NSNumber * purchased;
@property (nonatomic, retain) NSString * releaseDate;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * studioDescription;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * userRatingsCount;
@property (nonatomic, retain) id matchStatus;
@property (nonatomic, retain) id matchInfo;
@property (nonatomic, retain) NSSet *awards;
@property (nonatomic, retain) NSSet *casts;
@property (nonatomic, retain) NSSet *certifiedRatings;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *criticReviews;
@property (nonatomic, retain) NSSet *genres;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *onSelectActions;
@property (nonatomic, retain) NSSet *packages;
@property (nonatomic, retain) NSSet *purchases;
@property (nonatomic, retain) NSSet *relatedMultimedia;
@property (nonatomic, retain) NSSet *similarContent;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *userReviews;
@property (nonatomic, retain) NSSet *videos;
@end

@interface Content (CoreDataGeneratedAccessors)

- (void)addAwardsObject:(Award *)value;
- (void)removeAwardsObject:(Award *)value;
- (void)addAwards:(NSSet *)values;
- (void)removeAwards:(NSSet *)values;

- (void)addCastsObject:(Cast *)value;
- (void)removeCastsObject:(Cast *)value;
- (void)addCasts:(NSSet *)values;
- (void)removeCasts:(NSSet *)values;

- (void)addCertifiedRatingsObject:(CertifiedRating *)value;
- (void)removeCertifiedRatingsObject:(CertifiedRating *)value;
- (void)addCertifiedRatings:(NSSet *)values;
- (void)removeCertifiedRatings:(NSSet *)values;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addCriticReviewsObject:(CriticReview *)value;
- (void)removeCriticReviewsObject:(CriticReview *)value;
- (void)addCriticReviews:(NSSet *)values;
- (void)removeCriticReviews:(NSSet *)values;

- (void)addGenresObject:(ContentGenre *)value;
- (void)removeGenresObject:(ContentGenre *)value;
- (void)addGenres:(NSSet *)values;
- (void)removeGenres:(NSSet *)values;

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addOnSelectActionsObject:(OnSelectAction *)value;
- (void)removeOnSelectActionsObject:(OnSelectAction *)value;
- (void)addOnSelectActions:(NSSet *)values;
- (void)removeOnSelectActions:(NSSet *)values;

- (void)addPackagesObject:(Package *)value;
- (void)removePackagesObject:(Package *)value;
- (void)addPackages:(NSSet *)values;
- (void)removePackages:(NSSet *)values;

- (void)addPurchasesObject:(Purchase *)value;
- (void)removePurchasesObject:(Purchase *)value;
- (void)addPurchases:(NSSet *)values;
- (void)removePurchases:(NSSet *)values;

- (void)addRelatedMultimediaObject:(RelatedMultimedia *)value;
- (void)removeRelatedMultimediaObject:(RelatedMultimedia *)value;
- (void)addRelatedMultimedia:(NSSet *)values;
- (void)removeRelatedMultimedia:(NSSet *)values;

- (void)addSimilarContentObject:(SimilarContent *)value;
- (void)removeSimilarContentObject:(SimilarContent *)value;
- (void)addSimilarContent:(NSSet *)values;
- (void)removeSimilarContent:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addUserReviewsObject:(UserReview *)value;
- (void)removeUserReviewsObject:(UserReview *)value;
- (void)addUserReviews:(NSSet *)values;
- (void)removeUserReviews:(NSSet *)values;

- (void)addVideosObject:(Video *)value;
- (void)removeVideosObject:(Video *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

@end
