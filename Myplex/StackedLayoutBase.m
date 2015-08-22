//
//  StackedLayout.m
//  Myplex
//
//  Created by Igor Ostriz on 10/9/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "RelatedItem.h"
#import "RelatedSection.h"
#import "StackedLayoutBase.h"
#import "TimelineView.h"


static NSString * const SectionLayoutExtrasCellKind = @"ExtrasCell";
NSString * const SectionLayoutTitleKind = @"ExtrasTitle";
NSString * const SectionLayoutTitleDetailedKind = @"ExtrasTitleDetailed";
static NSString * const SectionLayoutTimelineKind = @"Timeline";

static NSUInteger const RotationCount = 32;
static NSUInteger const RotationStride = 3;
static NSUInteger const PhotoCellBaseZIndex = 100;

static CGFloat const ItemInsetLeft = 12;
static CGFloat const ItemInsetTop = 0;
static CGFloat const ItemInsetBottom = 22;
static CGFloat const InterItemSpacing = 20;
static CGFloat const TitleHeight = 26;


@implementation StackedLayoutBase
{
    NSDictionary *_layoutInfo;
    NSArray *_rotations;
}


- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    // create rotations at load so that they are consistent during prepareLayout
    NSMutableArray *rotations = [NSMutableArray arrayWithCapacity:RotationCount];
    
    CGFloat percentage = 0.0f;
    for (NSInteger i = 0; i < RotationCount; i++) {
        // ensure that each angle is different enough to be seen
        CGFloat newPercentage = 0.0f;
        do {
            newPercentage = ((CGFloat)(arc4random() % 220) - 110) * 0.0001f;
        } while (fabsf(percentage - newPercentage) < 0.006);
        percentage = newPercentage;
        
        CGFloat angle = 2 * M_PI * (1.0f + percentage);
        CATransform3D transform = CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
        
        [rotations addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    _rotations = rotations;
}


- (CATransform3D)transformForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger offset = (indexPath.section * RotationStride + indexPath.item);
    CATransform3D mat = [_rotations[offset % RotationCount] CATransform3DValue];
    RelatedSection *sec = _sections[indexPath.section];
    if (sec.expanded || sec.items.count < 2) {
        mat = CATransform3DIdentity;
    }
    return mat;
}



- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectZero;
}


- (CGRect)frameForTitleAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = [self frameForItemAtIndexPath:indexPath];

    frame.origin.y += frame.size.height + InterItemSpacing;
    frame.size.height = TitleHeight;
    
    return frame;

}

- (CGRect)frameForTimelineAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectZero;
}


#pragma mark - layout overrides
- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *titleLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *timelineLayoutInfo = [NSMutableDictionary dictionary];
    
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        RelatedSection *sec = nil;
        if (_sections.count > section) {
            sec = _sections[section];
        }
        NSInteger itemCount = [sec.items count];    //[self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForItemAtIndexPath:indexPath];
            itemAttributes.transform3D = [self transformForItemAtIndexPath:indexPath];
            itemAttributes.zIndex = PhotoCellBaseZIndex + itemCount - item;
            cellLayoutInfo[indexPath] = itemAttributes;
            
            UICollectionViewLayoutAttributes *titleAttributes;
            if ([self isKindOfClass:[StackedLayoutSingleRow class]] && indexPath.item == 0)
            {
                titleAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SectionLayoutTitleKind withIndexPath:indexPath];
                titleAttributes.frame = [self frameForTitleAtIndexPath:indexPath];
                titleAttributes.zIndex = 1;
                titleAttributes.hidden = NO;
                titleLayoutInfo[indexPath] = titleAttributes;
            }
            
            if ([self isKindOfClass:[StackedLayoutSingleColumn class]] && (indexPath.item == 0 || sec.expanded))
            {
                titleAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SectionLayoutTitleDetailedKind withIndexPath:indexPath];
                titleAttributes.frame = [self frameForTitleAtIndexPath:indexPath];

                UICollectionViewLayoutAttributes *timelineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SectionLayoutTimelineKind withIndexPath:indexPath];
                timelineAttributes.frame = [self frameForTimelineAtIndexPath:indexPath];
                timelineLayoutInfo[indexPath] = timelineAttributes;
                titleLayoutInfo[indexPath] = titleAttributes;
            }
            
        }
    }
    
    newLayoutInfo[SectionLayoutExtrasCellKind] = cellLayoutInfo;
    newLayoutInfo[SectionLayoutTitleKind] = titleLayoutInfo;
    newLayoutInfo[SectionLayoutTimelineKind] = timelineLayoutInfo;
    _layoutInfo = newLayoutInfo;
    
    [self registerClass:[TimelineView class] forDecorationViewOfKind:SectionLayoutTimelineKind];

}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:_layoutInfo.count];
    
    [_layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, NSDictionary *elementsInfo, BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *la = _layoutInfo[SectionLayoutExtrasCellKind][indexPath];
    NSLog(@"Item: ===> section:%i, item:%i, la:%@", indexPath.section, indexPath.row, la);
    return la;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *la = _layoutInfo[SectionLayoutTitleKind][indexPath];
    NSLog(@"\nSupplement:   =>section:%i, item:%i, la:%@\n", indexPath.section, indexPath.row, la);
    return la;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    return _layoutInfo[SectionLayoutTimelineKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    return CGSizeZero;
}



@end





@implementation StackedLayoutSingleRow

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // single row
    NSInteger column = indexPath.section;
    CGFloat originX = ItemInsetLeft;
    if (column > 0) {
        for (int col = 0; col < column; ++col)
            originX += [self.sections[col] maxSize].width + InterItemSpacing;
    }
    CGFloat originY = ItemInsetTop;
    RelatedItem *item = [self.sections[column] items][indexPath.item];
    
    CGRect r = CGRectMake(originX, originY, [item size].width, [item size].height);
    return r;

}

- (CGSize)collectionViewContentSize
{
    CGSize sz = CGSizeZero;
    for (int c = 0; c < [self.sections count]; c++) {
        sz.width += [self.sections[c] maxSize].width;
        CGFloat h = [self.sections[c] maxSize].height;
        if (sz.height < h) {
            sz.height = h;
        }
    }
    sz.height += ItemInsetTop + ItemInsetBottom + TitleHeight;
    return sz;
}

@end


@implementation StackedLayoutSingleColumn

- (void)setup
{
    [super setup];
}

- (CGRect)frameForTitleAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = [self frameForItemAtIndexPath:indexPath];
    
    frame.origin.x += frame.size.width + InterItemSpacing;
    frame.size.width = self.collectionView.bounds.size.width - frame.origin.x;// - InterItemSpacing;
//    frame.size.height = TitleHeight;
    
    return frame;
}

- (CGRect)frameForTimelineAtIndexPath:(NSIndexPath *)indexPath
{
    RelatedSection *sec = self.sections[indexPath.section];

    CGFloat originX = ItemInsetLeft;
    CGFloat originY = ItemInsetTop;
    for (int r = 0; r < indexPath.section; ++r) {
        RelatedSection *sc = self.sections[r];
        if (sc.expanded) {
            for (RelatedItem *itm in [sc items]) {
                originY += [itm size].height + InterItemSpacing;
            }
            
        } else
            originY += ([sc maxSize].height + InterItemSpacing);
    }
    CGFloat height = [sec maxSize].height + InterItemSpacing;
    if (sec.expanded) {
        for (int i = 0; i < indexPath.item; i++)
            originY += [sec.items[i] size].height + InterItemSpacing;
        
        height = [sec.items[indexPath.item] size].height + InterItemSpacing ;
    }
    CGRect r = CGRectMake(originX, originY, [TimelineView defaultWidth], height);
    return r;
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RelatedSection *sec = self.sections[indexPath.section];
    CGSize sz = sec.maxSize;
    CGFloat originX = ItemInsetLeft + [TimelineView defaultWidth] + ItemInsetLeft;
    CGFloat originY = ItemInsetTop;
    for (int r = 0; r < indexPath.section; ++r) {
        RelatedSection *sc = self.sections[r];
        if (sc.expanded) {
            for (RelatedItem *itm in [sc items]) {
                originY += [itm size].height + InterItemSpacing;
            }
            
        } else
            originY += ([sc maxSize].height + InterItemSpacing);
    }
    if (sec.expanded) {
        for (int i = 0; i < indexPath.item; i++)
            originY += [sec.items[i] size].height + InterItemSpacing;
        
        RelatedItem *item = [sec items][indexPath.item];
        sz = [item size];
    }
    CGRect r = CGRectMake(originX, originY, sz.width, sz.height);

    return CGRectMake(originX, originY, r.size.width, r.size.height);
}

- (CGSize)collectionViewContentSize
{
    CGSize sz = CGSizeZero;
    sz.width = self.collectionView.bounds.size.width;
    for (int r = 0; r < [self.sections count]; ++r) {
        RelatedSection *sec = self.sections[r];
        if (sec.expanded) {
            for (int i = 0; i < [sec.items count]; i++)
                sz.height += [sec.items[i] size].height + InterItemSpacing;
        } else
            sz.height += [sec maxSize].height + InterItemSpacing;
    }
    sz.height += ItemInsetTop + ItemInsetBottom;
    return sz;
}


@end


