//
//  CardsViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 9/9/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//


#import "AppData.h"
#import "AppDelegate.h"
#import "CardDetailsAnimatedTransitioning.h"
#import "CardDetailsViewController.h"
#import "CardsViewController.h"
#import "CardView.h"
#import "CardViewReusePool.h"
#import "Content+Utils.h"
#import "Genre.h"
#import "Image+Utils.h"
#import "MenuButton.h"
#import "Notifications.h"
#import "NSManagedObjectContext+Utils.h"
#import "PaymentPickerAnimatedTransitioning.h"
#import "PaymentPickerViewController.h"
#import "RESideMenu.h"
#import "UIAlertView+ReportError.h"
#import "UIAlertView+Blocks.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+ShowModalFromView.h"
#import "Mixpanel.h"
#import "IpadMainViewController.h"

static const int TOP_CARDS = 1;
static const int TOP_CARD_VISIBLE_PT = 6;
static const int TOP_MARGIN = 14;//TOP_CARDS * TOP_CARD_VISIBLE_PT;
static const int PLAY_FADEIN_AT = 95;

static const int CARD_WIDTH = 308;
static const int CARD_HEIGHT = 256;

//static const int N = 10;
static const int positions[] = {0, 263, 352, 415, 448};
static const int numPositions = sizeof(positions) / sizeof(int);

@interface CardsViewController () <UIScrollViewDelegate, CardViewDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, MenuButtonDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *watermarkImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshActivity;


@property (nonatomic) CardViewReusePool *cardViewReusePool;
@property (nonatomic, readonly) PaymentPickerTransitioningDelegate *paymentTransitioningDelegate;


@end



@implementation CardsViewController
{
    NSArray *__cards;
    CardBrowseType _currentType;
    MenuButton *_menuButton;
    NSString *_query;           // query used for searching
    NSString *_filterString;    // selected genre in drop down
    CardView *_tappedCard;
}

@synthesize paymentTransitioningDelegate = _paymentTransitioningDelegate;




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    self.cardViewReusePool = [CardViewReusePool new];
    //_currentType = -1;
    
//    _queue = [[NSOperationQueue alloc] init];
//    _queue.maxConcurrentOperationCount = 3;
//    
    [self.progressView setHidden:YES];
    isIPhone
        self.navigationItem.titleView = [self getMenuView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotificationCardImageDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefreshCards:) name:kNotificationCardsRefreshed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressUpdate:) name:kNotificationCardImageProgressBar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefreshCards:) name:kNotificationUserAuthenticated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefreshCards:) name:kNotificationGetProfile object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefreshCards:) name:kNotificationPurchaseSuccess object:nil];

    
#ifdef DEBUG
    UIRefreshControl *refreshControll = [[UIRefreshControl alloc] init];
    [refreshControll addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:refreshControll];
#endif
    isIPhone
        [self doRefresh:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [self updateWatermark];
}

-(UIView *)getMenuView {
    
    CGRect menuFrame;
    isIPhone
    menuFrame = CGRectMake(50, 0, 220, 44);
    else
        menuFrame = CGRectMake(0, 0, 256, 44);
    
    UIView *menuView = [[UIView alloc] initWithFrame:menuFrame];
    menuView.backgroundColor = [UIColor clearColor];
    
    _menuButton = [[MenuButton alloc] initWithMaxFrame:menuView.frame];
    _menuButton.delegate = self;
    _menuButton.backgroundColor = [UIColor clearColor];
    _menuButton.center = CGPointMake(CGRectGetMidX(menuView.bounds), CGRectGetMidY(menuView.bounds));
    _menuButton.items = @[@"All", @"Comedy", @"Documentary", @"Music", @"Action", @"Adventure", @"Drama", @"Romance", @"Foreign", @"Fantasy Adventure", @"Fantasy", @"Crime", @"Mistery", @"Paranormal", @"Science Fiction", @"Family"];
    [menuView addSubview:_menuButton];
    return menuView;
}

- (NSArray *)cardds
{
    NSArray *ar = __cards;
    if ([_filterString length]) {
        // predicat made
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY genres.genre.name CONTAINS[c] %@",_filterString];
        ar = [[ar filteredArrayUsingPredicate:pred] copy];
    }
    return ar;
}

- (PaymentPickerTransitioningDelegate *)paymentTransitioningDelegate
{
    if (!_paymentTransitioningDelegate) {
        _paymentTransitioningDelegate = [PaymentPickerTransitioningDelegate new];
    }
    return _paymentTransitioningDelegate;
}

- (void)swipeHandler:(UIPanGestureRecognizer *)sender
{
    [[self sideMenu] showFromPanGesture:sender];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCardsPosition:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.delegate = self;
    [super viewWillAppear:animated];
}

- (NSString *)stringFromQueryType {
    static NSDictionary *predicates;
    if (!predicates) {
        predicates = @{@(CardsAll): @"", @(CardsRecommendations):@"movie", @(CardsMovies):@"movie", @(CardsTVShows):@"show", @(CardsLiveTV):@"live", @(CardsFIFA):@"sportsevent"};
    }
    
    if ((int)_currentType == -1)
        return @"";
    return predicates[@(_currentType)];
}

- (NSString *)titleStringFromQueryType {
    static NSDictionary *predicates;
    if (!predicates) {
        predicates = @{@(CardsAll): @"", @(CardsRecommendations):@"Fifa Live", @(CardsMovies):@"movies", @(CardsTVShows):@"tv shows", @(CardsLiveTV):@"live tv", @(CardsFIFA):@"Fifa Matches"};
    }
    
    if ((int)_currentType == -1)
        return @"";
    return predicates[@(_currentType)];
}

- (void)doRefresh:(UIRefreshControl *)refreshControll
{
    switch (_currentType) {
        case CardsNone:
        case CardsAll:
        case CardsRecommendations:
            [Content refreshRecommendedCards];
            break;
        case CardsSearch:
            [Content refreshCardsForSearchWithQuery:_query];
//            [Content refreshFavoriteCards];
            break;
        case CardsPurchased:
            [Content refreshPurchasedCards];
            break;
        case CardsTVShows:
        case CardsLiveTV:
        case CardsMovies:
        case CardsFIFA:
            [Content refreshCardsWithType:[self stringFromQueryType]];
            break;
        case CardsFavorites:
            [Content refreshFavoriteCards];
            break;
        case CardsSelected:
        default:
            break;
    }
    
    [self startSpinningActivity];

    [self refresh];
    [refreshControll endRefreshing];
}


- (void)doRefreshMore
{
    if (_currentType == CardsRecommendations || _currentType == CardsNone) {
        [Content refreshMoreRecommendedCards];
    }
    else if (_currentType == CardsSearch) {
        [Content refreshMoreCardsForSearchWithQuery:_query];
    }
    else
        [Content refreshMoreCardsWithType:[self stringFromQueryType]];
    
    [self startSpinningActivity];
}

-(void)showDeletedCards {
    
    [Content updateCardsDeleteStatus];
    
}

- (void)refresh:(CardBrowseType)browseType
{
//    if (_currentType == browseType) {
//        return;
//    }
    _currentType = browseType;
    _filterString = @"";
    
    if (self.isViewLoaded) {
        [self refresh];
        [self doRefresh:nil];
        [self.scrollView setContentOffset:CGPointZero];
    }
}

- (void)refreshWithCards:(NSArray *)cards
{
    _currentType = CardsSelected;
    __cards = cards;
    _filterString = @"";
    [self refresh];
    [self doRefresh:nil];
}

- (void)refreshWithSearchQuery:(NSString *)query
{
    _currentType = CardsSearch;
    _query = query;
    _filterString = @"";
    [self refresh];
    [self doRefresh:nil];
}


- (void)refresh
{
    switch (_currentType) {
        case CardsNone:
        case CardsRecommendations:
            __cards = [Content getRecommendedCards];
            _menuButton.title = @"Viva";
            break;
        case CardsFavorites:
            __cards = [Content getFavoriteCards];
            _menuButton.title = @"Favorites";
            break;
        case CardsSelected:
            _menuButton.title = @"Viva";
            //_menuButton.title = @"selection";
            break;
        case CardsSearch:
            __cards = [Content getCardsForSearchWithQuery:_query];
            _menuButton.title = [NSString stringWithFormat:@"Search: %@", _query];
            break;
        case CardsPurchased:
            __cards = [Content getPurchasedCards];
            _menuButton.title = @"Purchased";
            break;
        default:
            __cards = [Content getCardsWithType:[self stringFromQueryType]];
            _menuButton.title = [self titleStringFromQueryType];
            break;
    }
    
    [self loadFirstCardForIpad];

    [_menuButton setSubTitle:_filterString];
    [Image clearCacheIfPossible];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, [self getN] * positions[1] + self.scrollView.frame.size.height);
    [self updateCardsPosition:YES];
}

-(void) loadFirstCardForIpad
{
    isIPhone {} else {
        if ([__cards count] && !_tappedCard) {
            id content = [self getCard:0];
            [self cardTapped:content];
        }
    }
}

- (NSInteger)getN
{
    return [[self cardds] count];
}

- (Content *)getCard:(int)i
{
    if ([[self cardds]count] > i) {
        Content *c = (Content *)[[self cardds] objectAtIndex:i];
        return c;
    }
    return nil;
}

- (NSArray *)visibleCards
{
    NSMutableArray *cards = [NSMutableArray array];
    
    for (UIView *v in self.scrollView.subviews) {
        if ([v isKindOfClass:[CardView class]]) {
            [cards addObject:v];
        }
    }
    
    [cards sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CardView *v1 = (CardView *)obj1;
        CardView *v2 = (CardView *)obj2;
        
        if (v1.frame.origin.y < v2.frame.origin.y) {
            return NSOrderedAscending;
        }
        if (v1.frame.origin.y > v2.frame.origin.y) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return cards;
}

- (void)loadCardView:(CardView *)cardView forIndex:(int)i
{
    //static UIImage *defaultPreviewImage;
    static NSDictionary *cardTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //defaultPreviewImage = [UIImage imageNamed:@"logowhite"];
        cardTypes = @{ @"movie" : @(ContentTypeMovie), @"tvshow" : @(ContentTypeTVShow), @"livetv" : @(ContentTypeLiveTV) };
    });
    
    cardView.delegate = self;
    cardView.content = [self getCard:i];

// defer loading
//    __weak CardsViewController *weakSelf = self;
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        Content *c = [weakSelf getCard:i];
//        cardView.delegate = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cardView.content = c;
//        });
//    }];
//    [_queue addOperation:operation];
//    cardView.playButton.hidden = YES;
}

- (CardView *)getTopCardForCurrentOffset
{
    CGFloat scrollOffset = MAX(0, self.scrollView.contentOffset.y);
    scrollOffset = MIN(self.scrollView.contentSize.height - self.scrollView.frame.size.height, scrollOffset);
    
    int offset = floor(scrollOffset);
    int iTopCard = (offset / positions[1]);
    CardView* cardView = (CardView *)[self.cardViewReusePool findView:iTopCard];
    return cardView;
}



- (void)changeCardViewFrame:(CGRect)frame index:(int)i forceContentUpdate:(BOOL)forceContentUpdate {

//    CGFloat positionY = frame.origin.y - self.scrollView.contentOffset.y - TOP_MARGIN;
//    NSLog(@"y:%.1f, so:%.1f", self.scrollView.bounds.origin.y, positionY);
    
    CardView* cardView = (CardView *)[self.cardViewReusePool findView:i];
    //NSLog(@"OldCardViewFrame %@, newframe %@",NSStringFromCGRect(cardView.frame),NSStringFromCGRect(frame));
    if (cardView) {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.02];
//        cardView.frame = frame;
//        [UIView commitAnimations];
        
        [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            cardView.frame = frame;
        } completion:^(BOOL finished) {
            if(forceContentUpdate) {
                [self loadCardView:cardView forIndex:i];
            }
         }];
    } else {
        cardView = (CardView *)[self.cardViewReusePool reuseView:i];
        if (cardView) {
            //NSLog(@"reuse");
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.02];
//            cardView.frame = frame;
//            [UIView commitAnimations];
            [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                cardView.frame = frame;
            } completion:^(BOOL finished) {
                [self loadCardView:cardView forIndex:i];
            }];
        } else {
            //NSLog(@"create");
            cardView = [CardView card];
            cardView.frame = frame;
            [self.scrollView addSubview:cardView];
            [self.cardViewReusePool addView:i view:cardView];
            [self loadCardView:cardView forIndex:i];
        }
    }
    
    if (cardView.hidablesView.alpha == 0)
        cardView.hidablesView.alpha = 1;
    
//    [self loadCardView:cardView forIndex:i];

    //    cardView.playButton.alpha = MAX(PLAY_FADEIN_AT - positionY, 0) / PLAY_FADEIN_AT;
    
    [self.scrollView bringSubviewToFront:cardView];
}

- (void)updateCardsPosition:(BOOL)forceContentUpdate
{
    //dispatch_async(dispatch_get_main_queue(), ^{
    CGFloat scrollOffset = MAX(0, self.scrollView.contentOffset.y);
    scrollOffset = MIN(self.scrollView.contentSize.height - self.scrollView.frame.size.height, scrollOffset);
    
    int offset = floor(scrollOffset);
    int iTopCard = (offset / positions[1]);
    int percent = offset % positions[1];
    
    CGFloat y = 0;
    for (int i = MAX(0, iTopCard - TOP_CARDS); i < [self getN]; ++i) {
        int j = i - iTopCard;
        if (j > 0) {
            if (j < numPositions) {
                y = TOP_MARGIN + positions[j] - (positions[j] - positions[j - 1]) * (CGFloat)percent / positions[1];
            } else {
                y += positions[numPositions - 1] - positions[numPositions - 2];
            }
        } else {
            y = MAX(TOP_MARGIN + j * TOP_CARD_VISIBLE_PT, TOP_MARGIN - TOP_CARDS * TOP_CARD_VISIBLE_PT);
        }
        
        if (y > self.scrollView.frame.size.height) {
            break;
        }
        [self changeCardViewFrame:CGRectMake((self.scrollView.frame.size.width-CARD_WIDTH)/2.f, scrollOffset + y /*cardOffset*/, CARD_WIDTH, CARD_HEIGHT) index:i forceContentUpdate:forceContentUpdate];
    }
    
    [self.cardViewReusePool finishUpdate];
    //});
}


- (void)updateWatermark
{
    CGRect frame = self.watermarkImage.frame;
    frame.origin.y = self.scrollView.frame.size.height - 0 + self.scrollView.contentOffset.y - self.watermarkImage.bounds.size.height;
    self.watermarkImage.frame = frame;
    
    frame = self.refreshActivity.frame;
    frame.origin.y = self.watermarkImage.frame.origin.y + 92;
    self.refreshActivity.frame = frame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll Started Updating CardsPostion and its content");
    [self updateCardsPosition:NO];

    [self updateWatermark];
    //NSLog(@"scrollViewDidScroll Completed Updating CardsPostion and its content");

    NSUInteger topCard = scrollView.contentOffset.y / positions[1];
    
    if (!self.refreshActivity.isAnimating && [[self cardds] count] > 9 && topCard > [[self cardds] count]-3) {
        [self doRefreshMore];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat y = targetContentOffset->y;
    
    int iTopCard = floor(y) / positions[1];
    
    CGFloat y1 = iTopCard * positions[1];
    CGFloat y2 = (iTopCard + 1) * positions[1];
    
    y = fabs(y - y1) < fabs(y - y2) ? y1 : y2;
    targetContentOffset->y = y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger topmost = scrollView.contentOffset.y / positions[1];
    
    if (topmost && topmost == [[self cardds] count]-1 && ![self.refreshActivity isAnimating]) {
        [self doRefreshMore];
    }
    
}

- (IBAction)showMore:(UIButton *)sender
{
    [self doRefreshMore];
}

#pragma mark - Card View delegate


- (void)cardTapped:(CardView *)cardView
{
    isIPhone
    {
        CardDetailsViewController *cd = [[UIStoryboard storyboardWithName:@"Details" bundle:nil] instantiateViewControllerWithIdentifier:@"CardDetailsViewControllerID"];
        cd.cardBrowseType = _currentType;
         cd.content = cardView.content;//cardView.content;
        [cd view];
        cd.content = cardView.content;//cardView.content;
        [self.navigationController pushViewController:cd animated:YES];
    }
    else if(self.delegate)
    {
        CardDetailsViewController *cd = (CardDetailsViewController *)self.delegate;
        cd.delegate = self;
        [cd setCardBrowseType:_currentType];
        [cd view];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopPlay" object:nil];
        if ([cardView isKindOfClass:[Content class]]) {
            [cd refreshContent:(Content *)cardView];
        }else if ([cardView isKindOfClass:[CardView class]]) {
            [cd refreshContent:cardView.content];
            [self setTappedCard:cardView];
        }
    }
}

- (IBAction)revealLeft:(id)sender
{
    //[[self revealViewController] revealToggle:sender];
#if DEBUG
    NSLog(@"revealLeft");
#endif
    [self.sideMenu show];
}

- (IBAction)revealRight:(id)sender
{
    //[[self revealViewController] rightRevealToggle:sender];
}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    
    id<UIViewControllerAnimatedTransitioning> animatedTransitioning = nil;
    if ([toVC isKindOfClass:[CardDetailsViewController class]]) {
        animatedTransitioning = [CardDetailsAnimatedTransitioning new];
    }

    return animatedTransitioning;
}

-(void)setTappedCard:(CardView *)cardView {
    _tappedCard = cardView;
}

#pragma mark - MenuButtonDelegate

- (void)menuButton:(MenuButton *)menuButton didSelectItem:(NSString *)string onIndex:(NSUInteger)index
{
    [self setTappedCard:nil];
    _filterString = index > 0 ? string : @"";
    [self refresh];
//    if (index > 0) {
//        [self refreshWithSearchQuery:[string lowercaseString]];
//    }
//    else {
//        [self refresh:CardsRecommendations];
//    }
    
}

-(CGRect)getFrame {
    return self.view.frame;
}

-(NSArray *)loadItems {
    
    NSArray *cards = __cards;
    
    NSArray *genres = [cards valueForKey:@"genres"];
    genres = [genres valueForKey:@"genre"];
    genres = [genres valueForKey:@"name"];
    NSMutableSet *items_ = [NSMutableSet set];
    for (NSSet *genre in genres) {
        if ([self isNotNull:genre] && genre.count > 0) {
            NSArray *allItems = [genre allObjects];
            [items_ addObjectsFromArray:allItems];
        }
    }
    
    NSMutableArray *menuItems = [NSMutableArray array];
    [menuItems addObject:@"All"];
    if (items_.count > 0) {
        [menuItems addObjectsFromArray:[items_ allObjects]];
    }
    return menuItems;
}

#pragma mark - CardViewDelegate

-(void)play:(CardView *)cardView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate cardSelectedWithStatus:YES drmEnabled:cardView.content.drmEnabled.boolValue contentId:cardView.content.remoteId title:cardView.content.title image:@"" packageId:nil delegate:cardView.movieImage];
}

- (void)deleteCard:(CardView *)cardView
{
    [UIAlertView alertViewWithTitle:kDeleteCardTitle message:[NSString stringWithFormat:kDeleteCardMessage,cardView.content.title]cancelBlock:nil dismissBlock:^(int buttonIndex) {
        NSMutableArray *cardsCopy = [[self cardds] mutableCopy];
        [cardsCopy removeObject:cardView.content];
        __cards = cardsCopy;
        
        // deep save into datatbase
        cardView.content.deleted = @YES;
        [cardView.content.managedObjectContext savePropagate];
//        NSMutableArray *cards_ = [__cards mutableCopy];
//        [cards_ removeObject:cardView.content];
//        __cards = cards_;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.cardViewReusePool removeView:cardView];
            [self updateCardsPosition:NO];
            _tappedCard = nil;
            [self loadFirstCardForIpad];
        }];
    } cancelButtonTitle:@"Cancel" otherButtonsTitles:@"Remove", nil];
}

- (void)favoriteCard:(CardView *)cardView favorite:(BOOL)favorite
{
    [cardView.content toggleFavorite];
    cardView.content.favorite = @(![cardView.content.favorite boolValue]);
//    cardView.content.favorite = @(favorite);
//    [cardView.content.managedObjectContext savePropagate];
}


- (void)purchase:(CardView *)cardView
{
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    if (![appDelegate checkAuthentication]) {
//        return;
//    }
    PaymentPickerViewController *vc = [[PaymentPickerViewController alloc] initWithNibName:@"PaymentPickerViewController" bundle:nil];
    vc.view.backgroundColor = [UIColor clearColor];
    vc.content = cardView.content;
    CGRect r = [self.view convertRect:cardView.priceButton.bounds fromView:cardView.priceButton];
    self.paymentTransitioningDelegate.sinkRect = r;
    
    vc.transitioningDelegate = self.paymentTransitioningDelegate;
    
    isIPhone
        vc.modalPresentationStyle = UIModalPresentationCustom;
    else
        vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:vc animated:YES completion:^{
        ;
    }];
}



#pragma mark - Notifications handler
- (void)notificationReceived:(NSNotification *)notification
{
    if (notification.name == kNotificationCardImageDownloaded) {
        if(!self.scrollView.decelerating  && ![self.scrollView isDragging]) {
            NSArray *visibleCards = [self visibleCards];
            [visibleCards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CardView *cardView = (CardView *)obj;
                [cardView refresh];
            }];
        }
    }
}

- (void)notificationRefreshCards:(NSNotification *)notification
{
    
    if (notification.name == kNotificationCardsRefreshed) {
        if (![self.scrollView isDecelerating] && ![self.scrollView isDragging]) {
            [self refresh];
            [self stopSpinningActivity];
        }
    }
    if (notification.name == kNotificationUserAuthenticated) {
        
        [[NSURLCache sharedURLCache]removeAllCachedResponses];

        _currentType = CardsRecommendations;
        [self doRefresh:nil];
    }
    if (notification.name == kNotificationGetProfile) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        // This makes the current ID (an auto-generated GUID)
        // and 'joe@example.com' interchangeable distinct ids.
        [mixpanel createAlias:[[AppData shared]data][@"user"][@"email"]
                forDistinctID:mixpanel.distinctId];
        // You must call identify if you haven't already
        // (e.g., when your app launches).
        //[mixpanel identify:mixpanel.distinctId];
        
        // Sets user 13793's "Plan" attribute to "Premium"
        NSString *userName = nil;
        if ([[[AppData shared]data][@"user"][@"name"]length]>0) {
            userName = [[AppData shared]data][@"user"][@"name"];
        }else {
            userName = [[AppData shared]data][@"user"][@"email"];
        }
        [mixpanel.people set:@{@"userId": [[AppData shared]data][@"user"][@"userId"],@"name":userName,@"email":[[AppData shared]data][@"user"][@"email"]}];
    }
    if (notification.name == kNotificationPurchaseSuccess) {
        if(!self.scrollView.decelerating) {
            [self refresh];
        }
    }
}

- (void)progressUpdate:(NSNotification *)notification
{
    if (notification.name == kNotificationCardImageProgressBar) {
        CGFloat progress = [notification.userInfo[@"progress"] floatValue];
        
        if (self.progressView.progress == 0 && progress > 0) {
            [UIView animateWithDuration:1 animations:^{
                self.progressView.alpha = 1;
            }];
        }
        
        self.progressView.progress = progress;
        
        if (progress + 0.02 > 1) {
            [UIView animateWithDuration:1 animations:^{
                self.progressView.alpha = 0;
            }];
        }
#ifdef DEBUG
        //NSLog(@"PROGRESS: %4.2f", progress);
#endif
    }
}


- (void)startSpinningActivity
{
    [UIView animateWithDuration:.5 animations:^{
        self.refreshActivity.alpha = 1;
        [self.refreshActivity startAnimating];
    }];
}

- (void)stopSpinningActivity
{
    [UIView animateWithDuration:.5 animations:^{
        self.refreshActivity.alpha = 0;
        [self.refreshActivity stopAnimating];
    }];
}

#pragma mark - autoraotation support

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    isIPhone {
        return UIInterfaceOrientationMaskPortrait;
    }
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
