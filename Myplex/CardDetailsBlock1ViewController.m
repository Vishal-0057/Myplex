//
//  CardDetailsBlock1ViewController.m
//  Myplex
//
//  Created by Igor Ostriz on 10/22/13.
//  Copyright (c) 2013 Igor Ostriz. All rights reserved.
//

#import "CardDetailsBlock1ViewController.h"
#import "Cast+Utils.h"
#import "CertifiedRating.h"
#import "Content+Utils.h"
#import "NSDate+ServerDateFormat.h"
#import "PaymentPickerAnimatedTransitioning.h"
#import "PaymentPickerViewController.h"
#import "StarsView.h"
#import "AppDelegate.h"
#import "Image.h"
#import "Notifications.h"
#import "Purchase.h"
#import "Subscribe.h"
#import "NSManagedObjectContext+Utils.h"
#import "UIAlertView+Blocks.h"
#import "AppWebViewController.h"
#import "MZFormSheetController.h"

#import <CoreText/CoreText.h>

@interface CastCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

static NSInteger const CardsLiveTV = 5;

@implementation CastCell


@end




static CGFloat spaceAfterBlock = 16;
static CGFloat spaceAfterLabel = 4;
static CGFloat paragraphSpacing = 5;

NSInteger _try = 0;
//static NSInteger separatorStartIndex = 101;


@interface CardDetailsBlock1ViewController () <UITableViewDataSource,WebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *expanderButton;
@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;
@property (weak, nonatomic) IBOutlet UIView *creditsSeperationView;
@property (weak, nonatomic) IBOutlet UIView *descriptionSperationView;
@property (weak, nonatomic) IBOutlet UITableView *creditsTableView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *durationImageView;
@property (weak, nonatomic) IBOutlet StarsView *ratingView;
@property (weak, nonatomic) IBOutlet UIView *section1View; //contains title,rating,length,time and price button.
@property (weak, nonatomic) IBOutlet UIView *section2View; //contains description and credits.
@property (weak, nonatomic) IBOutlet UIScrollView *block1ScrollView;
@property (weak, nonatomic) IBOutlet UILabel *team1Label;
@property (weak, nonatomic) IBOutlet UILabel *team2Label;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;


@end

@implementation CardDetailsBlock1ViewController
{
    BOOL _expanded;
    NSMutableArray *_casts;
    PaymentPickerTransitioningDelegate *_paymentTransitioningDelegate;
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
    
    self.view.layer.cornerRadius = 5;
    self.view.clipsToBounds = YES;
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.section1View.layer.cornerRadius = 5;
    self.section2View.layer.cornerRadius = 5;
    self.priceButton.layer.cornerRadius = 4;
    self.moreButton.layer.cornerRadius = 4;
    
    isIPhone {} else {
        
        self.view.layer.masksToBounds = NO;
        self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.view.layer.shouldRasterize = YES;
    
        self.section1View.layer.masksToBounds = NO;
        self.section1View.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.section1View.layer.shouldRasterize = YES;
        
        self.section2View.layer.masksToBounds = NO;
        self.section2View.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.section2View.layer.shouldRasterize = YES;

        self.priceButton.layer.masksToBounds = NO;
        self.priceButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.priceButton.layer.shouldRasterize = YES;

        self.moreButton.layer.masksToBounds = NO;
        self.moreButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.moreButton.layer.shouldRasterize = YES;
    }
    
    
    self.priceButton.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:16.0/255.0 blue:26.0/225.0 alpha:1.0].CGColor;
    self.priceButton.layer.borderWidth = 1.0f;
    
    self.moreButton.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:16.0/255.0 blue:26.0/225.0 alpha:1.0].CGColor;
    self.moreButton.layer.borderWidth = 1.0f;
    
    _paymentTransitioningDelegate = [PaymentPickerTransitioningDelegate new];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationReceived:) name:kNotificationPurchaseSuccess  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationReceived:) name:kNotificationCardsRefreshed  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationReceived:) name:kNotificationMatchStatusRefreshed  object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setLayoutWithAnimation:NO];
}

-(void)setupBlurToView:(UIView *)view {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toolbar.barTintColor = nil;
    
    [view insertSubview:toolbar atIndex:0];
}

- (void)setContent:(Content *)content
{
    _content = content;
    self.titleLabel.text = _content.title;
    isIPhone { }
    else {
        self.ratingView.frame = CGRectMake(190, 5, 100, 16);
    }
    if ([_content.certifiedRatings count]) {
//        self.titleLabel.text = [[self.titleLabel.text stringByAppendingString:[NSString stringWithFormat:@" (%@)",[[_content.certifiedRatings anyObject] rating]]]lowercaseString];
        self.titleLabel.text = [self.titleLabel.text stringByAppendingString:[NSString stringWithFormat:@" (%@)",[[_content.certifiedRatings anyObject] rating]]];
    }
//    self.ratingLabel.text = @"";
//    if ([_content.certifiedRatings count]) {
//        self.ratingLabel.text = [[_content.certifiedRatings anyObject] rating];
//    }
    NSString *s = [_content getPurchaseString];
    self.priceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [self.priceButton setTitle:[s lowercaseString] forState:UIControlStateNormal];
    [self.priceButton setTitle:s forState:UIControlStateNormal];

//    self.priceButton.titleLabel.font = [UIFont fontWithName:@"MuseoSansRounded-700" size:14.0];
//    
//    CGRect priceButtonFrame = self.priceButton.frame;
//    CGRect f = [s boundingRectWithSize:CGSizeMake(272, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"MuseoSansRounded-700" size:16.0]} context:nil];
//    priceButtonFrame.size.width = f.size.width;
//    self.priceButton.frame = priceButtonFrame;
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:_content.baseDescription?:@""];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_content.baseDescription length])];
    
    self.descriptionTextView.attributedText = attString;
    
    self.lengthLabel.text = _content.duration;
    self.dateLabel.text = _content.releaseDate;
    
    //CGSize sz = [_content.title sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font }];
    CGRect titleFrame = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.titleLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil];
    
    CGRect currentTitleFrame = self.titleLabel.frame;
    currentTitleFrame.size.height =  ceilf(titleFrame.size.height);
    self.titleLabel.frame = currentTitleFrame;
    
    NSInteger lastRowStringWidth = [self boundingWidthForAttributedString:[[NSAttributedString alloc]initWithString:self.titleLabel.text?:@"" attributes:@{NSFontAttributeName:self.titleLabel.font}] inHeight:currentTitleFrame.size.height];
    
    int lines = titleFrame.size.height/self.titleLabel.font.pointSize;
    
    NSLog(@"lines count : %i \n\n",lines);
    NSInteger lineSpacing = -7;
    if (lines > 1) {
        lineSpacing = 5;
    }
    NSInteger remainingWidth = (self.titleLabel.frame.size.width - lastRowStringWidth);
    CGRect ratingFrame = self.ratingView.frame;
    if (remainingWidth > self.ratingView.frame.size.width) {
        ratingFrame = CGRectMake(self.ratingView.frame.origin.x, ((self.titleLabel.frame.size.height/2) + self.titleLabel.frame.origin.y + lineSpacing), self.ratingView.frame.size.width, self.ratingView.frame.size.height);
        NSLog(@"show the rateimage Inline");
    } else {
        ratingFrame = CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.titleLabel.frame) + spaceAfterLabel, self.ratingView.frame.size.width, self.ratingView.frame.size.height);
        NSLog(@"show the rateimage in new line");
    }
    
 //   CGRect frame = self.ratingView.frame;
//    CGFloat left = self.titleLabel.frame.origin.x + currentTitleFrame.size.width + 12;
//    if (left < self.ratingView.frame.origin.x) {
//        //frame.origin.x = left;
//    } else {
//        frame.origin.y += frame.size.height + spaceAfterLabel;
//        frame.origin.x = self.titleLabel.frame.origin.x;
//    }
    self.ratingView.frame = ratingFrame;
    self.ratingView.userRating = [_content.averageRating floatValue];
    
    [self loadCasts];
    
    [self loadMatchStatus];
    
    isIPhone{} else
    {
        [self transitionAnimation];
        [[self block1ScrollView] setContentOffset:CGPointZero];
    }
}

- (CGFloat)boundingWidthForAttributedString:(NSAttributedString *)attributedString inHeight:(CGFloat)height
{
    NSLog(@"calculate boundingWidthForAttributedString withing %f height",height);
    CFIndex offset = 0, length;
    CGFloat y = 0, width = 0;
    NSInteger numberOfLines = 0;
    do {
        CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
        length = CTTypesetterSuggestLineBreak(typesetter, offset, self.titleLabel.frame.size.width);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length));
        numberOfLines++;
        if(typesetter){
            CFRelease(typesetter);
            typesetter = nil;
        }
        
        CGFloat ascent, descent, leading;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        if(line){
            CFRelease(line);
            line = nil;
        }
        
        offset += length;
        y += ascent + descent + leading;
    } while (offset < [attributedString length]);
    
    NSLog(@"last row string width %f",width);
    return width;
}

-(void)loadMatchStatus {
    [_content refreshMatchStatus];
}

-(void)loadCasts {
    NSArray *casts = [_content.casts allObjects];
    
    NSArray *actorCasts = [casts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type==[c] 'actor'"]];
    NSArray *directorCasts = [casts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type==[c] 'director'"]];
    NSArray *producerCasts = [casts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type==[c] 'producer'"]];
    NSArray *nonActorCasts = [casts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type!=[c] 'actor' && type!=[c] 'producer' && type!=[c] 'director'"]];
    
    if (actorCasts.count > 0) {
        _casts = [[NSMutableArray alloc]initWithArray:actorCasts];
    }
    if (directorCasts.count > 0) {
        if (_casts) {
            [_casts addObjectsFromArray:directorCasts];
        } else {
            _casts = [[NSMutableArray alloc]initWithArray:directorCasts];
        }
    }
    if (producerCasts.count > 0) {
        if (_casts) {
            [_casts addObjectsFromArray:producerCasts];
        } else {
            _casts = [[NSMutableArray alloc]initWithArray:producerCasts];
        }
    }
    if (nonActorCasts.count > 0) {
        if (_casts) {
            [_casts addObjectsFromArray:nonActorCasts];
        } else {
            _casts = [[NSMutableArray alloc]initWithArray:nonActorCasts];
        }
    }
    isIPhone {}
    else
    {
        [self.creditsTableView reloadData];
    }
}

- (IBAction)expanderClicked:(UIButton *)sender
{
    _expanded = !_expanded;
    
    [Analytics logEvent:CONTENT_CARD_DETAILS_PROPERTY parameters:@{CONTENT_NAME_PROPERTY:_content.title?:@""} timed:NO];
  
    [self.expanderButton setImage:[UIImage imageNamed:_expanded ? @"collapse-triangle" : @"expand-triangle"] forState:UIControlStateNormal];
    
    NSString *description = _expanded ? _content.extendedDescription : _content.baseDescription;
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:description?:@""];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5.5];
    [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [description length])];
    
//    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
//    NSRange range = [description rangeOfString:@"myplex description"];
//    [attString addAttribute:NSFontAttributeName value:font range:range];
    
//    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setParagraphSpacing:10.0];
//    [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    //[attString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    
    self.descriptionTextView.attributedText = attString;
    
    //self.descriptionTextView.text = _expanded ? _content.extendedDescription : _content.baseDescription;
    
    [self transitionAnimation];
}

static NSString *kSoonString = @"Coming soon";
static NSString *kFreeString = @"Watch now for free";
static NSString *kWatchNowString = @"Watch now";

- (IBAction)priceClicked:(UIButton *)sender
{
    [self verifyPurchaseAndPlay:sender.titleLabel.text];
}

-(void)verifyPurchaseAndPlay:(NSString *)title
{
   
    if ([title isEqualToString:kSoonString]) {
        return;
    }
    
    //    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    //    if (![appDelegate checkAuthentication]) {
    //        return;
    //    }
    
    if ([title isEqualToString:kWatchNowString] || [title isEqualToString:kFreeString]) {
        // is it payed for a content?
        Purchase *purchase_ = nil;
        BOOL isReceiptValidated = YES;
        for (purchase_ in _content.purchases) {
            if ([self isNotNull:purchase_.receipt] && !purchase_.isReceiptValidated.boolValue) { //check whether we have receipt data and its not validated object. if we have it then send the subscription request to the server.
                isReceiptValidated = NO;
                break;
            }
        }
        
        if (isReceiptValidated) {
            [self play];
        } else {
            if ([self isNotNull:purchase_] && [self isNotNull:purchase_.receipt]) {
                [self validateTheReceipt:purchase_.receipt withPurchase:purchase_ withPackage:purchase_.package];
            }
        }
        return;
    }
    
    PaymentPickerViewController *vc = [[PaymentPickerViewController alloc] initWithNibName:@"PaymentPickerViewController" bundle:nil];
    vc.view.backgroundColor = [UIColor clearColor];
    vc.content = _content;
    CGRect r = [self.view convertRect:self.priceButton.bounds fromView:self.priceButton];
    _paymentTransitioningDelegate.sinkRect = r;
    
    vc.transitioningDelegate = _paymentTransitioningDelegate;
    
    isIPhone
    {
        vc.modalPresentationStyle = UIModalPresentationCustom;
    }
    else
    {
        vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    [self presentViewController:vc animated:YES completion:^{ ; }];

}

-(void)validateTheReceipt:(NSData *)receipt withPurchase:(Purchase *)pur withPackage:(Package *)package {
    
    [AppDelegate showActivityIndicatorWithText:kPurchaseValidation];
    
    NSManagedObjectContext *managedObjectContext_ = [NSManagedObjectContext childUIManagedObjectContext];
    
    Subscribe *subscribe = [[Subscribe alloc]initWithManagedObjectContext:managedObjectContext_];
    [subscribe subscribe:package.packageId reiept:[receipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn] withCompletionHandler:^(BOOL success, NSDictionary *jsonResponse, NSError *error) {
        
#if DEBUG
        NSLog(@"In-App response from server %@",jsonResponse);
#endif
        PAY_COMMERCIAL_TYPES payCommercialTypes = Buy;
        if ([self isNotNull:package.commercialModel] && [package.commercialModel isEqualToString:@"Rental"]) {
            payCommercialTypes = Rental;
        }else {
            payCommercialTypes = Buy;
        }
        
        if (success) {
            [Analytics logEvent:EVENT_PAY parameters:@{PAY_STATUS_PROPERTY: PAY_CONTENT_STATUS_TYPES_STRING(PayContentSuccess),PAY_PACKAGE_PURCHASE_STATUS:PAY_PACKAGE_PURCHASE_STATUS_STRING(InProgress),PAY_PACKAGE_ID:package.packageId,PAY_PACKAGE_NAME:package.packageName,PAY_PACKAGE_CHANNEL:PAY_COMMERCIAL_TYPES_STRING(payCommercialTypes)} timed:YES];
            
            [AppDelegate removeActivityIndicator];
            pur.isReceiptValidated = @YES;
            
            [self play];
            
        } else {
            [Analytics logEvent:EVENT_PAY parameters:@{PAY_STATUS_PROPERTY: PAY_CONTENT_STATUS_TYPES_STRING(PayContentFailure),PAY_PACKAGE_PURCHASE_STATUS:PAY_PACKAGE_PURCHASE_STATUS_STRING(InProgress),PAY_PACKAGE_ID:package.packageId,PAY_PACKAGE_NAME:package.packageName?:@"",PAY_PACKAGE_CHANNEL:PAY_COMMERCIAL_TYPES_STRING(payCommercialTypes)} timed:YES];
            
            if (_try < 2) {
                _try++;
                [self validateTheReceipt:receipt withPurchase:pur withPackage:package];
            } else {
                
                [AppDelegate removeActivityIndicator];
                [UIAlertView alertViewWithTitle:@"Oops!" message:kVideoFeedNotAvailableMessage];
            }
            //[self callCompletionHandlerWithStatus:NO withResponse:transaction withError:error];
        }
    }];
}

-(void)play {
    
    NSSet *filteredSet = [_content.images filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type == 'thumbnail' && (profile == 'mdpi' || profile == 'hdpi' || profile == 'xhdpi')"]];
    Image *imageEntity  = [filteredSet anyObject];
    
    NSString *contentId = _content.remoteId;
    BOOL drmEnabled = _content.drmEnabled.boolValue;
    NSString *title = _content.title;
    if ([self isNotNull:contentId] /*testing demo && [@[@"405",@"201",@"204"] containsObject:contentId]*/) {
        
        NSLog(@"request for play with contentId %@ title %@, drmStatus %d, imageURL %@",contentId,title,drmEnabled,imageEntity.url);
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        [appDelegate cardSelectedWithStatus:YES drmEnabled:drmEnabled contentId:contentId title:title image:imageEntity.url packageId:nil delegate:self.delegate];
    }
}

- (void)setLayoutWithAnimation:(BOOL)animate
{
    
    void (^blck)() = ^{
        
        // set rating label, duration and release date y
        CGRect frame = self.durationImageView.frame;
        CGFloat y = CGRectGetMaxY(self.ratingView.frame) + spaceAfterBlock;
        frame.origin.y = y;
        //self.ratingLabel.frame = frame;
        frame = self.dateLabel.frame;
        frame.origin.y = y;
        self.dateLabel.frame = frame;
        frame = self.lengthLabel.frame;
        frame.origin.y = y;
        self.lengthLabel.frame = frame;
        frame = self.durationImageView.frame;
        frame.origin.y = y+3;
        self.durationImageView.frame = frame;
        
        frame = self.priceButton.frame;
        frame.origin.y = CGRectGetMaxY(self.durationImageView.frame) + spaceAfterBlock;
        self.priceButton.frame = frame;
        
        frame = self.section1View.frame;
        frame.size.height = CGRectGetMaxY(self.priceButton.frame) + spaceAfterLabel;
        self.section1View.frame = frame;
        
        UIView *sep0 = [self.view viewWithTag:100];
        frame = sep0.frame;
        frame.origin.y = CGRectGetMaxY(self.section1View.frame) + spaceAfterLabel;
        sep0.frame = frame;
        
        
        frame = self.section2View.frame;
        frame.origin.y = CGRectGetMaxY(self.section1View.frame) + spaceAfterBlock;
        self.section2View.frame = frame;
        
        //self.descriptionLabel.alpha = _expanded ? 1 : 0;
        
        frame = self.expanderButton.frame;
        frame.origin.y = self.descriptionLabel.frame.origin.y;
        self.expanderButton.frame = frame;
        
        isIPhone
            [self.descriptionTextView sizeToFit];
        
        frame = self.descriptionTextView.frame;
        frame.origin.y = CGRectGetMaxY(self.descriptionLabel.frame) + spaceAfterLabel + paragraphSpacing;
        
        CGSize size = [self.descriptionTextView sizeThatFits:CGSizeMake(frame.size.width, FLT_MAX)];
        
        //frame.size.height = self.descriptionTextView.contentSize.height;
        frame.size.height = size.height;
        self.descriptionTextView.frame = frame;
        
        
#ifdef DEBUG
        NSLog(@"descriptionText:%@ \nheight:%3f", self.descriptionTextView.text, self.descriptionTextView.contentSize.height);
#endif
        if (self.cardBrowseType != CardsLiveTV) {
            
            [self.creditsLabel setHidden:YES];
            [self.creditsTableView setHidden:NO];
            [self.creditsSeperationView setHidden:NO];
            
//            UIView *sep = [self.view viewWithTag:separatorStartIndex];
//            frame = sep.frame;
//            frame.origin.y = CGRectGetMaxY(self.descriptionTextView.frame) + spaceAfterBlock;
//            sep.frame = frame;
            
            frame = self.creditsLabel.frame;
            frame.origin.y = CGRectGetMaxY(self.descriptionTextView.frame) + spaceAfterBlock;
            self.creditsLabel.frame = frame;
            
            frame = self.creditsTableView.frame;
            frame.origin.y = CGRectGetMaxY(self.creditsLabel.frame) + spaceAfterBlock;
            frame.size.height = self.creditsTableView.rowHeight * [_casts count];
            self.creditsTableView.frame = frame;
            
//            sep = [self.view viewWithTag:separatorStartIndex+1];
//            frame = sep.frame;
//            frame.origin.y = CGRectGetMaxY(self.creditsTableView.frame) + spaceAfterBlock;
//            sep.frame = frame;
            isIPhone
            {
                frame = self.section2View.frame;
                frame.size.height = 117.5;//CGRectGetMaxY(_expanded ? self.creditsTableView.frame : self.descriptionTextView.frame) + spaceAfterBlock;
                self.section2View.frame = frame;

                frame = self.view.frame;
                frame.size.height = CGRectGetMaxY(_expanded ? self.section2View.frame : self.section2View.frame) + spaceAfterBlock;
                self.view.frame = frame;
            }
            else
            {
                frame = self.section2View.frame;
                frame.size.height = CGRectGetMaxY(self.creditsTableView.frame) + spaceAfterBlock;
                self.section2View.frame = frame;
                
                self.block1ScrollView.contentSize = CGSizeMake(self.section2View.frame.size.width, CGRectGetMaxY(self.section2View.frame) + spaceAfterBlock);
            }

        } else {
            [self.creditsLabel setHidden:YES];
            [self.creditsTableView setHidden:YES];
            [self.creditsSeperationView setHidden:YES];
            
//            UIView *sep = [self.view viewWithTag:separatorStartIndex];
//            frame = sep.frame;
//            frame.origin.y = CGRectGetMaxY(self.descriptionTextView.frame) + spaceAfterBlock;
//            sep.frame = frame;
            isIPhone
            {
            frame = self.section2View.frame;
            frame.size.height = CGRectGetMaxY(_expanded ? self.descriptionTextView.frame : self.descriptionTextView.frame) + spaceAfterBlock;
            self.section2View.frame = frame;
            
            frame = self.view.frame;
            frame.size.height = CGRectGetMaxY(_expanded ? self.section2View.frame : self.section2View.frame) + spaceAfterBlock;
            self.view.frame = frame;
            }
            else
            {
                frame = self.section2View.frame;
                frame.size.height = CGRectGetMaxY(self.descriptionTextView.frame);// + spaceAfterBlock;
                self.section2View.frame = frame;
                
                self.block1ScrollView.contentSize = CGSizeMake(self.section2View.frame.size.width, CGRectGetMaxY(self.section2View.frame) + spaceAfterBlock);
            }
        }
        NSLog(@"block %5.f", self.view.frame.size.height);
    };
    
    void (^compl)(BOOL) = ^(BOOL finished){
        NSLog(@"compl %5.f", self.view.frame.size.height);
    };
    
    if (animate) {
        [UIView animateWithDuration:0.3 animations:blck completion:compl];
    }
    else {
        blck();
        compl(YES);
    }
    
}

- (void)transitionAnimation
{
    [self setLayoutWithAnimation:YES];
}

-(void)notificationReceived:(NSNotification *)notification {
    if (notification.name == kNotificationPurchaseSuccess || notification.name == kNotificationCardsRefreshed) {
        NSString *s = [_content getPurchaseString];
//        [self.priceButton setTitle:[s lowercaseString] forState:UIControlStateNormal];
        [self.priceButton setTitle:s forState:UIControlStateNormal];
    } else if(notification.name == kNotificationMatchStatusRefreshed) {
        
        id matchStatus = _content.matchStatus;
        NSArray *teams = matchStatus[@"teams"];
        if (teams.count > 0) {
            id team1 = teams[0];
            self.team1Label.text = [NSString stringWithFormat:@"(%@) %@",team1[@"score"],team1[@"name"]];
        }
        if (teams.count > 1) {
            id team2 = teams[1];
            self.team2Label.text = [NSString stringWithFormat:@"(%@) %@",team2[@"score"],team2[@"name"]];
        }
        self.statusLabel.text = [NSString stringWithFormat:@"%@: %@",matchStatus[@"status"],matchStatus[@"statusDescription"]];
    }
}

#pragma mark - Cast TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_casts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CastCell *cell = (CastCell *)[tableView dequeueReusableCellWithIdentifier:@"CastCellID" forIndexPath:indexPath];
    Cast *cast = (Cast *)_casts[indexPath.row];
    if( [cast.type caseInsensitiveCompare:@"actor"] == NSOrderedSame && [self isNotNull:cast.role]) {
        cell.nameLabel.text = cast.role;
    } else {
        cell.nameLabel.text = cast.type;
    }
    cell.roleLabel.text = cast.name;
    
    isIPhone {} else cell.backgroundColor = [UIColor clearColor];
//    cell.roleLabel.text = cast.type;
//    cell.nameLabel.text = cast.name;
    return cell;
}

-(IBAction)showWebView:(id)sender {
  
    
    AppWebViewController *appWebViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AppWebViewControllerID"];
    appWebViewController.webLink = _content.matchInfo[@"matchMobileUrl"];
    appWebViewController.view.frame = CGRectMake(0, 0,  appWebViewController.view.frame.size.width, appWebViewController.view.frame.size.height);
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:appWebViewController];
    [appWebViewController setNavigationbar];
    [appWebViewController setTitle:@"Match Info"];
    
    isIPhone {
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithSize:appWebViewController.view.bounds.size viewController:navController];
        formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
        formSheet.shadowRadius = 2.0;
        formSheet.shadowOpacity = 0.3;
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.shouldCenterVertically = YES;
        //formSheet.shouldMoveToTopWhenKeyboardAppears = YES;
        
        appWebViewController.delegate = self;
        
        [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            
        }];
    }
    else {
        navController.modalPresentationStyle = UIModalPresentationPageSheet;
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)pressedDoneWithAppWebViewController:(AppWebViewController *)appWebViewController
{
    [appWebViewController dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

#pragma mark - Webview delegate method

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    
    NSLog(@"size: %f, %f", aWebView.frame.size.width, fittingSize.height);
    [self setLayoutWithAnimation:YES];
}

@end
