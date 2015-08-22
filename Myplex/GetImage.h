//
//  GetImage.h
//  Myplex
//
//  Created by Igor Ostriz on 29/10/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Image;
@interface GetImage : NSObject

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)moc;
- (void)getImageWithURL:(NSString *)stringURL withPartialData:(void(^)(int received, int expected))partialBlock andCompletionHandler:(void (^)(NSData *, NSError *))completeBlock;

+ (CGSize)getBrowseSize;
+ (CGSize)getBrowseSize2;

@end
