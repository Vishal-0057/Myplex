//
//  CardDetailsViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 8/30/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//
#import "IpadMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "CardDetailsViewController.h"
#import "CardDetailsBlock1ViewController.h"
#import "CardDetailsBlock2ViewController.h"
#import "CardDetailsCommentsViewController.h"
#import "Content+Utils.h"
#import "GooglePlusActivity.h"
#import "Image+Utils.h"
#import "ScrollingImageView.h"
#import "SharingActivityProvider.h"
#import "RESideMenu.h"
#import "RelatedMultimedia.h"
#import "UIAlertView+Blocks.m"
#import "LEColorPicker.h"
#import "AMBlurView.h"
#import "ReflectionView.h"
#import "Notifications.h"
#import "CardDetailsRelatedMultiMediaViewController.h"

const CGFloat kBlockSeparatorHeight = 12;

static NSString *const kFontSSSymbolFamilyName = @"SSSymboliconsLine";
static NSString *const kFontSSSymbolPlayCode = @"\uE8B1";
static NSString *const kFontSSSymbolTrailerCode = @"\uE8B0";
static NSString *const kFontSSSymbolBackCode = @"\u2B05";
static NSString *const kFontSSSymbolShareCode = @"\uF601";

static NSInteger const CardsLiveTV = 5;

@interface CardDetailsViewController () <ScrollingImageViewDataDelegate>

@property (weak, nonatomic) UIImage *shareImage;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerBlock1View;
@property (weak, nonatomic) IBOutlet UIView *containerBlock2View;
@property (weak, nonatomic) IBOutlet UIView *containerCommentsView;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation CardDetailsViewController
{
    CardDetailsBlock1ViewController *_cardDetailsBlock1ViewController;
    CardDetailsBlock2ViewController *_cardDetailsBlock2ViewController;
    CardDetailsCommentsViewController *_cardDetailsCommentsViewController;
    CardDetailsRelatedMultiMediaViewController *_cardDetailsRelatedMultiMediaViewController;
    NSMutableSet *_receivedProperImages;
    UIPopoverController* pop;
}

//static UIImage *_defaultPreviewImage;

//+ (UIImage *)defaultPreviewImage
//{
//    if (!_defaultPreviewImage) {
//        _defaultPreviewImage = [UIImage imageNamed:@"logowhite"];
//    }
//    return _defaultPreviewImage;
//}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    
    }
    return self;
}

static NSString *kSoonString = @"Coming soon";
static NSString *kFreeString = @"Watch now for free";
static NSString *kWatchNowString = @"Watch now";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _receivedProperImages = [NSMutableSet new];
    self.activityView.hidden = YES;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    //[shadow setShadowBlurRadius:1.0f];
    [shadow setShadowColor:[UIColor blackColor]];
    [shadow setShadowOffset:CGSizeMake(1.5f, 1.5f)];

    NSMutableAttributedString *attributedString;
    UIColor *_white;
    isIPhone
    {
        [self.backButton setTitle:kFontSSSymbolBackCode forState:UIControlStateNormal] ;
        // Vishal Changed.
        attributedString = [[NSMutableAttributedString alloc] initWithString:kFontSSSymbolBackCode];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(1, [self.backButton.titleLabel.text length] - 1)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSSSymbolFamilyName size:24] range:NSMakeRange(0, 1)];
        // Vishal Changed
        _white = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0];
        [attributedString addAttribute:NSForegroundColorAttributeName value:_white range:NSMakeRange(0, [self.backButton.titleLabel.text length])];
        [attributedString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [self.backButton.titleLabel.text length])];
        [self.backButton setAttributedTitle:attributedString forState:UIControlStateNormal];
        
        
        [self.shareButton setTitle:kFontSSSymbolShareCode forState:UIControlStateNormal] ;
        attributedString = [[NSMutableAttributedString alloc] initWithString:kFontSSSymbolShareCode];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(1, [self.shareButton.titleLabel.text length] - 1)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSSSymbolFamilyName size:24] range:NSMakeRange(0, 1)];
        _white = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0];
        [attributedString addAttribute:NSForegroundColorAttributeName value:_white range:NSMakeRange(0, [self.shareButton.titleLabel.text length])];
        [attributedString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [self.shareButton.titleLabel.text length])];
        [self.shareButton setAttributedTitle:attributedString forState:UIControlStateNormal];
        
    }
    
    [self.playButton setTitle:kFontSSSymbolPlayCode forState:UIControlStateNormal] ;
    attributedString = [[NSMutableAttributedString alloc] initWithString:kFontSSSymbolPlayCode];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(1, [self.playButton.titleLabel.text length] - 1)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSSSymbolFamilyName size:24] range:NSMakeRange(0, 1)];
    _white = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0];
    [attributedString addAttribute:NSForegroundColorAttributeName value:_white range:NSMakeRange(0, [self.playButton.titleLabel.text length])];
    [attributedString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [self.playButton.titleLabel.text length])];
    
    [self.playButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    if (self.cardBrowseType == CardsLiveTV) {
        self.trailerButton.hidden = YES;
        isIPhone
            _cardDetailsBlock2ViewController.view.hidden = YES;
        else
            _cardDetailsRelatedMultiMediaViewController.view.hidden = YES;
    } else {
        [self.trailerButton setTitle:kFontSSSymbolTrailerCode forState:UIControlStateNormal] ;
        attributedString = [[NSMutableAttributedString alloc] initWithString:kFontSSSymbolTrailerCode];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(1, [self.trailerButton.titleLabel.text length] - 1)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontSSSymbolFamilyName size:24] range:NSMakeRange(0, 1)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:_white range:NSMakeRange(0, [self.playButton.titleLabel.text length])];
        [attributedString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, [self.trailerButton.titleLabel.text length])];

        [self.trailerButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    }
    
    [self addObserver:self forKeyPath:@"_cardDetailsBlock1ViewController.view.frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    isIPhone
        [self addObserver:self forKeyPath:@"_cardDetailsBlock2ViewController.view.frame" options:NSKeyValueObservingOptionOld context:NULL];
    else
        [self addObserver:self forKeyPath:@"_cardDetailsRelatedMultiMediaViewController.view.frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    [self addObserver:self forKeyPath:@"_cardDetailsCommentsViewController.view.frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:kNotificationCardImageDownloaded object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationReceived:) name:kNotificationShowActivityIndicator object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    
//#ifdef DEBUG
//    UIRefreshControl *refreshControll = [[UIRefreshControl alloc] init];
//    [refreshControll addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventValueChanged];
//    [self.scrollView addSubview:refreshControll];
//#endif

}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    isIPhone
    {
        [self.navigationController.navigationBar setHidden:YES];
        self.view.frame = self.navigationController.view.frame;
    }
    
    self.reflectionView.reflectionHeight = 180.0f;
    self.reflectionView.reflectionOffset = 0.0f;

    //    NSString *purchaseString = [_content getPurchaseString];
    //    if ([purchaseString isEqualToString:kSoonString]) {
    //        [self.playButton setHidden:YES];
    //    } else if([purchaseString isEqualToString:kFreeString] || [purchaseString isEqualToString:kWatchNowString]) {
    //        [self.playButton setHidden:NO];
    //    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    _cardDetailsBlock1ViewController.cardBrowseType = self.cardBrowseType;
    _cardDetailsBlock1ViewController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    isIPhone {
        if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
            [self.navigationController.navigationBar setHidden:NO];
            // back button was pressed.  We know this is true because self is no longer
            // in the navigation stack.
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"StopPlay" object:nil];
        }
    }
}

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)share:(id)sender {
    TCSTART
    /*
     This section was used for basic sharing when no customization was needed
     NSString *shareString = @"CapTech is a great place to work.";
     UIImage *shareImage = [UIImage imageNamed:@"captech-logo.jpg"];
     NSURL *shareUrl = [NSURL URLWithString:@"http://www.captechconsulting.com"];
     
     NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareImage, shareUrl, nil];
     
     UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
     */
    
    // Create the custom activity provider
    NSString *shareMessage = nil;
    if (self.cardBrowseType == CardsLiveTV) {
        //shareMessage = [NSString stringWithFormat:kShareMessage,[_content.title lowercaseString],@"channel"];
        shareMessage = [NSString stringWithFormat:kShareMessage,_content.title,@"channel"];
    } else {
//        shareMessage = [NSString stringWithFormat:kShareMessage,[_content.title lowercaseString],@"movie"];
        shareMessage = [NSString stringWithFormat:kShareMessage,_content.title,@"movie"];
    }
    
    SharingActivityProvider *sharingActivityProvider = [[SharingActivityProvider alloc] initWithMessage:shareMessage];
    // get the image we want to share
    //UIImage *shareImage = [UIImage imageNamed:@"captech-logo.jpg"];
    // Prepare the URL we want to share
    
    
    // put the activity provider (for the text), the image, and the URL together in an array
    NSArray *activityProviders = @[sharingActivityProvider, self.shareImage?:[UIImage imageNamed:@"logo"], kShareURL];
    /*
     This section was used to customize text output to different social networks but before
     any additional social networks were created
     UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityProviders applicationActivities:nil];
     */
    
    // Create the google plus activity
    //GooglePlusActivity *gPlusActivity = [[GooglePlusActivity alloc] init];
    
    // Create the activity view controller passing in the activity provider, image and url we want to share along with the additional source we want to appear (google+)
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityProviders applicationActivities:nil];
    
    // tell the activity view controller which activities should NOT appear
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToWeibo];
    
    isIPhone
    {
        // display the options for sharing
        activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        pop = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:sender];
        [pop presentPopoverFromBarButtonItem:bar
                    permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        pop.passthroughViews = nil;
    }
    TCEND
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self removeObserver:self forKeyPath:@"_cardDetailsBlock1ViewController.view.frame"];
    isIPhone
        [self removeObserver:self forKeyPath:@"_cardDetailsBlock2ViewController.view.frame"];
    else
        [self removeObserver:self forKeyPath:@"_cardDetailsRelatedMultiMediaViewController.view.frame"];
    
    [self removeObserver:self forKeyPath:@"_cardDetailsCommentsViewController.view.frame"];
}

- (void)doRefresh:(UIRefreshControl *)refreshControll
{
    [refreshControll endRefreshing];
}

- (void)setContent:(Content *)content
{
    _content = content;
    
    if ([_content.type isEqualToString:@"live"])
    {
        self.cardBrowseType = CardsLiveTV;
        self.trailerButton.hidden = YES;
    }
    else
    {
        self.cardBrowseType = 0;
        //self.trailerButton.hidden = NO;
         self.trailerButton.hidden = YES;
    }
    self.navigationItem.title =_content.title;
    
    _cardDetailsBlock1ViewController.cardBrowseType = self.cardBrowseType;
    _cardDetailsBlock1ViewController.content = content;
    
    
    isIPhone
        _cardDetailsBlock2ViewController.content = content;
    else
    {
        _cardDetailsRelatedMultiMediaViewController.content = content;
        _cardDetailsRelatedMultiMediaViewController.delegate = self.delegate;
        for (UIViewController *vc in [[self navigationController] viewControllers]) {
            if ([vc isKindOfClass:[IpadMainViewController class]]) {
                vc.navigationItem.title = content.title;
                break;
            }
        }
    }
    
    _cardDetailsCommentsViewController.content = content;
    
    NSSet *filteredSet = [_content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"resolution == '960x540'"]];
    NSArray *images = [filteredSet allObjects];//[_content.images allObjects];

    ScrollingImageView *siv = (ScrollingImageView *)[self.view viewWithTag:67];
    siv.numPages = [images count];
    siv.dataDelegate = self;
    [siv reloadData];
    
    NSString *s = [_content getPurchaseString];
    if ([s isEqualToString:kSoonString]) {
        [self.playButton setHidden:YES];
    } else {
        [self.playButton setHidden:NO];
    }
}

-(void) refreshContent:(Content *)content
{
    [self setContent:content];
}

#pragma mark - Actions

- (IBAction)play:(UIButton *)sender
{
    NSString *contentId = nil;
    Image *imageEntity = nil;
    BOOL drmEnabled = NO;
    NSString *title = nil;
    if (sender.tag == 101) { //Play Trailer
        
        NSLog(@"relatedmultimedia %@",[_content.relatedMultimedia anyObject]);
        NSSet *trailers = [_content.relatedMultimedia filteredSetUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"categoryName == 'trailer'"]]];
        if (trailers.count > 0) {
            RelatedMultimedia *relatedMultimedia = [trailers anyObject];
            contentId = relatedMultimedia.content.remoteId;
            drmEnabled = relatedMultimedia.content.drmEnabled.boolValue;
            title = relatedMultimedia.content.title;
            
            NSSet *filteredSet = [relatedMultimedia.content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type == 'thumbnail' && (profile == 'mdpi' || profile == 'hdpi' || profile == 'xhdpi')"]];
            imageEntity  = [filteredSet anyObject];
        }
    } else { //Play Movie
        //self.movieImage.hidden = YES;
        
        [_cardDetailsBlock1ViewController verifyPurchaseAndPlay:[_content getPurchaseString]];
//        NSSet *filteredSet = [_content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type == 'thumbnail' && (profile == 'mdpi' || profile == 'hdpi' || profile == 'xhdpi')"]];
//       imageEntity  = [filteredSet anyObject];
//        
//        contentId = _content.remoteId;
//        drmEnabled = _content.drmEnabled.boolValue;
//        title = _content.title;
    }
    NSLog(@"Selected content id %@ required %@",contentId,@[@"405",@"201",@"204"]);
    if ([self isNotNull:contentId] /*testing demo && [@[@"405",@"201",@"204"] containsObject:contentId]*/) {

        NSLog(@"request for play with contentId %@ title %@, drmStatus %d, imageURL %@",contentId,title,drmEnabled,imageEntity.url);

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        //Demo
//        if ([contentId isEqualToString:@"204"]) {
//            [appDelegate initPlayerWithUrl:@"http://220.226.22.115:1935/live/smil:TIMESNOW.smil/playlist.m3u8" contentId:contentId title:@"Times Now" profile:nil drmEnabled:drmEnabled streaming:YES delegate:self elapsedTime:[jsonResponse[@"elapsedTime"]floatValue]];
//            return;
//        }
        //
        
        [appDelegate cardSelectedWithStatus:YES drmEnabled:drmEnabled contentId:contentId title:title image:imageEntity.url packageId:nil delegate:self];
    }
//    else {
//        [UIAlertView alertViewWithTitle:@"myplex" message:@"Selected movie couldn't play"];
//    }
}

-(void)showMenu:(id)sender {
    [self.sideMenu show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CardDetailsBlock1ID"]) {
        _cardDetailsBlock1ViewController = segue.destinationViewController;
    }

    if ([segue.identifier isEqualToString:@"CardDetailsBlock2ID"] /*&& _content.similarContent.count > 0*/) {
        isIPhone
            _cardDetailsBlock2ViewController = segue.destinationViewController;
        else
        {
            _cardDetailsRelatedMultiMediaViewController = segue.destinationViewController;
            _cardDetailsRelatedMultiMediaViewController.delegate = self.delegate;
        }
    }
    if ([segue.identifier isEqualToString:@"CardDetailsCommentsID"]) {
        _cardDetailsCommentsViewController = segue.destinationViewController;
    }

}

- (void)setScrollViewContentSize
{
    CGRect f = self.containerBlock1View.frame;
    f.size.height = _cardDetailsBlock1ViewController.view.frame.size.height;
    self.containerBlock1View.frame = CGRectIntegral(f);

    CGSize sz = CGSizeMake(320, self.containerBlock1View.frame.origin.y);
    sz.height += self.containerBlock1View.frame.size.height;
    //sz.height += kBlockSeparatorHeight;
    
    if (self.cardBrowseType != CardsLiveTV) {
        f = self.containerBlock2View.frame;
        f.origin.y = sz.height;
        isIPhone
            f.size.height = _cardDetailsBlock2ViewController.view.frame.size.height;
        else
            f.size.height = _cardDetailsRelatedMultiMediaViewController.view.frame.size.height;
        self.containerBlock2View.frame = CGRectIntegral(f);
        
        sz.height += self.containerBlock2View.frame.size.height;
        sz.height += kBlockSeparatorHeight;
    }

    f = self.containerCommentsView.frame;
    f.origin.y = sz.height;
    f.size.height = _cardDetailsCommentsViewController.view.frame.size.height;
    self.containerCommentsView.frame = CGRectIntegral(f);
    
    sz.height += self.containerCommentsView.frame.size.height;
    sz.height += kBlockSeparatorHeight;
    
    self.scrollView.contentSize = sz;
}

#pragma mark - Notifications handler

- (void)notificationReceived:(NSNotification *)notification
{
    if (notification.name == kNotificationCardImageDownloaded) {
//        UIImage *image = [[_content imageSuitableForBrowse] image];

//        self.movieImage.image = image;
//        self.movieImage.contentMode = UIViewContentModeScaleToFill;
        
        ScrollingImageView *siv = (ScrollingImageView *)[self.view viewWithTag:67];
        NSSet *filteredSet = [_content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"resolution == '960x540'"]];
        NSArray *images = [filteredSet allObjects];

        Image *imgRecv = (Image *)notification.object;
        if ([imgRecv.resolution isEqualToString:@"960x540"]) {
            NSUInteger oldCount = [_receivedProperImages count];
            [_receivedProperImages addObject:imgRecv];
            if (_receivedProperImages.count > oldCount) {
                siv.numPages = [images count];
                [siv reloadData];
            }
        }

//        // check if received currently displayed image
//        
//        if ([images count] && siv.currentPageIndex>=0) {
//            Image *imgDisplayed = (Image *)images[siv.currentPageIndex];
//            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!! Current image = %@", imgDisplayed.url);
//            
//            qualifies = [imgRecv.url isEqualToString:imgDisplayed.url] && !imgDisplayed.content;
//            NSLog(@"=========> %i, \n%@\n%@", qualifies, imgRecv.url, imgDisplayed.url);
//        }
//
//        if (qualifies) {
//            NSLog(@"pppp");
//        }
//        
//        if (siv.numPages != [images count] || qualifies) {
//            siv.numPages = [images count];
//            [siv reloadData];
//        }
    } else if(notification.name == kNotificationShowActivityIndicator) {

        BOOL startSpinning = [notification.object boolValue];
#if DEBUG
        NSLog(@"kNotificationShowActivityIndicator Status %d",startSpinning);
#endif
        if (startSpinning) {
            [self.activityView setHidden:NO];
            [self.activityIndicatorView startAnimating];
        } else {
            [self.activityView setHidden:YES];
            [self.activityIndicatorView stopAnimating];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"_cardDetailsBlock1ViewController.view.frame"] ||
       [keyPath isEqualToString:@"_cardDetailsBlock2ViewController.view.frame"] ||
       [keyPath isEqualToString:@"_cardDetailsCommentsViewController.view.frame"] ||[keyPath isEqualToString:@"_cardDetailsRelatedMultiMediaViewController.view.frame"]) {
        CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if([change objectForKey:@"old"] != [NSNull null]) {
            oldFrame = [[change objectForKey:@"old"] CGRectValue];
        }
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
        }
        isIPhone
            [self setScrollViewContentSize];
    }
}


-(NSURL *)imageURLForPageIndex:(int)pageIndex {
    NSSet *filteredSet = [_content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"resolution == '960x540'"]];
    NSArray *images = [filteredSet allObjects];
    Image *img = nil;
    if (images.count > pageIndex) {
       img = images[pageIndex];
    }
    return [NSURL URLWithString:img.url];
}

-(void)updateColorFromImage:(UIImage *)image forPage:(NSInteger)pageIndex {
    if (image && pageIndex == _content.currentImageIndex) {
        self.shareImage = image;
        LEColorPicker *colorPicker = [[LEColorPicker alloc] init];
        LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:image];
        isIPhone
        {
        self.view.backgroundColor = colorScheme.backgroundColor;
        self.scrollView.backgroundColor = [UIColor clearColor];
            
        [self.reflectionView updateReflection];
        }
    }
}
// Scrolling Image view delegate
- (void)scrollingImageView:(ScrollingImageView *)scrollingImageView imageForPageIndex:(int)pageIndex withCompletionBlock:(void (^)(UIImage *image, NSError *error))block
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        
        NSSet *filteredSet = [_content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"resolution == '960x540'"]];
        NSArray *images = [filteredSet allObjects];
        Image *img = images[pageIndex];
        if (img.content) {
            UIImage *image = img.browseImage2;
            if (pageIndex == _content.currentImageIndex) {
                LEColorPicker *colorPicker = [[LEColorPicker alloc] init];
                LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:image];
               
                dispatch_sync(dispatch_get_main_queue(),^(void) {
                    isIPhone
                    {
                    self.view.backgroundColor = colorScheme.backgroundColor;
                    self.scrollView.backgroundColor = [UIColor clearColor];
                    
                    [self.reflectionView updateReflection];
                    self.reflectionView.reflectionHeight = 180.0f;
                    self.reflectionView.reflectionOffset = 0.0f;
                    }
                    else
                    {
                        _cardDetailsBlock1ViewController.view.backgroundColor = colorScheme.backgroundColor;
                    }
                });
            }
            
            //self.movieImage.image = img.browseImage2;
            
            dispatch_sync(dispatch_get_main_queue(),^(void) {
                block(nil, nil);
            });
        } else {
            //[img fetchImage];
            dispatch_sync(dispatch_get_main_queue(),^(void) {
                block(nil, nil);
            });
        }
    });
}

- (void)scrollingImageView:(ScrollingImageView *)scrollingImageView currentPageIndexDidChange:(int)pageIndex
{
    _content.currentImageIndex = pageIndex;
}

- (UIImage*) blur:(UIImage*)theImage
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
    
    // if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

+(UIImage*) scaleIfNeeded:(CGImageRef)cgimg {
    bool isRetina = [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0;
    if (isRetina) {
        return [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp];
    } else {
        return [UIImage imageWithCGImage:cgimg];
    }
}
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    isIPhone
        return UIInterfaceOrientationMaskPortrait;
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
