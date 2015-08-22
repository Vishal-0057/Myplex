//
//  CardRelated.m
//  Myplex
//
//  Created by Igor Ostriz on 9/24/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "CardRelated.h"
#import "CellBlock1.h"
#import "Content+Utils.h"
#import "ExtrasCell.h"
#import "Image+Utils.h"
#import "RelatedItem.h"
#import "RelatedMultimedia.h"
#import "RelatedSection.h"
#import "RelatedViewController.h"
#import "SimilarContent.h"
#import "StackedLayoutBase.h"
#import "TimelineView.h"
#import "TitleReusableView.h"


static CGFloat kMaxRelatedCollectionViewHeight = 200;


@interface CardRelated () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation CardRelated
{
    __weak IBOutlet UIButton *_expanderButton;
    BOOL _expanded;
    
    
    NSMutableArray *_sections;
    
    StackedLayoutSingleRow *_stackedRow;
    StackedLayoutSingleColumn *_stackedColumn1, *_stackedColumn2;
    StackedLayoutSingleColumn *_currentStackedColumn;
}


+ (CGSize)size
{
    return CGSizeMake(308, 106);
}

- (CGSize)size
{
    return self.contentView.frame.size;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;

    
    _currentStackedColumn = _stackedColumn1;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotificationCardImageDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotificationCardDetailsRefreshed object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) reload
{
    _sections = [NSMutableArray array];
    
    if ([self.content.relatedMultimedia count]) {
        RelatedSection *sec = [RelatedSection new];
        sec.name = @"Related";
        [_sections addObject:sec];
        for (RelatedMultimedia *media in self.content.relatedMultimedia) {
            RelatedItem *ri = [[RelatedItem alloc] initWithName:media.content.title];
            ri.image = media.content.imageSuitableForBrowse;
            [sec addRelatedItem:ri];
        }
    }
    
    if ([self.content.similarContent count]) {
        RelatedSection *sec = [RelatedSection new];
        sec.name = @"Similar";
        [_sections addObject:sec];
        for (SimilarContent *similar in self.content.similarContent) {
            RelatedItem *ri = [[RelatedItem alloc] initWithName:similar.content.title];
            [sec addRelatedItem:ri];
        }
    }

    _stackedRow = [StackedLayoutSingleRow new];
    _stackedRow.sections = _sections;
    
    _stackedColumn1 = [StackedLayoutSingleColumn new];
    _stackedColumn1.sections = _sections;
    
    _stackedColumn2 = [StackedLayoutSingleColumn new];
    _stackedColumn2.sections = _sections;
    
    [self.collectionView reloadData];
    
}

- (void)setContent:(Content *)content
{
    if (_content == content) {
        return;
    }
    _content = content;
    [self reload];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[ExtrasCell class] forCellWithReuseIdentifier:@"ExtrasCellID"];
    [self.collectionView registerClass:[TitleReusableView class] forSupplementaryViewOfKind:SectionLayoutTitleKind withReuseIdentifier:@"TitleCellID"];
    [self.collectionView setCollectionViewLayout:_stackedRow];

    [content refreshCard];
}

- (IBAction)expand:(UIButton *)sender
{
    _expanded = !_expanded;
    
    NSLog(@"collectionView.height:%5.1f, contentView.height:%4.1f", self.collectionView.frame.size.height, self.collectionView.contentSize.height);
    
    [_expanderButton setBackgroundImage:[UIImage imageNamed:_expanded ? @"collapse-triangle" : @"expand-triangle"] forState:UIControlStateNormal];
    
    
    if ([self.collectionView.collectionViewLayout isKindOfClass:[StackedLayoutSingleRow class]]) {
        [self setCollectionViewSize:[_stackedColumn1 collectionViewContentSize].height];
        [self.collectionView setCollectionViewLayout:_stackedColumn1 animated:YES completion:^(BOOL finished) {
            //            [self setCollectionViewSize];
        }];
    } else {
        [_sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setExpanded:NO];
        }];
        
        [self setCollectionViewSize:[_stackedRow collectionViewContentSize].height];
        [self.collectionView setCollectionViewLayout:_stackedRow animated:YES completion:^(BOOL finished) {
            [_stackedRow invalidateLayout];
        }];
    }
    
    
//    [self setNeedsLayout];
    
}


- (void)setCollectionViewSize:(CGFloat)height
{
    [UIView transitionWithView:self.collectionView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGSize sz = self.collectionView.contentSize;
        CGRect f = self.collectionView.frame;
        if (sz.height > kMaxRelatedCollectionViewHeight) {
            sz.height = kMaxRelatedCollectionViewHeight;
        }
        f.size.height =  sz.height;
        self.collectionView.frame = f;
        
        f = self.bounds;
        f.size.height = self.collectionView.frame.origin.y + f.size.height + 20;
        self.bounds = f;
        
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCellLayoutChanged object:self];
    }];
}



#pragma mark - data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    RelatedSection *sec = _sections[section];
    return sec.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExtrasCell *cell = (ExtrasCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ExtrasCellID" forIndexPath:indexPath];
    
    RelatedSection *sec = _sections[indexPath.section];
    RelatedItem *itm = sec.items[indexPath.item];
    
    cell.imageView.image = itm.uiImage;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    TitleReusableView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:SectionLayoutTitleKind withReuseIdentifier:@"TitleCellID" forIndexPath:indexPath];
    
    titleView.titleString = [_sections[indexPath.section] name];    
    [titleView alignCenter:[collectionView.collectionViewLayout isKindOfClass:[StackedLayoutSingleRow class]]];
    
    return titleView;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    StackedLayoutBase *layout = (StackedLayoutBase *)collectionView.collectionViewLayout;
    RelatedSection *sec = layout.sections[indexPath.section];
    if (sec.expanded) {
        return;
    }
    
    _currentStackedColumn = layout == _stackedColumn1 ? _stackedColumn2 : _stackedColumn1;
    [_currentStackedColumn.sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RelatedSection *sec2 = obj;
        if (sec2 == sec)
            sec2.expanded = YES;
        else
            sec2.expanded = NO;
    }];
    
    [self setCollectionViewSize:[_currentStackedColumn collectionViewContentSize].height];
    [self.collectionView setCollectionViewLayout:_currentStackedColumn animated:YES];
    [self.collectionView.collectionViewLayout invalidateLayout];
}






#pragma mark - Notifications handler
- (void)notificationReceived:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;

    if (notification.name == kNotificationCardImageDownloaded) {
        for (RelatedSection *sec in _sections) {
            for (RelatedItem *itm in sec.items) {
                if (dict[@"url"]) {
                    ;
                }
            }
        }
        [self reload];
    }
    
    if (notification.name == kNotificationCardDetailsRefreshed) {
        [self reload];
    }
}


@end
