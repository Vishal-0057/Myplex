//
//  CardView.m
//  Myplex
//
//  Created by Igor Ostriz on 8/20/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CardView.h"
#import "Image+Utils.h"
#import "NSManagedObjectContext+Utils.h"
//#import "ScrollingImageView.h"
#import "UIDeviceHardware.h"
#import <objc/runtime.h>
#import "AppData.h"
#import "UIColor+Hex.h"


@interface CardView () /*<ScrollingImageViewDataDelegate>*/

@property (weak, nonatomic) IBOutlet UIView *bumpView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *favoutitesButton;
@property (weak, nonatomic) IBOutlet UIView *transparentView;

@end


@implementation CardView


+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}


static NSDictionary *_cardTypes;
+ (void)load
{
    _cardTypes = @{ @"movie" : @(ContentTypeMovie), @"tvshow" : @(ContentTypeTVShow), @"livetv" : @(ContentTypeLiveTV) };
}

//static UIImage *_defaultPreviewImage;
//
//+ (UIImage *)defaultPreviewImage
//{
//    if (!_defaultPreviewImage) {
//        _defaultPreviewImage = [UIImage imageNamed:@"logowhite"];
//    }
//    return _defaultPreviewImage;
//}

+ (CardView *)card
{
    CardView *cardView = [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier] owner:self options:nil] objectAtIndex:0];
    cardView.layer.cornerRadius = 5;
    cardView.clipsToBounds = YES;
    cardView.layer.masksToBounds = NO;
    cardView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cardView.layer.shouldRasterize = YES;

    return cardView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        // cannot use self.moviewImage because outlets are set later
        UIImageView *iv = (UIImageView *)[self viewWithTag:101];
        //iv.contentMode = UIViewContentModeCenter;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        //siv.dataDelegate = self;
        [iv addGestureRecognizer:tap];
        [[self viewWithTag:120] setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];

    }
    return self;
}

- (void)setContent:(Content *)content
{
    //dispatch_async(dispatch_get_main_queue(), ^{
    if ([self isNotNull:content]) {
        _content = content;
        //self.movieTitle.text = [_content.title lowercaseString];
        self.movieTitle.text = _content.title;
//        NSLog(@"movieTitle %@",self.movieTitle.text);
        //self.movieImage.numPages = 1;//[_content.images count];
        
        NSString *s = [_content getPurchaseString];
        //[self.priceButton setTitle:[s lowercaseString] forState:UIControlStateNormal];
        [self.priceButton setTitle:s forState:UIControlStateNormal];
        
        NSNumberFormatter *fmt = [NSNumberFormatter new];
        [fmt setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
        
        self.commentsLabel.text = [fmt stringFromNumber:_content.commentsCount];
        self.peopleLabel.text = [fmt stringFromNumber:_content.userRatingsCount];
        
        NSNumber *n = @(ContentTypeNone);//_cardTypes[_content.type];
        [self setContentType:n ? [n integerValue] : ContentTypeNone];
        
        self.favoutitesButton.selected = [_content.favorite boolValue];
        
        [self refresh];
    }
    //});
}

- (void)refresh
{
    //[self.movieImage reloadData];
    Image *img = nil;
//    if (_content.sortedImages.count > 0) {
//        img = _content.sortedImages[0];
//    }
    NSSet *filteredSet = [_content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"resolution == '960x540' AND type=='coverposter'"]];
    NSArray *images = [filteredSet allObjects];
    if (images.count > 0) {
        NSArray *contentFilteredImages = [images filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"content!=nil"]];
        if (contentFilteredImages.count > 0) {
            img = [contentFilteredImages firstObject];
        } else {
            img = [images firstObject];
        }
    }
    
    if (img.content) {
        self.movieImage.image = img.browseImage;
    } else {
        UIColor *color = objc_getAssociatedObject(self, @"CardColor");
        if (color == nil) {
//            CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
//            CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
//            CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
//            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
            color = [UIColor getPlaceHolderColor];
            objc_setAssociatedObject(self,  @"CardColor", color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        self.movieImage.image = nil;
        self.movieImage.backgroundColor = color;
        //self.movieImage.image = [CardView defaultPreviewImage];
        [img fetchImage];
    }
    
    if ([[AppData shared].data[@"user"][@"loggedInThrough"] isEqualToString:@"guest"]) {
        self.favoutitesButton.enabled = NO;
    } else {
       self.favoutitesButton.enabled = YES;
    }
}

- (void)setContentType:(ContentType)contentType
{
    static NSArray *colors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *a = @[
                       [UIColor colorWithRed:230./255 green:230./255 blue:230./255 alpha:1.],
                       [UIColor colorWithRed:124./255 green:197./255 blue:118./255 alpha:1.],
                       [UIColor colorWithRed:255./255 green:245./255 blue:104./255 alpha:1.],
                       [UIColor colorWithRed:109./255 green:207./255 blue:246./255 alpha:1.]
                    ];
        colors = a;
    });
    
    [self.bumpView setBackgroundColor:colors[(int)contentType]];
    _contentType = contentType;
}



- (void)tapped:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded && self.delegate && [self.delegate respondsToSelector:@selector(cardTapped:)]) {
        [Analytics logEvent:CONTENT_CARD_DETAILS parameters:@{CONTENT_NAME_PROPERTY:_content.title?:@"", CONTENT_TYPE_PROPERTY:@(_contentType)} timed:NO];
        [self.delegate cardTapped:self];
    }
}

static NSString *kSoonString = @"Coming soon";
static NSString *kFreeString = @"Watch now for free";
static NSString *kWatchNowString = @"Watch now";
static NSString *kFromString = @"Starting from ₹ %@";

- (IBAction)purchase:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:kSoonString]) {
        return;
    } else if([sender.titleLabel.text isEqualToString:kFreeString] || [sender.titleLabel.text isEqualToString:kWatchNowString]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardTapped:)]) {
            [self.delegate cardTapped:self];
        }
    } else if (self.delegate && [self.delegate respondsToSelector:@selector(purchase:)]) {
        [self.delegate purchase:self];
    }
}

- (IBAction)deleteCard:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteCard:)]) {
        [Analytics logEvent:CONTENT_CARD_DELETED parameters:@{CONTENT_NAME_PROPERTY:_content.title} timed:NO];
        [self.delegate deleteCard:self];
    }
}

- (IBAction)favoriteCard:(UIButton *)sender
{
    self.favoutitesButton.selected = ![_content.favorite boolValue];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(favoriteCard:favorite:)]) {
        [Analytics logEvent:CONTENT_CARD_FAVORITED parameters:@{CONTENT_NAME_PROPERTY:_content.title?:@""} timed:NO];
        [self.delegate favoriteCard:self favorite:self.favoutitesButton.selected];
    }
}


- (IBAction)play:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(play:)]) {
        [self.delegate play:self];
    }
}


- (void)setActivity:(BOOL)start animated:(BOOL)animated
{
    // no animation for low end and mid devices
    if ([UIDeviceHardware capabilities] != UIDeviceHighEnd) {
        return;
    }

    return;
    void (^blck)(BOOL) = ^(BOOL start){
        [self.activityIndicator setAlpha:start ? 1. : 0.];
        self.activityIndicator.hidden = !start;
        start ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];
    };
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            blck(start);
        }];
    } else
        blck(start);    
}

//-(NSURL *)imageURLForPageIndex:(int)pageIndex {
//    NSSet *filteredSet = [_content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"resolution == '960x540'"]];
//    NSArray *images = [filteredSet allObjects];
//    Image *img = images[pageIndex];
//    return [NSURL URLWithString:img.url];
//}

// Scrolling Image view delegate
//- (void)scrollingImageView:(ScrollingImageView *)scrollingImageView imageForPageIndex:(int)pageIndex withCompletionBlock:(void (^)(UIImage *, NSError *))block
//{
//    Image *img = nil;
//    if (_content.sortedImages.count > pageIndex) {
//        img = _content.sortedImages[pageIndex];
//    }
//    if (img.content) {
//        block(img.browseImage,nil);
//    } else if ([_movieImage isPageVisible:pageIndex]) { // prefetch only first image
//        block([CardView defaultPreviewImage],nil);
//        [img fetchImage];
//    }
//}
//
//- (void)scrollingImageView:(ScrollingImageView *)scrollingImageView currentPageIndexDidChange:(int)pageIndex
//{
//    _content.currentImageIndex = pageIndex;
//}

@end
