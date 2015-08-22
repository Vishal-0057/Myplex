//
//  IpadMainViewController.m
//  Myplex
//
//  Created by apalya technologies on 2/12/14.
//  Copyright (c) 2014 Igor Ostriz. All rights reserved.
//

#import "IpadMainViewController.h"
#import "CardsViewController.h"
#import "CardDetailsViewController.h"
#import "MenuButton.h"
#import "SearchViewController.h"
#import "DownloadsViewController.h"
#import "SettingsViewController.h"
#import "MainNavigationController.h"
#import "AppData.h"
#import "SharingActivityProvider.h"


NSString *const kFontSSSymbolFamilyName = @"SSSymboliconsLine";
NSString *const kFontSSSymbolSettings = @"\u2699";
NSString *const kFontSSSymbolDownloads = @"\uEB00";
NSString *const kFontSSSymbolLogout = @"\uEE10";
NSString *const kFontSSSymbolInviteFriends = @"\uE401";
NSString *const kFontSSSymbolFifaLive = @"\u26BD";
NSString *const kFontSSSymbolSearch = /*@"\uE856";*/@"\uEC05";
NSString *const kFontSSSymbolFavorites = @"\u2665";
NSString *const kFontSSSymbolFifaMatches = @"\u2691";
NSString *const kFontSSSymbolLiveTv = @"\uE8C0";
NSString *const kFontSSSymbolPurchases = @"\uE550";
NSString *const kFontSSSymbolShare = @"\uF601";

@interface IpadMainViewController () <UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *mainScrollView;
    __weak IBOutlet UIButton *buttonHome;
    __weak IBOutlet UIButton *buttonSearch;
    __weak IBOutlet UIButton *buttonMovies;
    __weak IBOutlet UIButton *buttonLiveTv;
    __weak IBOutlet UIButton *buttonFavorites;
    __weak IBOutlet UIButton *buttonPurchased;
    __weak IBOutlet UIView *menuView;
}

@end

@implementation IpadMainViewController
{
    CardsViewController *_cardsViewController;
    CardDetailsViewController *_cardDetailsViewController;
    SearchViewController *_searchViewController;
    DownloadsViewController *_downloadsViewController;
    SettingsViewController *_settingsViewController;
}

@synthesize searchClicked,searchContainerView;

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
    
    mainScrollView.delegate = self;
    [mainScrollView setContentSize:CGSizeMake(1344, mainScrollView.frame.size.height)];
    searchClicked = NO;
    
    NSMutableArray *barButtonItemArray = [NSMutableArray arrayWithCapacity:0];
    UIColor *barButtonItemColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:[_cardsViewController getMenuView]];
    [barButtonItemArray addObject:menu];
    
    // Search is moved on nav bar.
    UIBarButtonItem *search = [self getBarButtonItemForTitle:kFontSSSymbolSearch color:barButtonItemColor action:@selector(ButtonAction_Search:)];
    [barButtonItemArray addObject:search];
    
    [self.navigationItem setLeftBarButtonItems:barButtonItemArray];
    
    menuView.layer.cornerRadius = 3.0;
    menuView.layer.masksToBounds = NO;
    menuView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    menuView.layer.shouldRasterize = YES;
    
    [self styleMenuViewButtons];
    [self toggleColorForButton:buttonHome];
}

-(void) viewWillAppear:(BOOL)animated
{
    UIColor *barButtonItemColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    NSMutableArray *barButtonItemArray = [NSMutableArray arrayWithCapacity:0];
    
    UIBarButtonItem *logout = [self getBarButtonItemForTitle:kFontSSSymbolLogout color:barButtonItemColor action:@selector(logoutClicked)];
    [barButtonItemArray addObject:logout];
    
    //    if ([[[AppData shared]data][@"user"][@"loggedInThrough"] isEqualToString:@"Facebook"]) {
    //        UIBarButtonItem *inviteFriends = [self getBarButtonItemForTitle:kFontSSSymbolInviteFriends color:barButtonItemColor action:@selector(inviteFriendsClicked)];
    //        [barButtonItemArray addObject:inviteFriends];
    //    }
    
    //    UIBarButtonItem *downloads = [self getBarButtonItemForTitle:kFontSSSymbolDownloads color:barButtonItemColor action:@selector(downloadsClicked)];
    //    [barButtonItemArray addObject:downloads];
    
    UIBarButtonItem *share = [self getBarButtonItemForTitle:kFontSSSymbolShare color:barButtonItemColor action:@selector(shareClicked:)];
    [barButtonItemArray addObject:share];
    
    UIBarButtonItem *settings = [self getBarButtonItemForTitle:kFontSSSymbolSettings color:barButtonItemColor action:@selector(settingsClicked)];
    [barButtonItemArray addObject:settings];
    
    [self.navigationItem setRightBarButtonItems:barButtonItemArray];
}

-(void) styleMenuViewButtons
{
    NSArray *fontIconArray = [NSArray arrayWithObjects:kFontSSSymbolFifaLive,kFontSSSymbolFifaMatches,kFontSSSymbolPurchases,kFontSSSymbolFavorites, nil];
    for (int i = 0; i < [[menuView subviews] count]; i++) {
        UIButton *btn = (UIButton *)[[menuView subviews] objectAtIndex:i];
        UIColor *color = [UIColor colorWithRed:200.0/255.0 green:16.0/255.0 blue:26.0/225.0 alpha:1.0];
        [self getAttributedTitleForButton:btn title:[NSString stringWithFormat:@"%@\n%@",[fontIconArray objectAtIndex:i],[[btn titleLabel] text]] textColor:color backgroundColor:[UIColor whiteColor]];
        //        [self styleButton:btn withColor:color];
    }
}

-(UIBarButtonItem *) getBarButtonItemForTitle:(NSString *)title color:(UIColor *)color action:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 7, 44, 44);
    [button addTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self getAttributedTitleForButton:button title:title textColor:color backgroundColor:[UIColor clearColor]];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return barButtonItem;
}

-(void) getAttributedTitleForButton:(UIButton *)button title:(NSString *)title textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor
{
    NSMutableAttributedString *attributedString;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:title forState:UIControlStateNormal] ;
    [button setBackgroundColor:backgroundColor];
    attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSSSymbolFamilyName size:24] range:NSMakeRange(0, 1)];
    
    if ([title length] > 2) {
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(2, [title length]-2)];
    }
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [title length])];
    [button setAttributedTitle:attributedString forState:UIControlStateNormal];
}

-(void) styleButton:(UIButton *)button withColor:(UIColor *)color
{
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = NO;
    button.layer.rasterizationScale = [UIScreen mainScreen].scale;
    button.layer.shouldRasterize = YES;
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1.0f;
}

-(void)toggleColorForButton:(UIButton *)btn
{
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *blueColor = [UIColor colorWithRed:200.0/255.0 green:16.0/255.0 blue:26.0/225.0 alpha:1.0];
    
    for (UIButton *button in [menuView subviews]) {
        if ([button isEqual:btn]) {
            [self getAttributedTitleForButton:btn title:[btn titleForState:UIControlStateNormal] textColor:whiteColor backgroundColor:blueColor];
        }
        else
            [self getAttributedTitleForButton:button title:[button titleForState:UIControlStateNormal] textColor:blueColor backgroundColor:whiteColor];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"IpadMainBlock1ID"]) {
        _cardsViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:@"IpadMainBlock2ID"]) {
        _cardDetailsViewController = segue.destinationViewController;
        _cardsViewController.delegate = _cardDetailsViewController;
        [_cardsViewController setTappedCard:nil];
        [self ButtonAction_Home:buttonHome];
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
    return UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - ScrollView Delegate

-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self animateScrollView:scrollView];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self animateScrollView:scrollView];
}

-(void) animateScrollView:(UIScrollView *) scrollView
{
    CGPoint newOffset = (scrollView.contentOffset.x < 160)?CGPointMake(0, scrollView.contentOffset.y):CGPointMake(320, scrollView.contentOffset.y);
    [scrollView setContentOffset:newOffset animated:YES];
}

#pragma mark - IBAction

-(IBAction)ButtonAction_Home:(id)sender
{
    [self clickedButton:(UIButton*)sender refreshCardType:CardsRecommendations];
}

-(IBAction)ButtonAction_Movie:(id)sender
{
    [self clickedButton:(UIButton*)sender refreshCardType:CardsMovies];
}

-(IBAction)ButtonAction_LiveTv:(id)sender
{
    [self clickedButton:(UIButton*)sender refreshCardType:CardsLiveTV];
}

-(IBAction)ButtonAction_FiFaMatches:(id)sender
{
    [self clickedButton:(UIButton*)sender refreshCardType:CardsFIFA];
}

-(IBAction)ButtonAction_Purchased:(id)sender
{
    [self clickedButton:(UIButton*)sender refreshCardType:CardsPurchased];
}

-(IBAction)ButtonAction_Favorites:(id)sender
{
    [self clickedButton:(UIButton*)sender refreshCardType:CardsFavorites];
}

-(IBAction)ButtonAction_Search:(id)sender
{
    _searchViewController = [[UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchViewControllerID"];
    [self searchViewTransition];
    [_searchViewController setDelegateWithViewController:_cardsViewController];
    
}

-(void) clickedButton:(UIButton *)button refreshCardType:(CardBrowseType)cardType
{
    [self toggleColorForButton:button];
    [_cardsViewController showDeletedCards];
    [_cardsViewController setTappedCard:nil];
    [_cardsViewController refresh:cardType];
}

-(void) shareClicked:(UIBarButtonItem*)sender
{
    [_cardDetailsViewController share:sender];
}

-(void) downloadsClicked
{
    _downloadsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DownloadsViewControllerID"];
    _downloadsViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStyleBordered target:_downloadsViewController action:@selector(closePageSheetWithViewController)];
    _downloadsViewController.playerDelegate = _cardDetailsViewController;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_downloadsViewController];
    nav.navigationBar.barTintColor = [UIColor colorWithRed:86.0/255.0 green:180.0/255.0 blue:229.0/225.0 alpha:1.0];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) settingsClicked
{
    _settingsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewControllerID"];
    _settingsViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStyleBordered target:_settingsViewController action:@selector(closePageSheetWithViewController)];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_settingsViewController];
    nav.navigationBar.barTintColor = [UIColor colorWithRed:200.0/255.0 green:16.0/255.0 blue:26.0/225.0 alpha:1.0];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) inviteFriendsClicked
{
    [(MainNavigationController *)self.navigationController showFBInviteDialog];
}

-(void) logoutClicked
{
    [(MainNavigationController *)self.navigationController checkForLogin];
}

-(id)getDelegate {
    return _cardsViewController;
}

-(void) searchViewTransition
{
    CGRect aFrame = searchContainerView.frame;
    CGFloat xDiff = 320;
    
    aFrame.origin.x += searchClicked?(-xDiff):(xDiff);
    searchContainerView.frame = aFrame;
    
    searchClicked?[self.view sendSubviewToBack:searchContainerView]:[self.view bringSubviewToFront:searchContainerView];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.45];
    [animation setType:kCATransitionPush];
    
    searchClicked?[animation setSubtype:kCATransitionFromRight]:[animation setSubtype:kCATransitionFromLeft];
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [[searchContainerView layer] addAnimation:animation forKey:@"SwitchToSearchView"];
    
    searchClicked = searchClicked?NO:YES;
}
@end
