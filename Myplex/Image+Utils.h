//
//  Image+Utils.h
//  Myplex
//
//  Created by Igor Ostriz on 9/30/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "Image.h"

@interface Image (Utils)

@property (nonatomic) UIImage *image;
@property (nonatomic) UIImage *browseImage;
@property (nonatomic) UIImage *browseImage2;

@property (nonatomic, assign) BOOL downloading;

- (BOOL)isContainedIn:(NSSet *)setOfImages;
- (void)fetchImage;


+ (NSDictionary *)downloadingImages;
+ (void)clearCacheIfPossible;


@end
