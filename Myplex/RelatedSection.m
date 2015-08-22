//
//  RelatedSection.m
//  Transitions
//
//  Created by Igor Ostriz on 10/15/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "RelatedItem.h"
#import "RelatedSection.h"


@implementation RelatedSection
{
    NSMutableArray *_items;
    CGSize _maxSize;
}


- (id)init
{
    self = [super init];
    if  (self) {
        _items = [NSMutableArray new];
    }
    return self;
}


- (NSArray *)items
{
    return [_items copy];
}

- (CGSize)maxSize
{
    return _maxSize;
}

- (void)addRelatedItem:(RelatedItem *)item
{
    [_items addObject:item];
    _maxSize = [self calcMaxSize];
}
- (BOOL)removeRelatedItem:(RelatedItem *)item
{
    if ([_items indexOfObject:item] == NSNotFound) {
        return NO;
    }
    
    [_items removeObject:item];
    _maxSize = [self calcMaxSize];
    return YES;
}

- (CGSize)calcMaxSize
{
    __block CGSize sz;
    
    [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RelatedItem *itm = (RelatedItem *)obj;
        
        if (itm.size.width > sz.width) {
            sz.width = itm.size.width;
        }
        if (itm.size.height > sz.height) {
            sz.height = itm.size.height;
        }
    }];
    
    return sz;
}

@end
