//
//  RelatedItem.h
//  Transitions
//
//  Created by Igor Ostriz on 10/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Image;
@class Content;
@interface RelatedItem : NSObject

@property (nonatomic, readonly) UIImage *uiImage;
@property (nonatomic) Image *image;

@property (nonatomic) Content *content;

- (id)initWithName:(NSString *)name;
- (CGSize)size;

@end
