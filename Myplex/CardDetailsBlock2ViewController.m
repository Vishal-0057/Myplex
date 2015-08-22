//
//  CardDetailsBlock2ViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 10/22/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "CardDetailsBlock2ViewController.h"
#import "CardsViewController.h"
#import "ExtrasCell.h"
#import "Image+Utils.h"
#import "RelatedItem.h"
#import "RelatedMultimedia.h"
#import "RelatedSection.h"
#import "SimilarContent.h"
#import "StackedLayoutBase.h"
#import "TitleReusableView.h"
#import "TitleDetailedReusableView.h"
#import "UIImageView+WebCache.h"


static CGFloat kMaxRelatedCollectionViewHeight = 400;



@interface CardDetailsBlock2ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet StackedLayoutBase *stackedLayout;
@property (weak, nonatomic) IBOutlet UIButton *expanderButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end



@implementation CardDetailsBlock2ViewController
{
    NSMutableArray *_sections;
    NSMutableDictionary *_supplementaryViews;
    BOOL _expanded;
    
    StackedLayoutSingleRow *_stackedRow;
    StackedLayoutSingleColumn *_stackedColumn1, *_stackedColumn2;
    StackedLayoutSingleColumn *_currentStackedColumn;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _supplementaryViews = [NSMutableDictionary new];

    self.view.layer.cornerRadius = 5;
    self.view.clipsToBounds = YES;
    
    isIPhone {} else {
        
        self.view.layer.masksToBounds = NO;
        self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.view.layer.shouldRasterize = YES;

    }
    
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];

    [self.collectionView registerClass:[ExtrasCell class] forCellWithReuseIdentifier:@"ExtrasCellID"];
    [self.collectionView registerClass:[TitleReusableView class] forSupplementaryViewOfKind:SectionLayoutTitleKind withReuseIdentifier:@"TitleCellID"];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([TitleDetailedReusableView class]) bundle:nil];
    [self.collectionView registerNib:nib forSupplementaryViewOfKind:SectionLayoutTitleDetailedKind withReuseIdentifier:@"TitleDetailedCellID"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setLayoutWithAnimation:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotificationCardImageDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotificationCardDetailsRefreshed object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setContent:(Content *)content
{
//    if (_content == content) {
//        return;
//    }
    
    _content = content;

    [self reload];
    
    [self.collectionView setCollectionViewLayout:_stackedRow];
    
    if (![_content.similarContent count]) {
        [self.indicatorView startAnimating];
        [content refreshSimilarContent];
    }
}

- (void) reload
{
    _sections = [NSMutableArray array];
    
//    if ([self.content.relatedMultimedia count]) {
//        RelatedSection *sec = [RelatedSection new];
//        sec.name = @"Related";
//        [_sections addObject:sec];
//        for (RelatedMultimedia *media in self.content.relatedMultimedia) {
//            RelatedItem *ri = [[RelatedItem alloc] initWithName:media.content.title];
//
//            Image *img = media.content.imageSuitableForBrowse;
//            if (!img.content) {
//                [img fetchImage];
//            }
//
//            ri.image = img;
//            ri.content = media.content;
//            
//            [sec addRelatedItem:ri];
//        }
//    }

    if ([_content.similarContent count]) {

        RelatedSection *sec = [RelatedSection new];
        sec.name = @"similar";
        [_sections addObject:sec];
        for (SimilarContent *similar in _content.similarContent) {
            RelatedItem *ri = [[RelatedItem alloc] initWithName:similar.content.title];

//            Image *img = similar.content.imageSuitableForBrowse;
//            if (!img.content) {
//                [img fetchImage];
//            }
//
//            ri.image = img;
            ri.content = similar.content;

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

- (void)setLayoutWithAnimation:(BOOL)animate
{
    void (^blck)() = ^{
        StackedLayoutBase *layout = (StackedLayoutBase *)self.collectionView.collectionViewLayout;
        CGSize sz = [layout collectionViewContentSize];
//        CGSize sz = self.collectionView.contentSize;
        
        CGRect f = self.collectionView.frame;
        if (sz.height > kMaxRelatedCollectionViewHeight) {
            sz.height = kMaxRelatedCollectionViewHeight;
        }
        f.size.height =  sz.height;
        self.collectionView.frame = f;
        
        f = self.view.frame;
        f.size.height = CGRectGetMaxY(self.collectionView.frame);// self.collectionView.frame.origin.y + f.size.height;
        self.view.frame = f;
    };
    
    void (^compl)(BOOL) = ^(BOOL finished){

    };

    
    if (animate) {
        [UIView animateWithDuration:0.3 animations:blck completion:compl];
    }
    else {
        blck();
        compl(YES);
    }

}


- (IBAction)expanderClicked:(id)sender
{
    _expanded = !_expanded;
    
    [self.expanderButton setImage:[UIImage imageNamed:_expanded ? @"collapse-triangle" : @"expand-triangle"] forState:UIControlStateNormal];
    
    StackedLayoutBase *newLayout = _stackedColumn1;
    if (!_expanded)
    {
        // collapse all
        [_sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setExpanded:NO];
        }];        
        newLayout = _stackedRow;
    }
    [self.collectionView setCollectionViewLayout:newLayout animated:YES completion:^(BOOL finished) {
//        NSArray *ar = [self.collectionView subviews];
//        NSLog(@"%@", ar);
//        [self.collectionView setNeedsDisplay];

    }];
    [self setLayoutWithAnimation:YES];
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
    
    //cell.imageView.image = itm.uiImage;
    if (indexPath.item == 0) {
        RelatedSection *sec = _sections[indexPath.section];
        RelatedItem *itm = sec.items[indexPath.item];
        Image *img = [itm.content.images anyObject];
        [cell.imageView setImageWithURL:[NSURL URLWithString:img.url] placeholderImage:nil];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (!_expanded) {

        TitleReusableView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:SectionLayoutTitleKind withReuseIdentifier:@"TitleCellID" forIndexPath:indexPath];
        titleView.titleString = [_sections[indexPath.section] name];
//        [titleView alignCenter:[collectionView.collectionViewLayout isKindOfClass:[StackedLayoutSingleRow class]]];
        _supplementaryViews[indexPath] = titleView;
        titleView.hidden = NO;
        return titleView;
    }
    
    TitleDetailedReusableView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:SectionLayoutTitleDetailedKind withReuseIdentifier:@"TitleDetailedCellID" forIndexPath:indexPath];
    
    RelatedSection *sec = nil;
    if (_sections.count > indexPath.section) {
      sec  = _sections[indexPath.section];
    }
    titleView.titleLabel.text = sec.name;
    titleView.subTitleLabel.text = [NSString stringWithFormat:@"(total %d items)",sec.items.count];
    
    return titleView;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([view isKindOfClass:[TitleReusableView class]]) {
        [_supplementaryViews removeObjectForKey:indexPath];
    }
}
 

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RelatedSection *section = _sections[indexPath.section];
    NSArray *cards = [section.items valueForKey:@"content"];
    
    // ugly fallback to cardsviewbrowser
    CardsViewController *cvc;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[CardsViewController class]]) {
            cvc = (CardsViewController *)vc;
            break;
        }
    }
    if (!cvc) {
        cvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CardsViewControllerID"];
    }
    [cvc refreshWithCards:cards];
    [self.navigationController setViewControllers:@[cvc] animated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"StopPlay" object:nil];
    return;
    
    
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
    
    [self.collectionView setCollectionViewLayout:_currentStackedColumn animated:YES];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self setLayoutWithAnimation:YES];
//    [self.collectionView.collectionViewLayout invalidateLayout];
}






#pragma mark - Notifications

- (void)notificationReceived:(NSNotification *)notification
{
    if (notification.name == kNotificationCardImageDownloaded) {
        [self.collectionView reloadData];
    } else if(notification.name == kNotificationCardDetailsRefreshed) {
        //_content = notification.object;
        Content *content_ = notification.object;
        if ([content_.similarContent count]) {
            [self setContent:notification.object];
        }
        [self.indicatorView stopAnimating];
        [self setLayoutWithAnimation:NO];
    }
}





@end
