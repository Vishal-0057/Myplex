//
//  RelatedSection.h
//  Transitions
//
//  Created by Igor Ostriz on 10/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RelatedItem;
@interface RelatedSection : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic) BOOL expanded;
@property (nonatomic, readonly) CGSize maxSize;

- (void)addRelatedItem:(RelatedItem *)item;
- (BOOL)removeRelatedItem:(RelatedItem *)item;


@end
