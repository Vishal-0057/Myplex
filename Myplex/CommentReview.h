//
//  CommentReview.h
//  Myplex
//
//  Created by Igor Ostriz on 20/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentReview : NSObject

- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc;

- (void)addComment:(NSString *)comment toContent:(NSString *)remoteId andCompletionHandler:(void(^)(id response, NSError *error))block;
- (void)getCommentsOfContent:(NSString *)remoteId andCompletionHandler:(void(^)(id response, NSError *error))block;

- (void)addReview:(NSString *)review andRating:(CGFloat)rating toContent:(NSString *)remoteId andCompletionHandler:(void(^)(id response, NSError *error))block;
- (void)getReviewsOfContent:(NSString *)remoteId andCompletionHandler:(void(^)(id response, NSError *error))block;
@end
