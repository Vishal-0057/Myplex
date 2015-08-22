//
//  CardDetailsRelatedMultiMediaViewController.m
//  Myplex
//
//  Created by apalya technologies on 2/14/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import "CardDetailsRelatedMultiMediaViewController.h"
#import "RelatedItem.h"
#import "RelatedMultimedia.h"
#import "RelatedSection.h"
#import "SimilarContent.h"
#import "CardView.h"


@interface CardDetailsRelatedMultiMediaViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation CardDetailsRelatedMultiMediaViewController
{
    NSMutableArray *_sections;
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
	// Do any additional setup after loading the view.
    self.view.layer.cornerRadius = 5;
    self.view.clipsToBounds = YES;
    self.view.layer.masksToBounds = NO;
    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.view.layer.shouldRasterize = YES;
    
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];
    [self.indicatorView startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
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
    
//    [self.collectionView setCollectionViewLayout:_stackedRow];
    
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
    
//    _stackedRow = [StackedLayoutSingleRow new];
//    _stackedRow.sections = _sections;
//    
//    _stackedColumn1 = [StackedLayoutSingleColumn new];
//    _stackedColumn1.sections = _sections;
//    
//    _stackedColumn2 = [StackedLayoutSingleColumn new];
//    _stackedColumn2.sections = _sections;
    
    [self.collectionView reloadData];
    
}

#pragma mark- Collection View DataSource Methods

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
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    CardView *cardView = (CardView *)[cell.contentView viewWithTag:1];
    if (cardView == nil) {
        cardView = [CardView card];
        cardView.tag = 1;
        cardView.delegate = self.delegate;
        [cell.contentView addSubview:cardView];
    }

    [cardView setContent:[[[_sections[indexPath.section] items] objectAtIndex:indexPath.row] content]];
    return cell;
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
//        [self setLayoutWithAnimation:NO];
    }
}

#pragma mark - autoraotation support

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    isIPhone
    return UIInterfaceOrientationPortrait;
    else
        return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}

@end
