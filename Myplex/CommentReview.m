//
//  CommentReview.m
//  Myplex
//
//  Created by Igor Ostriz on 20/11/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "AppData.h"
#import "CommentReview.h"
#import "ServerStandardRequest.h"
#import "UIAlertView+Blocks.m"

@implementation CommentReview
{
    NSManagedObjectContext* _managedObjectContext;
}


- (id)initWithManagedObjectContext: (NSManagedObjectContext*)moc
{
	self = [super init];
	if (self) {
		_managedObjectContext = moc;
	}
	
	return self;
}


- (void)addComment:(NSString *)comment toContent:(NSString *)remoteId andCompletionHandler:(void(^)(id response, NSError *error))block;
{
    NSString *path = [NSString stringWithFormat:@"user/content/%@/comment", remoteId];
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey, @"comment":comment};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeCreate completionHandler:^(id jsonData, NSError* error) {
        
        block(jsonData, error);

    }];
}

- (void)getCommentsOfContent:(NSString *)remoteId andCompletionHandler:(void(^)(id response, NSError *error))block;
{
    //https://api-beta.myplex.in/content/v2/contentDetail/195/?clientKey=9c8603bce96d11980d9e1f3b4d69b729858a8a462f7a54327140568d08e0a3c8&level=devicemax&count=10&fields=comments
    
    NSString *path = [NSString stringWithFormat:@"content/contentDetail/%@/", remoteId];
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey,@"fields":@"comments"};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        block(jsonData, error);
        
    }];
}

- (void)addReview:(NSString *)review andRating:(CGFloat)rating toContent:(NSString *)remoteId andCompletionHandler:(void (^)(id response, NSError *))block
{
    NSString *path = [NSString stringWithFormat:@"user/content/%@/rating", remoteId];
    NSMutableDictionary *params = [@{@"clientKey":[AppData shared].clientKey} mutableCopy];
    
    if (review) {
        params[@"review"] = review;
    }
    if (rating >= 0) {
        params[@"rating"] = [[NSNumber numberWithFloat:rating] stringValue];
    }
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeCreate completionHandler:^(id jsonData, NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && jsonData[@"message"]) {
                [UIAlertView alertViewWithTitle:kAppTitle message:jsonData[@"message"]];
            }
            block(jsonData, error);
        });
    }];
}

- (void)getReviewsOfContent:(NSString *)remoteId andCompletionHandler:(void(^)(id response, NSError *error))block {
    
    //https://api-beta.myplex.in/content/v2/contentDetail/195/?clientKey=9c8603bce96d11980d9e1f3b4d69b729858a8a462f7a54327140568d08e0a3c8&level=devicemax&count=10&fields=reviews/user
    
    NSString *path = [NSString stringWithFormat:@"content/contentDetail/%@/", remoteId];
    NSDictionary *params = @{@"clientKey":[AppData shared].clientKey,@"fields":@"reviews/user"};
    
    //When a function returns a result that you don't need you can cast it to void to eliminate the compiler warning:
    (void)[[ServerStandardRequest alloc] initWithPath:path jsonData:params requestType:ServerStandardRequestTypeRead completionHandler:^(id jsonData, NSError* error) {
        
        block(jsonData, error);
        
    }];
}
@end
